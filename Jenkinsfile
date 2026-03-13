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
        stage('Build Swift Project') {
            steps {
                // Menjalankan build tanpa hambatan virtualisasi
                sh 'xcodebuild -scheme News -destination "platform=iOS Simulator,name=iPhone 17 Pro" build'
            }
        }
    }
}