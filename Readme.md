## Documentación completa con imagenes 
https://medium.com/@giovannyorjuel2/integrando-jenkins-con-vault-2f1d42e31f95



### Vault plugin
https://plugins.jenkins.io/hashicorp-vault-plugin/

### setup vault
https://gist.github.com/Mishco/b47b341f852c5934cf736870f0b5da81

### policy 
https://developer.hashicorp.com/vault/docs/concepts/policies#capabilities


```shell script
vault server -config=vault_config.hcl 
   
vault status

vault operator init -key-shares=1 -key-threshold=1

vault operator unseal

export VAULT_TOKEN=hvs.Xg6fI2NZOqs1tegnlwoNLv4S

vault login

vault auth enable approle

vault write auth/approle/role/jenkins-role secret_id_ttl=10m token_num_uses=10 token_ttl=20m token_max_ttl=30m secret_id_num_uses=40 policies=jenkins

vault read auth/approle/role/jenkins-role/role-id

vault write -f auth/approle/role/jenkins-role/secret-id

vault secrets enable -path=secrets kv

vault write secrets/creds/my-secret-jenkins secret=Jenkins!321

vault policy write jenkins jenkins-policy.hcl 

vault token lookup hvs.CAESIDa4azasfi-l7lYyVY5jhHPkZJidmTP1dUypKOyo0pG3Gh4KHGh2cy5XZkRqM2hodTRyQU5ZSm9MejMwb1ZPbm4
 
curl \
    --header "X-Vault-Token: hvs.dLXtGrkntXngWww8JUnBHzqh" \
    --request POST \
    --data '{"policies": "jenkins"}' \
    http://127.0.0.1:8200/v1/auth/approle/role/jenkins-role


vault token create -no-default-policy

```

```json
{"request_id":"c07e1d27-85da-3ce7-e8f6-1989641fdfb4","lease_id":"","renewable":false,"lease_duration":0,"data":null,"wrap_info":null,"warnings":null,"auth":{"client_token":"hvs.CAESIKy4tQWEStyU1MZ11rU-JSbfMqCetYotmceKsg-vAHvzGh4KHGh2cy40am1WOG9USGhKZnltVmhFR08wSnk1MWY","accessor":"PEQCDZESmAc9rwiQumNr1dqI","policies":["default","jenkins"],"token_policies":["default","jenkins"],"metadata":{"role_name":"jenkins-role"},"lease_duration":1200,"renewable":true,"entity_id":"f5798c1d-9738-d60c-0c95-d77cb44a5af5","token_type":"service","orphan":true,"mfa_requirement":null,"num_uses":10}}
```

- **request_id**: Es un identificador único para cada solicitud al Vault. Cada vez que se realiza una solicitud, se genera un nuevo request_id.
-  **client_token**: Es el token de cliente que se utiliza para realizar operaciones en el Vault. Cada solicitud de token exitosa generará un nuevo token de cliente, que es válido durante un período de tiempo específico.
-  **accessor**: Es un identificador único para la entidad asociada al token. Se utiliza internamente por Vault para hacer referencia al token.
-  **policies**: Es una lista de políticas asociadas con el token. Las políticas definen qué operaciones puede realizar el token en el Vault.
-  **token_policies**: Es similar a "policies", pero representa las políticas efectivas del token. Estas pueden ser diferentes de las políticas originales si hay políticas globales que se aplican.
- **metadata**: Contiene metadatos adicionales sobre el token, como el nombre del rol asociado al token.
- **lease_duration**: Es la duración del tiempo de vida del token, es decir, cuánto tiempo será válido el token antes de expirar.
- **renewable**: Indica si el token es renovable o no. Si es renovable, puede ser renovado antes de que expire.
- **entity_id**: Es un identificador único para la entidad asociada al token, similar al accessor.
- *token_type**: Indica el tipo de token. En este caso, ambos son tokens de servicio.
- **orphan**: Indica si el token es huérfano o no. Un token huérfano es un token que no tiene un padre asociado.
- **mfa_requirement**: Indica si se requiere autenticación de múltiples factores para este token.
- **num_uses**: Indica el número de veces que el token se ha utilizado hasta el momento.


curl \
    --request POST \
    --data '{"role_id":"8325f5a2-2896-cb40-446d-b29d69ca7393","secret_id":"7aa0c906-c110-0c35-b038-a754251d0da4"}' \
    http://127.0.0.1:8200/v1/auth/approle/login


curl \
    --header "X-Vault-Token: hvs.dLXtGrkntXngWww8JUnBHzqh" \
    --request GET \
    http://127.0.0.1:8200/v1/secrets/creds/my-secret-jenkins

curl \
    --header "X-Vault-Token: hvs.CAESIEcgOPIWgishHpGzB63xOaf363PuwePltznieUUzTHhjGh4KHGh2cy5TVzk1R3dmeHg5V2dUbDU2UHk4Z09qS04" \
    --request GET \                                                                                                 
    http://127.0.0.1:8200/v1/secrets/creds/my-secret-jenkins

curl \
    --header "X-Vault-Token: hvs.CAESIAVKaWOqrSTEhRpDxE93bjab6sjl9tKUEWtSJ-KIBLn-Gh4KHGh2cy5lUWhtVHFqVjJZUjZuVFNxVUVQeEcwczU" \
    --request GET \
    http://127.0.0.1:8200/v1/secrets/creds/my-secret-jenkins

    curl \
    --header "X-Vault-Token: hvs.Xg6fI2NZOqs1tegnlwoNLv4S" \
    --request POST \
    --data '{"policies": "jenkins"}' \
    http://127.0.0.1:8200/v1/auth/approle/role/my-role
