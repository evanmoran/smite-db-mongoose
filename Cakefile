
#───────────────────────────
# Include
#───────────────────────────

fs = require 'fs'
path = require 'path'
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

# mkdir: make a directory if it doesn't exist (mkdir -p)
mkdir = (dir, cb) ->
  fs.stat dir, (err, stats) ->
    if err?.code == 'ENOENT'
      mkdir path.dirname(dir), (err) ->
        if err
          cb(err)
        else
          fs.mkdir dir, cb
    else if stats.isDirectory
      cb(null)
    else
      throw "mkdir: #{dir} is not a directory"
      cb({code:"NotDir"})

nativeTrim = String.prototype.trim
trim = (str, characters = '\\s') ->
  if !str
    return '';
  if (arguments.length == 1) and nativeTrim
    return nativeTrim.call str
  String(str).replace(new RegExp('\^' + characters + '+|' + characters + '+$', 'g'), '')

parseDBConfig = (path, cb) ->
  fs.readFile path, 'utf8', (err, data) ->
    if err
      cb err, null
    else
      config = {}
      lines = data.split "\n"
      pattern = /\s*(\w+)\s*=\s*([^#]*)/i
      for line in lines
        match = line.match pattern
        if match
          config[match[1]] = trim match[2]
      cb null, config

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
  parseDBConfig "db/config/#{mode}.conf", (err, config) ->
    startDB = -> launch "mongod", ['--config', "db/config/#{mode}.conf"]
    if config?.dbpath
      mkdir config.dbpath, startDB
     else
       startDB()

task 'db:console', 'Launch db interactive console', (options) ->
  mode = optionsMode options
  console.log 'mongo localhost:4000/database'

