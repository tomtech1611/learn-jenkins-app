pipeline {
    agent any

    stages {
        stage('Build') {
          agent{
              docker {
                image 'node:18-alpine'
                reuseNode true
              }
          }
          steps {
              sh '''
                ls -la
                node --version
                npm --version
                npm ci
                npm run build
                ls -la
              '''
          }
        }

        stage("Test") {
          agent{
              docker {
                image 'node:18-alpine'
                reuseNode true
              }
          }
          steps {
            sh '''
              # check in build has index.html
              ls -la build | grep index.html

              # run test
              npm run test
            '''
          }
        }
    }
}


# test build has index.html
# npm run test