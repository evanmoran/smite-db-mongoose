
#───────────────────────────
# Include
#───────────────────────────
_ = require 'underscore'
path = require 'path'
SMITE = require 'smite'

#───────────────────────────
# Configure
#───────────────────────────

plugins = {}

# Figure out app dir. Hack it so process can be run from smite-db-mongoose/test/app or /smite-db-mongoose
appDir = process.cwd()
if appDir.indexOf('test/app') == -1
  appDir = path.join appDir, 'test/app'

# Figure out srcDir
dbDir = process.cwd()
if dbDir.indexOf('test/app') != -1
  dbDir = path.join dbDir, '../..'

plugins["#{dbDir}/src/SMITE.db-mongoose"] =
  port: 4000

settings =
  verbose: false
  minify: false
  srcDirectory: __dirname
  appDirectory: path.join __dirname, '..'
  plugins: plugins

module.exports = SMITE settings, ->

  #───────────────────────────
  # Test: SMITE.get
  #───────────────────────────

  @app.get '/test/get', (req, res) ->
    res.set 'Content-Type', 'text/plain'
    res.send 'hello world'
