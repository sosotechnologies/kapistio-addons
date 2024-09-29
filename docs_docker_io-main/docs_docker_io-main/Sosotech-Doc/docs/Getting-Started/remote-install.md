# Remote Server

## Installation links

### Install IAM EKS authenticator 
  - [Right-Click to open Link in a New Tab](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html)
```
curl -o aws-iam-authenticator https://amazon-eks.s3.us-west-2.amazonaws.com/1.15.10/2020-02-22/bin/linux/amd64/aws-iam-authenticator
chmod +x ./aws-iam-authenticator
sudo mv ./aws-iam-authenticator /usr/local/bin
aws-iam-authenticator help
```
### Install docker in ec2 
  - [Right-Click to open Link in a New Tab](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/create-container-image.html)

### Install AWSCLI 
  - [Right-Click to open Link in a New Tab](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

### Install Terraform 
  - [Right-Click to open Link in a New Tab](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

### Install Kubens + kubectx 
  - [Right-Click to open Link in a New Tab](https://github.com/ahmetb/kubectx#installation) 

### Install HelM 
  - [Right-Click to open Link in a New Tab](https://helm.sh/docs/intro/install/)
```
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
```

### Install Kubectl 
  - [Right-Click to open Link in a New Tab](https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html/)
```
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
echo "$(<kubectl.sha256)  kubectl" | sha256sum --check
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client --output=yaml
```

### Install MkDocs 
  - [Right-Click to open Link in a New Tab](https://www.mkdocs.org/user-guide/installation/)
```
pip install mkdocs
mkdocs helm
mkdocs new my-soso-package
cd my-soso-package
tree
```

### Install PiP on RHeL
```
REDHAT
sudo yum info python*-pip     //get the pip version, then install the version
sudo yum install python39-pip
python3 --version
curl -O https://bootstrap.pypa.io/get-pip.py
python3 get-pip.py --user
```

### Install Trivy 
  - [Right-Click to open Link in a New Tab](https://aquasecurity.github.io/trivy/v0.18.3/installation/)

```
sudo yum -y update

sudo wget https://github.com/aquasecurity/trivy/releases/download/v0.18.3/trivy_0.18.3_Linux-64bit.deb
sudo dpkg -i trivy_0.18.3_Linux-64bit.deb
trivy i nginx    //scanning nginx image
trivy i nginx | grep -i critical
trivy i nginx:alpine | grep -i critical
```