pipeline {
    agent {
        node {
            label 'ROBOSHOP'  
        }
    }
    environment {
        def appVersion = "" // make the appVersion variable globally available
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

