###
Copyright 2015 Kinvey, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
###

# Package modules.
async  = require 'async'
Docker = require 'dockerode'

# Local modules.
tester = require './tester.coffee'

# Configure.
docker = new Docker()

# Helper to start a container with the specified Docker image.
startDockerContainer = (imageName, callback) ->
  docker.pull imageName, (err, stream) ->
    if err? then callback err
    else docker.modem.followProgress stream, (err) ->
      if err? then callback err
      else docker.createContainer { Image: imageName }, (err, container) ->
        if err? then callback err
        else container.start { PublishAllPorts: true }, (err) ->
          # TODO Fix - this is required somehow.
          setTimeout ->
            callback err
          , 1000

# Utility to set-up test suite.
setup = (options, callback) ->
  options.quiet = true # Mute tester warnings.

  # Run.
  async.series [
    # Set-up Docker containers.
    startDockerContainer.bind null, 'kinvey/blrunner:latest'

    # Set-up tester.
    tester.createClient.bind tester, options
  ], (err, results) ->
    # Pass the tester client back to the test suite.
    callback err, results?[1]

# Utility to teardown test suite.
teardown = (options, callback) ->
  callback() # Do nothing.

# Exports.
module.exports = { setup: setup, teardown: teardown }