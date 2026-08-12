pipeline {
    agent any

    environment {
      NETLIFY_SITE_ID = '1e1f5f54-58a9-4218-b1c6-d4658a8555a9'
      NETLIFY_AUTH_TOKEN = credentials('netlify-token')
      REACT_APP_VERSION = '1.2.3'
    }

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
                  publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, icon: '', keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Playwright Local Report', reportTitles: '', useWrapperFileDirectly: true])
                }
               }
            }
          }
        }


        stage("Deploy staging") {
          agent{
              docker {
                image 'mcr.microsoft.com/playwright:v1.62.0-noble'
                reuseNode true
              }
          }

          environment {
            CI_ENVIRONMENT_URL = 'STAGING_URL_WILL_BE_SET'
          }
          
          steps {
            sh '''
              npm install netlify-cli@20.1.1 node-jq
              node_modules/.bin/netlify --version
              echo "Deploying to staging. Site ID: $NETLIFY_SITE_ID"
              node_modules/.bin/netlify status
              node_modules/.bin/netlify deploy --dir=build --json > deploy-output.json
              CI_ENVIRONMENT_URL=$(node_modules/.bin/node-jq -r '.deploy_url' deploy-output.json)
              npx playwright test --reporter=html
            '''
          }

          post{
            always {
              publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, icon: '', keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Stage E2E Report', reportTitles: '', useWrapperFileDirectly: true])
            }
          }
         }

        stage("Deploy prod") {
          agent{
              docker {
                image 'mcr.microsoft.com/playwright:v1.62.0-noble'
                reuseNode true
              }
          }

          environment {
            CI_ENVIRONMENT_URL = 'https://fanciful-conkies-e7082c.netlify.app'
          }

          steps {
            sh '''
              node --version
              npm install netlify-cli@20.1.1
              node_modules/.bin/netlify --version
              echo "Deploying to production. Site ID: $NETLIFY_SITE_ID"
              node_modules/.bin/netlify status
              node_modules/.bin/netlify deploy --dir=build --prod
              npx playwright test --reporter=html
            '''
          }

          post{
            always {
              publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, icon: '', keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Prod E2E Report', reportTitles: '', useWrapperFileDirectly: true])
            }
            }
        }
    }
}


