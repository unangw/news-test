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

    stages {

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

                stage('Unit Testing') {
                    steps {
                        echo "Running unit tests via fastlane (test-without-building)..."
                        sh 'bundle exec fastlane ci_unit_tests'
                    }
                }

                stage('UI Testing') {
                    steps {
                        echo "Running UI tests via fastlane (sequential runner)..."
                        sh 'bundle exec fastlane ci_ui_tests'
                    }
                }
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

            // .xcresult is a directory bundle; plain globs like build/*.xcresult/** often match nothing in archiveArtifacts.
            // Produce zip archives (ditto preserves bundle structure on macOS agents) and archive explicit tree patterns.
            sh '''
                set +e
                for name in unit_test ui_test; do
                    SRC="${WORKSPACE}/build/${name}.xcresult"
                    if [ -d "$SRC" ]; then
                        rm -f "${WORKSPACE}/${name}.xcresult.zip"
                        /usr/bin/ditto -c -k --sequesterRsrc --keepParent "$SRC" "${WORKSPACE}/${name}.xcresult.zip" && \
                            echo "Packed ${name}.xcresult -> ${name}.xcresult.zip"
                    else
                        echo "No ${name}.xcresult at $SRC (stage may have been skipped or failed before tests)."
                    fi
                done
                exit 0
            '''
            archiveArtifacts artifacts: 'unit_test.xcresult.zip,ui_test.xcresult.zip', allowEmptyArchive: true

            echo "Cleaning up environment..."
            sh 'xcrun simctl shutdown all || true'

            cleanWs()
        }
    }
}
