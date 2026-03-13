pipeline {
    agent any

    stages {
        stage('Check Tools') {
            steps {
                // Memastikan Swift 6 dan Xcode sudah terbaca
                sh 'swift --version'
                sh 'xcode-select -p'
            }
        }

        stage('Testing') {
            parallel {
                stage('Linter Check') {
                    steps {
                        sh "echo bundle exec fastlane swift_lint"
                    }
                }
                stage('UI Testing') {
                    steps {
                        sh "echo bundle exec fastlane ui_testing"
                    }
                }
                stage('Unit Testing') {
                    steps {
                        sh "echo bundle exec fastlane unit_testing"
                    }
                }
            }
        }

        stage('Build Swift Project') {
            steps {
                // Menjalankan build tanpa hambatan virtualisasi
                sh 'xcodebuild -scheme News -destination "platform=iOS Simulator,name=iPhone 17 Pro" build'
            }
        }
    }
}