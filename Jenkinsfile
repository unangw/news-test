pipeline {
    agent any

    options {
        parallelsAlwaysFailFast()
    }

    environment {
        LC_ALL                      = 'en_US.UTF-8'
        LANG                        = 'en_US.UTF-8'
        FASTLANE_SKIP_UPDATE_CHECK  = 'true'
        FASTLANE_HIDE_CHANGELOG     = 'true'

        PROJECT_PATH = 'News.xcodeproj'
        SCHEME       = 'News'
        DESTINATION  = 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest'

        DD_PATH = "${WORKSPACE}/build/derived_data"
        CLONED_SOURCE_PACKAGES_DIR = "${WORKSPACE}/build/SourcePackages"
        SWIFTLINT_EXECUTABLE       = '/opt/homebrew/bin/swiftlint'
    }

    parameters {
        booleanParam(
            name: 'FORCE_CLEAN', 
            defaultValue: false, 
            description: 'Check this box to delete the DerivedData/Cache folder before starting the build.'
        )

        string (
            name: 'VERSION_NAME',
            description: 'Version Name:',
            defaultValue: '4.40.0',
            trim: true
        )
        
      string (
        name: 'VERSION_CODE',
        description: 'Version Code:',
        defaultValue: '4400001',
        trim: true
      )
    }

    stages {

        stage('Cleanup Cache') {
            when { 
                expression { params.FORCE_CLEAN == true } 
            }
            steps {
                echo "FORCE_CLEAN is true. Cleaning workspace..."
                // Adjust this path to match your actual DerivedData location
                sh "rm -rf ${DD_PATH}"
            }
        }

        stage('Configure Environment') {
            steps {
                echo "Installing Ruby gems (fastlane)..."
                sh 'bundle install --jobs 4 --retry 3'
            }
        }

        stage('Build for Testing') {
            steps {
                echo "Compiling application and test targets via fastlane..."
                sh 'bundle exec fastlane compile_for_testing'
            }
        }

        stage('Testing') {
            parallel {

                stage('Linter Check') {
                    steps {
                        echo "Running SwiftLint via fastlane..."
                        sh 'bundle exec fastlane ci_lint'
                    }
                }

                stage('TestPlan Test') {
                    steps {
                        echo "Running TestPlan Test via fastlane..."
                        sh 'bundle exec fastlane test_with_testplan'
                    }
                }

                // stage('Unit Testing') {
                //     steps {
                //         echo "Running unit tests via fastlane (test-without-building)..."
                //         sh 'bundle exec fastlane ci_unit_tests'
                //     }
                // }

                // stage('UI Testing') {
                //     steps {
                //         echo "Running UI tests via fastlane (sequential runner)..."
                //         sh 'bundle exec fastlane ci_ui_tests'
                //     }
                // }
            }
        }

        // stage('UI Testing') {
        //             steps {
        //                 echo "Running UI tests via fastlane (sequential runner)..."
        //                 sh 'bundle exec fastlane ci_ui_tests'
        //             }
        //         }

        stage('Build for Release') {
            steps {
                sh 'bundle exec fastlane build_for_release'
            }
        }

        stage('Release') {
            steps {
                sh 'bundle exec fastlane release_to_firebase'
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'swiftlint-report.html', allowEmptyArchive: true
            archiveArtifacts artifacts: 'fastlane/build/*.xcresult/**', allowEmptyArchive: true

            echo "Cleaning up environment..."
            sh 'xcrun simctl shutdown all || true'

            // Disable cleanWs() because delete cache is setup to configurable
            // cleanWs()
        }
    }
}
