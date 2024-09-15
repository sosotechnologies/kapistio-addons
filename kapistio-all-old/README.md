
terraform plan 
terraform plan -out=tfplan -json > plan_output.json
tofu apply tfplan


aws eks --region us-east-1 update-kubeconfig --name kukuruuku

####### For Istio ##################
NOTE : THis will be the service account IRSA Role for webIdentity: karpenter-controller

```sh
tofu init
tofu apply --auto-approve
```

kubectl get pods -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller


Once the resources have been provisioned, you will need to replace the `istio-ingress` pods due to a [`istiod` dependency issue](https://github.com/istio/istio/issues/35789). Use the following command to perform a rolling restart of the `istio-ingress` pods:

```sh
kubectl rollout restart deployment istio-ingress -n istio-ingress
```

### Observability Add-ons

Use the following code snippet to add the Istio Observability Add-ons on the EKS
cluster with deployed Istio.

```sh
for ADDON in kiali jaeger prometheus grafana
do
    ADDON_URL="https://raw.githubusercontent.com/istio/istio/release-1.20/samples/addons/$ADDON.yaml"
    kubectl apply -f $ADDON_URL
done
```

## Validate

1. List out all pods and services in the `istio-system` namespace:

    ```sh
    kubectl get pods,svc -n istio-system
    kubectl get pods,svc -n istio-ingress
    ```

    ```text
    NAME                             READY   STATUS    RESTARTS   AGE
    pod/grafana-7d4f5589fb-4xj9m     1/1     Running   0          4m14s
    pod/istiod-ff577f8b8-c8ssk       1/1     Running   0          4m40s
    pod/jaeger-58c79c85cd-n7bkx      1/1     Running   0          4m14s
    pod/kiali-749d76d7bb-8kjg7       1/1     Running   0          4m14s
    pod/prometheus-5d5d6d6fc-s1txl   2/2     Running   0          4m15s

    NAME                       TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                                 AGE
    service/grafana            ClusterIP   172.20.141.12    <none>        3000/TCP                                4m14s
    service/istiod             ClusterIP   172.20.172.70    <none>        15010/TCP,15012/TCP,443/TCP,15014/TCP   4m40s
    service/jaeger-collector   ClusterIP   172.20.223.28    <none>        14268/TCP,14250/TCP,9411/TCP            4m15s
    service/kiali              ClusterIP   172.20.182.231   <none>        20001/TCP,9090/TCP                      4m15s
    service/prometheus         ClusterIP   172.20.89.64     <none>        9090/TCP                                4m14s
    service/tracing            ClusterIP   172.20.253.201   <none>        80/TCP,16685/TCP                        4m14s
    service/zipkin             ClusterIP   172.20.221.157   <none>        9411/TCP                                4m15s

    NAME                                 READY   STATUS    RESTARTS   AGE
    pod/istio-ingress-6f7c5dffd8-g1szr   1/1     Running   0          4m28s

    NAME                    TYPE           CLUSTER-IP      EXTERNAL-IP                                                                     PORT(S)                                      AGE
    service/istio-ingress   LoadBalancer   172.20.104.27   k8s-istioing-istioing-844c89b6c2-875b8c9a4b4e9365.elb.us-west-2.amazonaws.com   15021:32760/TCP,80:31496/TCP,443:32534/TCP   4m28s
    ```

2. Verify all the Helm releases installed in the `istio-system` and `istio-ingress` namespaces:

    ```sh
    helm list -n istio-system
    ```

    ```text
    NAME           NAMESPACE    REVISION UPDATED                              STATUS   CHART          APP VERSION
    istio-base    istio-system 1        2023-07-19 11:05:41.599921 -0700 PDT deployed base-1.18.1    1.18.1
    istiod        istio-system 1        2023-07-19 11:05:48.087616 -0700 PDT deployed istiod-1.18.1  1.18.1
    ```

    ```sh
    helm list -n istio-ingress
    ```

    ```text
    NAME           NAMESPACE    REVISION UPDATED                              STATUS   CHART          APP VERSION
    istio-ingress istio-ingress 1        2023-07-19 11:06:03.41609 -0700 PDT  deployed gateway-1.18.1 1.18.1
    ```

### Observability Add-ons

Validate the setup of the observability add-ons by running the following commands
and accessing each of the service endpoints using this URL of the form
[http://localhost:\<port>](http://localhost:<port>) where `<port>` is one of the
port number for the corresponding service.

```sh
# Visualize Istio Mesh console using Kiali
kubectl port-forward svc/kiali 20001:20001 -n istio-system

# Get to the Prometheus UI
kubectl port-forward svc/prometheus 9090:9090 -n istio-system

# Visualize metrics in using Grafana
kubectl port-forward svc/grafana 3000:3000 -n istio-system

# Visualize application traces via Jaeger
kubectl port-forward svc/jaeger 16686:16686 -n istio-system
```

# Karpenter on EKS Fargate

This pattern demonstrates how to provision Karpenter on a serverless cluster (serverless data plane) using Fargate Profiles.

## Deploy

See [here](https://aws-ia.github.io/terraform-aws-eks-blueprints/getting-started/#prerequisites) for the prerequisites and steps to deploy this pattern.

## Validate

1. Test by listing the nodes in the cluster. You should see four Fargate nodes in the cluster:

    ```sh
    kubectl get nodes

    NAME                                                STATUS   ROLES    AGE     VERSION
    fargate-ip-10-0-11-195.us-west-2.compute.internal   Ready    <none>   5m20s   v1.28.2-eks-f8587cb
    fargate-ip-10-0-27-183.us-west-2.compute.internal   Ready    <none>   5m2s    v1.28.2-eks-f8587cb
    fargate-ip-10-0-4-169.us-west-2.compute.internal    Ready    <none>   5m3s    v1.28.2-eks-f8587cb
    fargate-ip-10-0-44-106.us-west-2.compute.internal   Ready    <none>   5m12s   v1.28.2-eks-f8587cb
    ```

2. Provision the Karpenter `EC2NodeClass` and `NodePool` resources which provide Karpenter the necessary configurations to provision EC2 resources:

    ```sh
    kubectl apply -f karpenter.yaml
    ```

3. Once the Karpenter resources are in place, Karpenter will provision the necessary EC2 resources to satisfy any pending pods in the scheduler's queue. You can demonstrate this with the example deployment provided. First deploy the example deployment which has the initial number replicas set to 0:

    ```sh
    kubectl apply -f example.yaml
    ```

4. When you scale the example deployment, you should see Karpenter respond by quickly provisioning EC2 resources to satisfy those pending pod requests:

    ```sh
    kubectl scale deployment inflate --replicas=3
    ```

5. Listing the nodes should now show some EC2 compute that Karpenter has created for the example deployment:

    ```sh
    kubectl get nodes

    NAME                                                STATUS   ROLES    AGE   VERSION
    fargate-ip-10-0-11-195.us-west-2.compute.internal   Ready    <none>   13m   v1.28.2-eks-f8587cb
    fargate-ip-10-0-27-183.us-west-2.compute.internal   Ready    <none>   12m   v1.28.2-eks-f8587cb
    fargate-ip-10-0-4-169.us-west-2.compute.internal    Ready    <none>   12m   v1.28.2-eks-f8587cb
    fargate-ip-10-0-44-106.us-west-2.compute.internal   Ready    <none>   13m   v1.28.2-eks-f8587cb
    ip-10-0-32-199.us-west-2.compute.internal           Ready    <none>   29s   v1.28.2-eks-a5df82a # <== EC2 created by Karpenter
    ```

## Destroy

Scale down the deployment to de-provision Karpenter created resources first:

```sh
kubectl delete -f example.yaml
```

{%
   include-markdown "../../docs/_partials/destroy.md"
%}



############## For IRSA ###########################
# Amazon EKS Blueprints Addon tofu module

tofu module which provisions an addon ([Helm release](https://registry.tofu.io/providers/hashicorp/helm/latest/docs/resources/release)) and an [IAM role for service accounts (IRSA)](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html).

## Usage

### Create Addon (Helm Release) w/ IAM Role for Service Account (IRSA)

```hcl
module "eks_blueprints_addon" {
  source = "aws-ia/eks-blueprints-addon/aws"
  version = "~> 1.0" #ensure to update this to the latest/desired version

  chart            = "karpenter"
  chart_version    = "0.16.2"
  repository       = "https://charts.karpenter.sh/"
  description      = "Kubernetes Node Autoscaling: built for flexibility, performance, and simplicity"
  namespace        = "karpenter"
  create_namespace = true

  set = [
    {
      name  = "clusterName"
      value = "eks-blueprints-addon-example"
    },
    {
      name  = "clusterEndpoint"
      value = "https://EXAMPLED539D4633E53DE1B71EXAMPLE.gr7.us-east-1.eks.amazonaws.com"
    },
    {
      name  = "aws.defaultInstanceProfile"
      value = "arn:aws:iam::111111111111:instance-profile/KarpenterNodeInstanceProfile-complete"
    }
  ]

  set_irsa_names = ["serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"]
  # # Equivalent to the following but the ARN is only known internally to the module
  # set = [{
  #   name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
  #   value = iam_role_arn.this[0].arn
  # }]

  # IAM role for service account (IRSA)
  create_role = true
  role_name   = "karpenter-controller"
  role_policies = {
    karpenter = "arn:aws:iam::111111111111:policy/Karpenter_Controller_Policy-20221008165117447500000007"
  }

  oidc_providers = {
    this = {
      provider_arn = "oidc.eks.us-east-1.amazonaws.com/id/EXAMPLED539D4633E53DE1B71EXAMPLE"
      # namespace is inherited from chart
      service_account = "karpenter"
    }
  }

  tags = {
    Environment = "dev"
  }
}
```

### Create Addon (Helm Release) Only

```hcl
module "eks_blueprints_addon" {
  source = "aws-ia/eks-blueprints-addon/aws"
  version = "~> 1.0" #ensure to update this to the latest/desired version

  chart         = "metrics-server"
  chart_version = "3.8.2"
  repository    = "https://kubernetes-sigs.github.io/metrics-server/"
  description   = "Metric server helm Chart deployment configuration"
  namespace     = "kube-system"

  values = [
    <<-EOT
      podDisruptionBudget:
        maxUnavailable: 1
      metrics:
        enabled: true
    EOT
  ]

  set = [
    {
      name  = "replicas"
      value = 3
    }
  ]
}
```

### Create IAM Role for Service Account (IRSA) Only

```hcl
module "eks_blueprints_addon" {
  source = "aws-ia/eks-blueprints-addon/aws"
  version = "~> 1.0" #ensure to update this to the latest/desired version

  # Disable helm release
  create_release = false

  # IAM role for service account (IRSA)
  create_role = true
  create_policy = false
  role_name   = "aws-vpc-cni-ipv4"
  role_policies = {
    AmazonEKS_CNI_Policy = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  }

  oidc_providers = {
    this = {
      provider_arn    = "oidc.eks.us-east-1.amazonaws.com/id/EXAMPLED539D4633E53DE1B71EXAMPLE"
      namespace       = "kube-system"
      service_account = "aws-node"
    }
  }

  tags = {
    Environment = "dev"
  }
}
```

<!-- BEGINNING OF PRE-COMMIT-tofu DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_tofu"></a> [tofu](#requirement\_tofu) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.47 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.9 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.47 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | >= 2.9 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.this](https://registry.tofu.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.this](https://registry.tofu.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.additional](https://registry.tofu.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.this](https://registry.tofu.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [helm_release.this](https://registry.tofu.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [aws_caller_identity.current](https://registry.tofu.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.assume](https://registry.tofu.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.this](https://registry.tofu.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.tofu.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |



--target=aws_security_group.custom_sg