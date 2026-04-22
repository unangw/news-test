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
        RESOLVED_PACKAGES_PATH = "${PROJECT_PATH}/project.xcworkspace/xcshareddata/swiftpm/Package.resolved"
        SWIFTLINT_EXECUTABLE       = '/opt/homebrew/bin/swiftlint'
    }

    parameters {
        string(
            name: 'BRANCH_NAME', 
            defaultValue: 'main', 
            description: 'Nama branch untuk cache'
        )
        
        choice(
            name: 'BUILD_STRATEGY', 
            choices: ['NATIVE_PERSISTENT', 'JOB_CACHER', 'FRESH_BUILD'], 
            description: 'Choose a strategy for DerivedData'
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

        stage('Configure Environment') {
            steps {
                echo "Installing Ruby gems (fastlane)..."
                sh 'bundle install --jobs 4 --retry 3'
            }
        }

        stage('Build for Testing') {
            steps {
                script {
                    echo "Running Build with strategy: ${params.BUILD_STRATEGY}"
                    
                    if (params.BUILD_STRATEGY == 'NATIVE_PERSISTENT') {
                        sh 'bundle exec fastlane compile_for_testing'
                    } 
                    
                    else if (params.BUILD_STRATEGY == 'JOB_CACHER') {
                        sh "rm -rf ${DD_PATH}"
                        sh "rm -rf ${CLONED_SOURCE_PACKAGES_DIR}"
                        
                        cache(maxCacheSize: 30240, defaultBranch: "master", caches: [
                            arbitraryFileCache(
                                path: "${DD_PATH}",
                                compressionMethod: 'TARGZ',
                                cacheValidityDecidingFile: "${PROJECT_PATH}/project.pbxproj"
                            ),

                            arbitraryFileCache(
                                path: "${CLONED_SOURCE_PACKAGES_DIR}",
                                compressionMethod: 'TARGZ',
                                cacheValidityDecidingFile: "${RESOLVED_PACKAGES_PATH}"
                            )
                        ]) {
                            sh 'bundle exec fastlane compile_for_testing'
                        }
                    } 
                    
                    else {
                        sh "rm -rf ${DD_PATH}"
                        sh "rm -rf ${CLONED_SOURCE_PACKAGES_DIR}"
                        
                        sh 'bundle exec fastlane compile_for_testing'
                    }
                }
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

                // stage('TestPlan Test') {
                //     steps {
                //         echo "Running TestPlan Test via fastlane..."
                //         sh "bundle exec fastlane test_with_testplan JENKINS_VERSION_CODE:'${params.VERSION_CODE}'"
                //     }
                // }

                stage('Unit Testing') {
                    steps {
                        echo "Running unit tests via fastlane (test-without-building)..."
                        sh "bundle exec fastlane ci_unit_tests JENKINS_VERSION_CODE:'${params.VERSION_CODE}'"
                    }
                }

                // stage('UI Testing') {
                //     steps {
                //         echo "Running UI tests via fastlane (sequential runner)..."
                //         sh "bundle exec fastlane ci_ui_tests JENKINS_VERSION_CODE:'${params.VERSION_CODE}'"
                //     }
                // }
            }
        }

        stage('UI Testing') {
            steps {
                echo "Running UI tests via fastlane (sequential runner)..."
                sh "bundle exec fastlane ci_ui_tests JENKINS_VERSION_CODE:'${params.VERSION_CODE}'"
            }
        }

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
