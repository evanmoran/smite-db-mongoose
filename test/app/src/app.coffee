
#───────────────────────────
# Include
#───────────────────────────
_ = require 'underscore'
path = require 'path'
SMITE = require 'smite'

SMITE.db = require '../../../src/SMITE.db-mongoose'

#───────────────────────────
# Configure
#───────────────────────────

settings =
  verbose: false
  minify: false
  srcDirectory: __dirname
  appDirectory: path.join __dirname, '..'
  plugins: db: port: 4004

module.exports = SMITE settings, ->

  #───────────────────────────
  # Test: SMITE.get
  #───────────────────────────

  @app.get '/test/get', (req, res) ->
    res.set 'Content-Type', 'text/plain'
    res.send 'hello world'
