https://github.com/aws-ia/terraform-aws-eks-blueprints-addon.git

# EFS
## SteP 1 create a role, policy and service account if you dont already have
Get the IAM OIDC provider for your cluster 

```sh
cluster_name=kukuruuku

oidc_id=$(aws eks describe-cluster --name $cluster_name --query "cluster.identity.oidc.issuer" --output text | cut -d '/' -f 5)

echo $oidc_id
# Determine whether an IAM OIDC provider with your cluster's issuer ID is already in your account.
aws iam list-open-id-connect-providers | grep $oidc_id | cut -d "/" -f4
```

## SteP 2 Create the IAM Policy
### 2.1. Create the IAM Policy
- Create a policy JSON file called [efs-csi-driver-policy.json] with the following contents:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "elasticfilesystem:DescribeAccessPoints",
                "elasticfilesystem:DescribeFileSystems"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticfilesystem:CreateAccessPoint"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticfilesystem:DeleteAccessPoint"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticfilesystem:DescribeMountTargets"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticfilesystem:DescribeMountTargetSecurityGroups"
            ],
            "Resource": "*"
        }
    ]
}
```

### 2.2 Create the IAM Policy in AWS
```sh
aws iam create-policy \
    --policy-name AmazonEKS_EFS_CSI_Driver_Policy \
    --policy-document file://efs-csi-driver-policy.json
```

### 2.3. Attach the IAM Policy to Your Role
```sh
aws iam attach-role-policy \
    --role-name macaz-efs-role \
    --policy-arn arn:aws:iam::368085106192:policy/AmazonEKS_EFS_CSI_Driver_Policy
```

### 2.4. Verify the Policy is Attached
```sh
aws iam list-attached-role-policies \
    --role-name macaz-efs-role
```

## Step 3 - and and Assign IAM roles to Kubernetes service accounts 
create a service account for the efs called: [soso-efs-sa]
I already have a role that I will use called: [macaz-efs-role]

### Update the Assume Role Policy
- veryfy the role:

```sh
aws iam get-role --role-name macaz-efs-role
```

- get your oidc number and replace with yours. Mine in the json file is:  FD49F88F458EE34D2E549CAD66539654
- put the below json code in a file: assume-role-policy.json

```sh
nano assume-role-policy.json
```

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::368085106192:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/FD49F88F458EE34D2E549CAD66539654"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "oidc.eks.us-east-1.amazonaws.com/id/FD49F88F458EE34D2E549CAD66539654:sub": "system:serviceaccount:kube-system:soso-efs-sa"
                }
            }
        }
    ]
}
```

***To update the role's trust policy, you can use the following command:*** 

```sh
aws iam update-assume-role-policy --role-name macaz-efs-role --policy-document file://assume-role-policy.json

aws iam get-role --role-name macaz-efs-role | jq '.Role.AssumeRolePolicyDocument'
```

### Now create the SA yaml with the name of the role:

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: soso-efs-sa
  namespace: kube-system
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::368085106192:role/macaz-efs-role
```

## Step 4: Add the EFS CSI Driver Helm Repository

```sh
helm repo add aws-efs-csi-driver https://kubernetes-sigs.github.io/aws-efs-csi-driver/
helm repo update
```

## Step 5: Install the EFS CSI Driver and add the created service acct
[Link:](https://github.com/kubernetes-sigs/aws-efs-csi-driver/releases)
[Get the tag version from the values.yaml file](https://github.com/kubernetes-sigs/aws-efs-csi-driver/blob/master/charts/aws-efs-csi-driver/values.yaml)
[repo](https://docs.aws.amazon.com/eks/latest/userguide/add-ons-images.html)

```sh
helm upgrade -i aws-efs-csi-driver aws-efs-csi-driver/aws-efs-csi-driver \
    --namespace kube-system \
    --version 3.0.8 \
    --set image.repository=602401143452.dkr.ecr.us-east-1.amazonaws.com/eks/aws-efs-csi-driver \
    --set image.tag=v2.0.7 \
    --set controller.serviceAccount.create=false \
    --set controller.serviceAccount.name=soso-efs-sa
```

### get the resources
```sh
k -n kube-system get sa soso-efs-sa
k -n kube-system get deploy efs-csi-controller
```

## Step 6: Create an EFS File System
```sh
aws efs create-file-system \
    --region us-east-1 \
    --performance-mode generalPurpose \
    --throughput-mode bursting \
    --tags Key=Name,Value=MyEFSFileSystem
```

## STEP 7 TO BE. seems I had to Create Mount Targets:
- Create mount targets for your EFS file system in each availability zone of your VPC where you plan to mount the file system.
- Get the sg and subnets of your vpc
- In my case I am using 3 AZ subnets with same sg 

```sh   
aws efs create-mount-target --file-system-id fs-045d117974d7e4368 --subnet-id <PrivateSubnetId-2a> --security-groups <SecurityGroupId>
aws efs create-mount-target --file-system-id fs-045d117974d7e4368 --subnet-id <PrivateSubnetId-2b> --security-groups <SecurityGroupId>
aws efs create-mount-target --file-system-id fs-045d117974d7e4368 --subnet-id <PrivateSubnetId-2c> --security-groups <SecurityGroupId>


aws efs create-mount-target --file-system-id fs-045d117974d7e4368 --subnet-id subnet-0a339ff7b94d5eb7e --security-groups sg-0a465a08ef5c488c0
aws efs create-mount-target --file-system-id fs-045d117974d7e4368 --subnet-id subnet-0e4062cf43d69d7d0 --security-groups sg-0a465a08ef5c488c0
aws efs create-mount-target --file-system-id fs-045d117974d7e4368 --subnet-id subnet-0a6997ccec3c6e32a --security-groups sg-0a465a08ef5c488c0
```

## Step 8: Create a PV, PVC, SAMPLE SVC for EFS
- deploy the shared-provisioning.yaml  file

```sh
k apply -f shared-provisioning.yaml
```

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: efs-pv
spec:
  capacity:
    storage: 5Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  storageClassName: efs-sc
  csi:
    driver: efs.csi.aws.com
    volumeHandle: fs-045d117974d7e4368  # Replace with your EFS File System ID
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: efs-pvc
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: efs-sc
  resources:
    requests:
      storage: 5Gi
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
        volumeMounts:
        - name: efs-storage
          mountPath: /usr/share/nginx/html  # Path where the EFS will be mounted
      volumes:
      - name: efs-storage
        persistentVolumeClaim:
          claimName: efs-pvc
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
  labels:
    app: nginx
spec:
  ports:
    - port: 80
  selector:
    app: nginx
  type: LoadBalancer
```

### get the resources
```sh
kubectl -n kube-system logs -l app=efs-csi-controller -c efs-plugin
nslookup fs-045d117974d7e4368.efs.us-east-1.amazonaws.com
```

### Other troubleshooting
```sh
kubectl describe node ip-10-0-10-243.us-east-1.compute.internal
kubectl logs ip-10-0-10-243.us-east-1.compute.internal -n kube-system -c kubelet
kubectl logs ip-10-0-36-98.us-east-1.compute.internal -n kube-system -c kubelet
```

## test-it

```sh
echo "test" > /usr/share/nginx/html/test.py
cat /usr/share/nginx/html/test.py
```


###NEXT UP Is Dynamic provisioning w nfs-subdir-external-provisioner

https://github.com/kubernetes-sigs/nfs-subdir-external-provisioner/tree/master/charts/nfs-subdir-external-provisioner

