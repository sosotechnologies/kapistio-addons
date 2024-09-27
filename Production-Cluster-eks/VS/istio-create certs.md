aws eks --region us-east-1 update-kubeconfig --name IWordee-Production-sosotechboss

## Download the chart
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update
helm search repo istio

## Mkdir for Istio Helm charts

mkdir svc-mersh-istio
cd svc-mersh-istio/
helm pull istio/istiod --untar=true
helm pull istio/base --untar=true
helm pull istio/gateway --untar=true
mv gateway ingressgateway
mv base istio-base

## Install the charts
kubectl create ns istio-system
helm install istio-base -n istio-system istio-base
helm install istiod -n istio-system istiod
helm install ingressgateway -n istio-system ingressgateway
kubectl -n istio-system get po

## Mkdir for virtual-svc and gateway yamls | Apply the gateway
mkdir istio-vs-gw-files
cd istio-vs-gw-files/
kubectl apply -f gateway.yaml


## create the cert and secure the record
sudo certbot certonly --manual -d *.globalwealthorder.com --agree-tos --manual-public-ip-logging-ok --preferred-challenges dns-01 --server https://acme-v02.api.letsencrypt.org/directory --email=macfenty@gmail.com --rsa-key-size 4096

### save as a text record
_acme-challenge.globalwealthorder.com.
6j4Cp-UTkajyutcgMviCtn-Se8uuc1aLMB6tEW1rJZ0

### save the C or  A Record - save the LB as a CNAME Record
k8s-istioing-istioing-02c45aaad3-7f4188698cbeaadd.elb.us-east-1.amazonaws.com

### cREATE A secret with the TLS Key n cert
sudo kubectl create secret tls gateway-certs --cert=/etc/letsencrypt/live/globalwealthorder.com/fullchain.pem --key=/etc/letsencrypt/live/globalwealthorder.com/privkey.pem -n istio-system --dry-run=client -o yaml > globalwealthorder-tls-secret.yaml

### argocd
mkdir argocd && cd argocd
wget https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl  -n argocd  apply -f install.yaml 
k create argocd
k create ns argocd
kubectl  -n argocd  apply -f install.yaml 
kubectl -n argocd get all

### Longhorn
https://longhorn.io/docs/1.7.1/deploy/install/install-with-kubectl/

```sh
kubectl apply -f https://raw.githubusercontent.com/longhorn/longhorn/v1.7.1/deploy/longhorn.yaml

kubectl get pods \
--namespace longhorn-system \
--watch

```