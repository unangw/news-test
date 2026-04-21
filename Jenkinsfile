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
        string(
            name: 'BRANCH_NAME', 
            defaultValue: 'main', 
            description: 'Nama branch untuk cache'
        )
        
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

        // stage('Build for Testing') {
        //     steps {
        //         echo "Compiling application and test targets via fastlane..."
        //         sh 'bundle exec fastlane compile_for_testing'
        //     }
        // }

        // stage('Build for Testing') {
        //     steps {
        //         script {
        //             echo "🔍 Checking cache status BEFORE build..."
        //             sh """
        //                 echo "=== Pre-Build Cache Check ==="
        //                 if [ -d "${DD_PATH}" ]; then
        //                     echo "✅ DerivedData exists (cache restored or previous build)"
        //                     echo "Size: \$(du -sh ${DD_PATH} | cut -f1)"
        //                     echo "Files: \$(find ${DD_PATH} -type f | wc -l) files"
        //                     echo "Modified: \$(stat -f "%Sm" ${DD_PATH} 2>/dev/null || stat -c "%y" ${DD_PATH})"
        //                 else
        //                     echo "❌ No DerivedData (will build from scratch)"
        //                 fi
        //                 echo "================================"
        //             """
                    
        //             def startTime = System.currentTimeMillis()
                    
        //             cache(
        //                 maxCacheSize: 10240, 
        //                 defaultBranch: params.BRANCH_NAME,
        //                 caches: [
        //                     arbitraryFileCache(
        //                         path: "${DD_PATH}",
        //                         cacheValidityDecidingFile: "${PROJECT_PATH}/project.pbxproj",
        //                         compressionMethod: 'TARGZ'
        //                     )
        //                 ]
        //             ) {
        //                 echo "🔨 Running compile_for_testing..."
        //                 sh 'bundle exec fastlane compile_for_testing'
        //             }
                    
        //             def duration = (System.currentTimeMillis() - startTime) / 1000
        //             echo "⏱️ Total build time: ${duration} seconds"
                    
        //             echo "🔍 Checking cache status AFTER build..."
        //             sh """
        //                 echo "=== Post-Build Cache Check ==="
        //                 if [ -d "${DD_PATH}" ]; then
        //                     echo "✅ DerivedData exists"
        //                     echo "Size: \$(du -sh ${DD_PATH} | cut -f1)"
        //                     echo "Files: \$(find ${DD_PATH} -type f | wc -l) files"
        //                 else
        //                     echo "❌ No DerivedData (build failed?)"
        //                 fi
        //                 echo "================================"
        //             """
        //         }
        //     }
        // }

        stage('Build for Testing') {
            steps {
                echo "Compiling application and test targets with caching..."
                
                cache(
                    maxCacheSize: 10240, 
                    defaultBranch: params.BRANCH_NAME,
                    caches: [
                         arbitraryFileCache(
                            path: "${DD_PATH}",
                            cacheValidityDecidingFile: "${PROJECT_PATH}/project.pbxproj",
                            compressionMethod: 'TARGZ'
                        )
                    ]
                ) {
                    echo "🔨 Running compile_for_testing..."
                    sh 'bundle exec fastlane compile_for_testing'
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
