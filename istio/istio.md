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


