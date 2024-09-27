## Install the argocd application

```sh
mkdir argocd && cd argocd
wget https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl  -n argocd  apply -f install.yaml 
kubectl -n argocd get all
```

## Create the configmaps
- add argocd virtual-service for istio
- be sure [arcocd-param-cm.yaml] and [arcocd-cm.yaml], contain the values of your keycloak client and realm
- apply the files, based on numering

```sh
kubectl apply -f 1-argocd-vs.yaml
kubectl -n argocd apply -f 2-arcocd-param-cm.yaml      # will configure existing
```

### Retsrat the deploy via rollout
```sh
kubectl -n argocd rollout restart deploy,sts
kubectl -n argocd get po
```

NOW CHECK THE ARGOCD URL IF APP IS WORKING.

### copy the argo application secret to a file for visiility

```sh
kubectl -n argocd get secret argocd-secret -o yaml > argocdsecret.yaml 
```

## Disable username and password

apply just this part of file [3-argocd-cm.yaml], we will later apply the complete file as seen in the file after creating our keycloak items:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-cm
  labels:
    app.kubernetes.io/name: argocd-cm
    app.kubernetes.io/part-of: argocd
data:
  admin.enabled: "false"
```

Apply this now and later we will reapply the file with complete values

```sh
kubectl -n argocd apply -f  3-argocd-cm.yaml
```

NOW CHECK THE ARGOCD URL YOU WILL SEE THAT USERNAME/PASSWORD ARE DISABLED


## Now implement Keycloak


My actual keycloak is: 
user: collins 
pass: secret


- For the client role. delete the default and create a new role: vaultadminrole
- for client scope [one on lect task bar] add clientscope called: vaultgroups
- Cleate Mapper under the client scope called vaultgroups. Name the mapper: vaultgroups
    - Mapper type: Group Membership
    - Token Claim Name: vaultgroups
- Now return to the client and on it's own for client scope move the  vaultgroups from Available Client Scopes to Assigned Default Client Scopes 
- create a group: vaultAdmin
- create a user: collinsvault
- join the collinsvault to the vaultAdmin group
- My issuer is : https://keycloak.sosotech.io/auth/realms/sosotech

| Client Name   | credentials                        | role           | client scopes   | Mapper      | group       | user         |
|---------------|------------------------------------|----------------|-----------------|-------------|-------------|--------------|
| vault-aws     | jTYBnVDXCTvamO8q8EAIeYhE3cy8Bs9i   | vaultadminrole |     vaultgroups | vaultgroups |  vaultAdmin | collinsvault |

REFERENCE: The user I used for argocd was cafanwii


