https://middlewaretechnologies.in/2022/01/how-to-authenticate-user-with-keycloak-oidc-provider-in-kubernetes.html#Test_Environment


openssl req -x509 -nodes -days 730 -newkey rsa:2048 -keyout tls.key -out tls.crt -config sslcert.conf -extensions 'v3_req'

cat tls.crt | base64 -w 0
cat tls.key | base64 -w 0
