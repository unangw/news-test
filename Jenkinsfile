pipeline {
    agent any

    environment {
        PROJECT_PATH = 'News.xcodeproj'
        SCHEME = 'News'
        DESTINATION = 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest'
    }

    stages {
        stage('Check Tools') {
            steps {
                sh 'swift --version'
                sh 'xcode-select -p'
            }
        }

        stage('Linter Check') {
            steps {
                sh "xcrun --sdk iphonesimulator /opt/homebrew/bin/swiftlint lint --reporter html > swiftlint-report.html"

                sh "ls -lh swiftlint-report.html"
            }
        }

        stage('Unit Testing') {
            steps {
                echo "Running Unit Tests..."
                sh """
                xcodebuild test \
                    -project ${PROJECT_PATH} \
                    -scheme ${SCHEME} \
                    -destination '${DESTINATION}' \
                    -only-testing:${SCHEME}Tests
                """
            }
        }

        stage('UI Testing') {
            steps {
                echo "Running UI Tests..."
                sh """
                xcodebuild test \
                    -project ${PROJECT_PATH} \
                    -scheme ${SCHEME} \
                    -destination '${DESTINATION}' \
                    -only-testing:${SCHEME}UITests
                """
            }
        }


        // stage('Build Swift Project') {
        //     steps {
        //         sh 'xcodebuild -scheme News -destination "platform=iOS Simulator,name=iPhone 17 Pro" build'
        //     }
        // }
    }

    post {
        always {
            archiveArtifacts artifacts: 'swiftlint-report.html', allowEmptyArchive: true

            echo "Cleaning up..."
            cleanWs()
        }
    }
}