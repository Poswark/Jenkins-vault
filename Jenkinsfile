pipeline {
    agent any
    
    stages {
        stage('Obtener secreto del Vault') {
            steps {
                script {
                    // Define los secretos y las variables de entorno
                    def secrets = [
                        [path: 'secrets/creds/my-secret-jenkins', engineVersion: 1, secretValues: [
                            [envVar: 'SECRET', vaultKey: 'secret']
                        ]]
                    ]

                    // Configuración opcional, si no la proporcionas se usará la configuración global
                    def configuration = [vaultUrl: 'http://vault:8200',
                                         vaultCredentialId: 'vault-jenkins-role',
                                         engineVersion: 1]

                    // Dentro de este bloque tus credenciales estarán disponibles como variables de entorno
                    withVault([configuration: configuration, vaultSecrets: secrets]) {
                        // Utiliza la variable de entorno para acceder al secreto
                        sh 'echo $SECRET'
                    }
                }
            }
        }
    }
}
