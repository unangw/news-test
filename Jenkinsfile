pipeline {
    agent any

    environment {
        PROJECT_PATH = 'News.xcodeproj'
        SCHEME = 'News'
        DESTINATION = 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest'
    }

    stages {
        stage('Build for Testing') {
            steps {
                sh "echo bundle exec fastlane build_for_testing"
            }
        }

        stage('Static Analysis & Logic Test') {
            parallel {
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
                            # -derivedDataPath 'build/unit_test_dd' \
                            # -resultBundlePath 'build/unit_test.xcresult'
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
                            # -derivedDataPath 'build/ui_test_dd' \
                            # -resultBundlePath 'build/ui_test.xcresult'
                        """
                    }
                }
            }
        }

        stage('Build for Release') {
            steps {
                sh "echo bundle exec fastlane build_for_release"
            }
        }

        stage('Release') {
            steps {
                sh "echo bundle exec fastlane release_to_firebase"
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'swiftlint-report.html', allowEmptyArchive: true

            echo "Cleaning up..."
            cleanWs()
        }
    }
}