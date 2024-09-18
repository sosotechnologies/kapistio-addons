# Amazon EKS Blueprints Addon Tests

Configuration in this directory provisions:
- An EKS cluster and VPC 
- An addon (Helm release) for [`metrics-server`](https://github.com/kubernetes-sigs/metrics-server) without an IAM role for service account (IRSA)
- An addon (Helm release) for [`karpenter`](https://github.com/aws/karpenter) with an IAM role for service account (IRSA)
- An addon (Helm release) for [`Istio`](https://github.com/aws/karpenter) 
  * Install Istio Ingress Gateway using Helm resources in tofu
  * This step deploys a Service of type `LoadBalancer` that creates an AWS Network Load Balancer.
  * Deploy/Validate Istio communication using sample application
- An IAM role for service account (IRSA) suitable for use by the [AWS VPC-CNI](https://github.com/aws/amazon-vpc-cni-k8s)

Refer to the [documentation](https://istio.io/latest/docs/concepts/) on Istio
concepts.

## Usage

To run this example you need to execute:

```bash
$ tofu init
$ tofu plan
$ tofu apply #--auto-approve
```

###  For Istio
Once the resources have been provisioned, you will need to replace the `istio-ingress` pods due to a [`istiod` dependency issue](https://github.com/istio/istio/issues/35789). Use the following command to perform a rolling restart of the `istio-ingress` pods:

```sh
kubectl rollout restart deployment istio-ingress -n istio-ingress

kubectl get pods -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller
```

#### Other Istio OPTIONAL Addons - Observability Add-ons

Use the following code snippet to add the Istio Observability Add-ons on the EKS
cluster with deployed Istio.

```sh
for ADDON in kiali jaeger prometheus grafana
do
    ADDON_URL="https://raw.githubusercontent.com/istio/istio/release-1.20/samples/addons/$ADDON.yaml"
    kubectl apply -f $ADDON_URL
done
```

***Validate***

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


### Observation about Istio on Fargate

```text
There seems to be an issue when integrating Karpenter with resources, especially in a Fargate or managed node-based EKS cluster setup. 
Istio and the AWS Load Balancer Controller require access to underlying EC2 nodes, and deploying them with Fargate profiles may cause networking issues. The webhook service for the AWS Load Balancer Controller might be failing because of Fargate limitations.

Solution: Istio is more likely to work smoothly with EC2-backed worker nodes (managed or via Karpenter). Ensure that:

Istio pods (especially istiod and istio-ingressgateway) are scheduled on EC2-backed nodes instead of Fargate.
Karpenter should be configured to ensure the correct nodes are provisioned for the workloads that cannot run on Fargate.
Ensure Istio and AWS Load Balancer Controller run on EC2 instances provisioned by Karpenter, using node selectors, taints, or tolerations.
Confirm that Karpenter is properly provisioning nodes with the required capacity (e.g., instance types m5.large).
Ensure the AWS Load Balancer Controller is installed and functioning correctly on EC2 nodes to avoid webhook errors.
Double-check network policies and security groups to make sure the required ports for Istio communication are open.
By addressing these potential conflicts between Fargate and EC2-backed workloads, your integration with Karpenter should work more smoothly.
```