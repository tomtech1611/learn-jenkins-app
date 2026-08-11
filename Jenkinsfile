pipeline {
    agent any

    environment {
      NETLIFY_SITE_ID = '1e1f5f54-58a9-4218-b1c6-d4658a8555a9'
    }

    stages {
          
        // stage('Build') {
        //   agent{
        //       docker {
        //         image 'node:18-alpine'
        //         reuseNode true
        //       }
        //   }
        //   steps {
        //       sh '''
        //         ls -la
        //         node --version
        //         npm --version
        //         npm ci
        //         npm run build
        //         ls -la
        //       '''
        //   }
        // }
        

        stage('Run Tests') {
          parallel {
            stage("Unit tests") {
              agent{
                  docker {
                    image 'node:18-alpine'
                    reuseNode true
                  }
              }
              steps {
                  sh '''
                    # Test index.html in build
                    test -f build/index.html

                    # Unit test
                    CI=true npm test
                  '''
              }

              post{
                always {
                  junit 'jest-results/junit.xml'
                }
               }
            }


            stage("E2E") {
              agent{
                  docker {
                    image 'mcr.microsoft.com/playwright:v1.62.0-noble'
                    reuseNode true
                  }
              }
              steps {
                sh '''
                  npm install serve
                  node_modules/.bin/serve -s build &
                  sleep 10
                  npx playwright test --reporter=html
                '''
              }

              post{
                always {
                  publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, icon: '', keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Playwright HTML Report', reportTitles: '', useWrapperFileDirectly: true])
                }
               }
            }
          }
        }

        stage("Deploy") {
            agent{
                docker {
                  image 'node:18-alpine'
                  reuseNode true
                }
            }
            steps {
                sh '''
                  npm install netlify-cli@20.1.1
                  node_modules/.bin/netlify --version
                  echp "Deploying to production. Site ID: $NETLIFY_SITE_ID"
                '''
            }
          
        }
    }
}


