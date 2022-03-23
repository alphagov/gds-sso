#!/usr/bin/env groovy

library("govuk")

def rubyVersions = ["2.7"]
def gemfiles = ["rails_5", "rails_6", "rails_7"]

node {
  govuk.buildProject(
    beforeTest: {
      stage("Trap signon processes") {
        sh('trap "./stop_signon.sh" EXIT')
      }

      stage("Remove lock files") {
        sh("rm -f Gemfile.lock")
        sh("rm -f gemfiles/*.gemfile.lock")
      }

      stage("Clean up git") {
        sh("git clean -fxde /tmp")
      }

      stage("Start signon") {
        sh("./start_signon.sh")
      }
    },
    overrideTestTask: {
      for (rubyVersion in rubyVersions) {
        for(gemfile in gemfiles) {
          stage("Test with ruby $rubyVersion and gemfile $gemfile") {
            govuk.setEnvar("RBENV_VERSION", rubyVersion)
            govuk.setEnvar("BUNDLE_GEMFILE", "gemfiles/${gemfile}.gemfile")
            govuk.bundleGem()
            govuk.runTests()
          }
        }
      }
    },
    afterTest: {
      sh("unset RBENV_VERSION")
      sh("unset BUNDLE_GEMFILE")
    }
  )
}
