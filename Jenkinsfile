pipeline {
    agent {
        node {
            label 'ROBOSHOP'  
        }
    }
    environment {
        def appVersion = "" // make the appVersion variable globally available
        acc_id = "875926135141"
        project = "roboshop"
        component = "catalogue"
    }
    options {
        disableConcurrentBuilds() // to queue a build when there's already an executing build of the pipeline 
        timeout(time: 15, unit: 'MINUTES')
    }
    // parameters {
    //     string(name: 'PERSON', defaultValue: 'Mr Jenkins', description: 'Who should I say hello to?')
    //     text(name: 'BIOGRAPHY', defaultValue: '', description: 'Enter some information about the person')
    //     booleanParam(name: 'DEPLOY', defaultValue: true, description: 'Toggle this value')
    //     choice(name: 'CHOICE', choices: ['One', 'Two', 'Three'], description: 'Pick something')
    //     password(name: 'PASSWORD', defaultValue: 'SECRET', description: 'Enter a password')
    // }

// when executing this pipeline jenkins will check this label
// then it will launch the agent and the build the pipeline in that agent
// Build 
    stages {
        stage('Read version'){
            steps {
                script {
                    // To execute this block you must install pipeline utility plugins
                    def packageJson = readJSON file: 'package.json' // Read the package.json file 
                    // Extracts the version property 
                    // def appVersion = packageJson.version // local variable
                    appVersion = packageJson.version 
                    echo "The application version is: ${appVersion}"
                    // This is local variable and only be available in this stage
                }
            }
        }
        stage('Build') {
            steps {
                script {
                    sh """
                        echo "Version: ${appVersion}"
                    """
                }
            }
        }
        stage ('Install dependencies') {
            steps {
                script {
                    sh """
                        npm install 
                    """
                }
            }
        }
        stage('Unit tests') {
            steps {
                script {
                    sh """
                        npm test
                    """
                }
            }
        }
        stage('SonarQube Analysis') {
            steps {
                // 'My SonarQube Server' must match the name configured in Jenkins system settings
                withSonarQubeEnv('sonar-server') { // name configured in the system
                    sh "${tool 'sonar-8'}/bin/sonar-scanner" // name configured in the tools
                }
            }
        }
        stage('SonarQube Quality Gate') {
            steps {
                timeout(time:10, unit: 'Minutes') {
                    script {
                        def qg = waitForQualityGate() // Pauses pipeline 
                        if (aq.status != 'OK') {
                            error "Pipeline aborted: ${qg.status}"
                        }
                    }
                }
            }
        }
        stage('Check Dependabot Alerts') {
            steps {
                withCredentials([string(credentialsId: 'github-token', variable: 'GH_TOKEN')]) {
                    sh '''
                        set -e

                        REPO="daws-90s/catalogue"

                        curl -s -L \
                        -H "Accept: application/vnd.github+json" \
                        -H "Authorization: Bearer ${GH_TOKEN}" \
                        -H "X-GitHub-Api-Version: 2026-03-10" \
                        "https://api.github.com/repos/${REPO}/dependabot/alerts?state=open" \
                        -o alerts.json

                        echo "---- Open Dependabot Alerts ----"
                        jq -r '.[] | "\\(.number)\\t\\(.security_vulnerability.severity)\\t\\(.dependency.package.name)\\t\\(.security_advisory.ghsa_id)"' alerts.json

                        HIGH_CRITICAL_COUNT=$(jq '[.[] | select(.security_vulnerability.severity == "high" or .security_vulnerability.severity == "critical")] | length' alerts.json)

                        echo "High/Critical alert count: ${HIGH_CRITICAL_COUNT}"

                        if [ "$HIGH_CRITICAL_COUNT" -gt 0 ]; then
                            echo "❌ Found ${HIGH_CRITICAL_COUNT} High/Critical severity dependency alert(s). Failing build."
                            exit 1
                        else
                            echo "✅ No High/Critical dependency alerts found."
                        fi
                    '''
                }
            }
        }
        // stage('Docker Build') {
        //     steps {
        //         script {
        //             sh """
        //                 docker build -t catalogue:${appVersion} .
        //             """
        //         }
        //     }
        // }
        stage('Docker Build') {
            steps {
                script {
                    // in this block we get aws authentication 
                    withAWS(credentials: 'aws-creds', region: 'us-east-1') {
                        sh """
                            aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${acc_id}.dkr.ecr.us-east-1.amazonaws.com
                            docker build -t ${acc_id}.dkr.ecr.us-east-1.amazonaws.com/${project}/${component}:${appVersion} .
                            docker push ${acc_id}.dkr.ecr.us-east-1.amazonaws.com/${project}/${component}:${appVersion}
                        """
                    }
                }
            }
        }
        stage('Test') {
            steps {
                script {
                    sh """
                        echo "Testing"
                    """
                }
            }
        }
        stage('Deploy') {
            when {
                // Evaluates the boolean paramerter directly 
                expression { "${params.DEPLOY}" == "true" }
            }
            // input {
            //     message "Should we continue?"
            //     ok "Yes, we should."
            //     submitter "alice,bob"
            //     parameters {
            //         string(name: 'PERSON', defaultValue: 'Mr Jenkins', description: 'Who should I say hello to?')
            //     }
            // } 
            // For manual approval we will add the above block
            steps {
                script {
                    sh """
                        echo "Deploying"
                    """
                }
            }
        }
    }

    post {
        always {
            echo 'I will always say hello again!'
        }
        success {
            echo 'I will run when success'
        }
        failure {
            echo 'I will run when it is failed'
        }
    }
}

