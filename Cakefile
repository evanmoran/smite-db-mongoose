
#───────────────────────────
# Include
#───────────────────────────

fs = require 'fs'
cp = require 'child_process'
util = require 'util'
_ = require 'underscore'
{spawn, exec} = require 'child_process'
# as = require 'async'

#───────────────────────────
# Utilities
#───────────────────────────

optionsMode = (options, modes = ['production', 'staging', 'testing', 'development']) ->
  optionsCombine options, modes

optionsCombine = (options, choices) ->
  for choice in choices
    if options[choice]
      break
  choice

captialize = (str) ->
  "#{str.charAt(0).toUpperCase()}#{str.slice(1)}"

# envFromObject({FOO:'bar', FOO2:'bar2'}) => 'FOO=bar FOO2=bar2 '
envFromObject = (obj) ->
  out = ""
  for k,v of obj
    out += "#{k}=#{v} "
  out

#───────────────────────────
# Logging
#───────────────────────────

code =
  bold: '\u001b[0;1m'
  red: '\u001b[31m'
  blue: '\u001b[34m'
  magenta: '\u001b[35m'
  yellow: '\u001b[33m'
  cyan: '\u001b[36m'
  white: '\u001b[37m'
  reset: '\u001b[0m'
  warn: '\u001b[33m'
  error: '\u001b[31m'
  info: '\u001b[36m'

log = (message, color, explanation) -> console.log code[color] + message + code.reset + ' ' + (explanation or '')
error = (message, explanation) -> log message, 'red', explanation
info = (message, explanation) -> log message, 'cyan', explanation
warn = (message, explanation) -> log message, 'yellow', explanation

launch = (cmd, args=[], options, callback = ->) ->
  # Options is optional (may be cb instead)
  if _.isFunction options
    callback = options
    options = {}

  # Info output command being run
  info "[#{envFromObject options?.env}#{cmd} #{args.join ' '}]"

  # cmd = which(cmd) if which
  app = spawn cmd, args, options
  app.stdout.pipe(process.stdout)
  app.stderr.pipe(process.stderr)
  app.on 'exit', (status) -> callback() if status is 0

#───────────────────────────
# Options
#───────────────────────────

option '-v', '--verbose',     'Enable verbose output mode'
option '-d', '--development', 'Use development mode'
option '-p', '--production',  'Use production mode'
option '-s', '--staging',     'Use staging mode'
option '-t', '--testing',     'Use testing mode'

#───────────────────────────
# Tasks
#───────────────────────────

task "test", "Run unit tests", ->
  exec "NODE_ENV=testing mocha", (err, output) ->
    throw err if err
    console.log output

task "test:watch", "Watch unit tests", ->
  launch 'mocha', ['--reporter', 'min', '--watch']

#───────────────────────────
# Node Tasks
#───────────────────────────

task 'node', 'Launch node', (options) ->
  mode = optionsMode options
  if mode == 'development'
    launch "node-dev", ['src/app.js'] # , env: NODE_ENV: mode
  else
    launch "node", ['src/app.js']  #, env: NODE_ENV: mode

#───────────────────────────
# DB Tasks
#───────────────────────────

task 'db', 'Launch database', (options) ->
  mode = optionsMode options
  console.log 'mode is: ', mode
  launch "mongod", ['--config', "db/config/#{mode}.conf"]

task 'db:console', 'Launch db interactive console', (options) ->
  mode = optionsMode options
  console.log 'mongo localhost:4000/database'
