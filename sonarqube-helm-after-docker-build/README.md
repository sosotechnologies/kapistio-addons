## Create and deploy postgres secret 
kubectl -n sonarqube create secret generic sonarqube-postgresql-secret --from-literal=postgres-password=Depay20$ --dry-run=client -o yaml > postgressecret.yaml



## For sonarqube/sonarqube
helm repo add sonarqube https://SonarSource.github.io/helm-chart-sonarqube
helm repo update
helm pull sonarqube/sonarqube --untar=true

## configure values.yaml

### change the image to mine
image:
  repository: cafanwii/sonarqube
  tag: 1.0.0
  pullPolicy: IfNotPresent

### [change to true] If enable the JDBC Overwrite, 
jdbcOverwrite:
  # If enable the JDBC Overwrite, make sure to set `postgresql.enabled=false`
  enable: true
  # The JDBC url of the external DB
  jdbcUrl: "jdbc:postgresql://10.0.0.36/sonarqube2024?socketTimeout=1500"
  # The DB user that should be used for the JDBC connection
  jdbcUsername: "cafanwiiuser"
  # Use this if you don't mind the DB password getting stored in plain text within the values file
  jdbcPassword: "Depay20$"

### Enable to deploy the bitnami PostgreSQL chart
enable: false

## install
helm install sonargube sonarqube -n sonarqube

## connecting to database
psql -h cafanwii-postgres-sosotech.io -u cafanwiiuser -d sonarqube

helm chart link: [https://gitlab.com/afanwicollins/helm-gitlab](https://gitlab.com/afanwicollins/helm-gitlab)
