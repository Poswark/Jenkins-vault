pipeline {
    agent any
    parameters {
        password(name: 'VAULT_TOKEN', defaultValue: '', description: 'Token de autenticación para Vault')
        string(name: 'VAULT_PATH', defaultValue: 'my-secret', description: 'Path del secreto en Vault')
        string(name: 'SECRET_KEY1', defaultValue: 'key1', description: 'Clave del secreto 1')
        password(name: 'SECRET_VALUE1', defaultValue: 'value1', description: 'Valor del secreto 1')
        string(name: 'SECRET_KEY2', defaultValue: '', description: 'Clave del secreto 2 (opcional)')
        password(name: 'SECRET_VALUE2', defaultValue: '', description: 'Valor del secreto 2 (opcional)')
        string(name: 'SECRET_KEY3', defaultValue: '', description: 'Clave del secreto 3 (opcional)')
        password(name: 'SECRET_VALUE3', defaultValue: '', description: 'Valor del secreto 3 (opcional)')
        string(name: 'SECRET_KEY4', defaultValue: '', description: 'Clave del secreto 4 (opcional)')
        password(name: 'SECRET_VALUE4', defaultValue: '', description: 'Valor del secreto 4 (opcional)')
        string(name: 'SECRET_KEY5', defaultValue: '', description: 'Clave del secreto 5 (opcional)')
        password(name: 'SECRET_VALUE5', defaultValue: '', description: 'Valor del secreto 5 (opcional)')
    }
    environment {
        VAULT_SERVER = "http://vault:8200" // Cambia esta URL según tu configuración
    }
    stages {
        stage('Check or Create Secret') {
            steps {
                script {
                    // Función para construir el payload
                    def buildPayload = {
                        def data = [:]
                        for (int i = 1; i <= 5; i++) {
                            def key = params["SECRET_KEY${i}"]
                            def value = params["SECRET_VALUE${i}"]
                            if (key?.trim() && value) {
                                // Convertir valores sensibles a texto plano
                                value = value instanceof hudson.util.Secret ? value.getPlainText() : value
                                data[key.trim()] = value.trim()
                            }
                        }
                        // Crear el objeto final con el formato requerido
                        return groovy.json.JsonOutput.toJson([data: data])
                    }

                    // Escribir el payload en un archivo
                    def payloadFile = "vault_payload.json"
                    writeFile file: payloadFile, text: buildPayload()

                    // Verificar si el secreto ya existe en Vault
                    def checkCommand = """
                        set +x
                        curl --silent --header "X-Vault-Token: $VAULT_TOKEN" \
                             --request GET \
                             $VAULT_SERVER/v1/secrets/creds/${params.VAULT_PATH}
                    """
                    def checkResponse = sh(script: checkCommand, returnStdout: true).trim()

                    if (checkResponse.contains('"data"')) {
                        echo "Secreto encontrado en ${params.VAULT_PATH}. Realizando patch..."
                        // Realizar patch si el secreto ya existe
                        sh(script: """
                            set +x
                            curl --header "X-Vault-Token: $VAULT_TOKEN" \
                                 --header "Content-Type: application/merge-patch+json" \
                                 --request PATCH \
                                 --data @${payloadFile} \
                                 $VAULT_SERVER/v1/secrets/creds/${params.VAULT_PATH}
                        """)
                    } else {
                        echo "No se encontró secreto en ${params.VAULT_PATH}. Creando nuevo secreto..."
                        // Crear secreto si no existe
                        sh(script: """
                            set +x
                            curl --header "X-Vault-Token: $VAULT_TOKEN" \
                                 --header "Content-Type: application/json" \
                                 --request POST \
                                 --data @${payloadFile} \
                                 $VAULT_SERVER/v1/secrets/creds/${params.VAULT_PATH} 
                        """)
                    }

                    // Limpiar archivos sensibles
                    sh "shred -u ${payloadFile}"
                }
            }
        }
    }
}
