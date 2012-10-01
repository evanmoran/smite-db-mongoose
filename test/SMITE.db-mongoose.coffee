{spawn, exec} = require 'child_process'

launch = (cmd, args=[], options = {}) ->
  console.log "[#{cmd} #{args.join ' '}]"
  app = spawn cmd, args, options
  # app.stdout.pipe(process.stdout)
  # app.stderr.pipe(process.stderr)
  process.on 'exit', ->
    app.kill()
  app

# Launch the database and kill it when the test completes
mode = 'testing'

launch "mongod", ['--config', "db/config/#{mode}.conf"]

# Open test app. This app will connect to the db automatically
SMITE = require './app/src/app.coffee'

describe 'SMITE.db-mongoose', ->
  it 'database connected', ->
    SMITE.db.connection.should.exist

require('../node_modules/smite/test/SMITE.db.coffee')(SMITE)
require('../node_modules/smite/test/SMITE.model.coffee')(SMITE)
