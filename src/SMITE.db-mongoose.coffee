# SMITE.db-mongoose
# ===============================================================

_ = require 'underscore'
as = require 'async'
Mongoose = require 'mongoose'
mongooseTimestamps = require './mongooseTimestamps'

# Export
# ----------------------------------------------------------------
SMITE = {}
module.exports = SMITE.db = {}
SMITE.db.models = {}
SMITE.db.schemas = {}

# Use
# ----------------------------------------------------------------
# Plugin system for smite

SMITE.db.use = (_SMITE, settings = {}) ->

  # Pass through SMITE functions
  for attr in ['version', 'error', 'warn', 'info', 'debug', 'throw', 'settings', 'models', 'query']
    SMITE[attr] = _SMITE[attr]

  _.defaults settings,
    host: 'localhost'
    port: 4000
    database: 'database'
  if not settings.url?
    settings.url = "mongodb://#{settings.host}:#{settings.port}/#{settings.database}"

  # Store settings
  SMITE.db.settings = settings

  # Return our namespace within SMITE
  'db'

# SMITE.db.connect
# ----------------------------------------------------------------
# Connect to the db using SMITE.db.settings

SMITE.db.connect = (cb) ->
  SMITE.db.connection = Mongoose.createConnection SMITE.db.settings.url
  cb? null, SMITE.db.connection

# SMITE.db.drop
# ----------------------------------------------------------------
# Drop the database

SMITE.db.drop = (modelName, cb = ->) ->
  typo 'db.drop: expected one or two arguments',

  throw 'db.drop: expected one or two arguments' unless (arguments.length == 1) or (arguments.length == 2)
  throw 'db.drop: String expected for first argument (modelName)' unless _.isString modelName
  throw 'db.drop: Function expected for second argument (cb)' unless _.isFunction cb

  Model = SMITE.db.model modelName
  return cb('db.drop: model name not found') unless Model?

  # Delete the collection
  Model.remove {}, cb

# Helpers
# ----------------------------------------------------------------

# ### _bbJsonFromDBJson
SMITE.db._bbJsonFromDBJson = (jsonDB) ->
  jsonBB = _.clone jsonDB
  # id should be a string
  if jsonDB._id?
    jsonBB.id = SMITE.db._bbIDFromDBID jsonDB._id
    # no _id or __v fields
    delete jsonBB._id
  delete jsonBB.__v
  jsonBB

# ### _dbJsonFromBBJson
SMITE.db._dbJsonFromBBJson = (jsonBB) ->
  jsonDB = _.clone jsonBB
  # id should be a hex number
  if jsonDB.id?
    jsonDB._id = SMITE.db._dbIDFromBBID jsonDB._id
    # no .id field
    delete jsonDB.id
  jsonDB

# ### _dbIDFromBBID
SMITE.db._dbIDFromBBID = (idBB) ->
  # Hex string to integer
  Mongoose.Types.ObjectId.fromString(idBB)

# ### _dbIDFromBBID
SMITE.db._bbIDFromDBID = (idDB) ->
  String(idDB)

# SMITE.db.model
# ----------------------------------------------------------------
# Get or create the db model object

# Create db model type from backbone model or backbone model instance
SMITE.db.model = (modelName) ->

  BBModel = SMITE.models[modelName]
  throw "SMITE.db.model: model name not found #{modelName}" unless BBModel?

  # Succeed with model if it already has been made
  if SMITE.db.models[modelName]?
    return SMITE.db.models[modelName]

  modelDefinition = _mapMap BBModel._modelArgs, (v, attr) ->
    out = _.clone v
    # If type is a model change it into an id
    if _.isString v?.type
      out.ref = v.type
      out.type = Mongoose.Schema.ObjectId

    # Validation must return true when it succeeds
    if v.validate?
      origValidate = v.validate
      out.validate = (v) -> !origValidate v
    out

    # TODO: Support trim model option
    # TODO: Support toUppercase, toLowercase
    # TODO: Support readonly option
    # TODO: Support required option

  # Define schema
  SchemaNew = SMITE.db.schemas[modelName] = new Mongoose.Schema(
    modelDefinition
    strict: true
  )

  # TODO add createAt and updateAt
  # SchemaNew.plugin(mongooseTimestamps)

  # Define model on this connection
  ModelNew = SMITE.db.models[modelName] = SMITE.db.connection.model modelName, SchemaNew
  ModelNew


# SMITE.db.create
# ----------------------------------------------------------------

SMITE.db.create = (modelName, modelData, cb) ->
  SMITE.throw 'db.create: expected three arguments' unless arguments.length == 3
  SMITE.throw 'db.create: first argument expected String (modelName)' unless _.isString(modelName) and modelName != ''
  SMITE.throw 'db.create: second argument expected Object (modelData)' unless  _.isObject(modelData)
  SMITE.throw 'db.create: third argument expected Function (cb)' unless  _.isFunction(cb)

  # Get or create the schema
  DBModel = SMITE.db.model modelName
  return cb('db.create: db schema could not be found') unless DBModel?

  # Instance the schema
  dbModel = new DBModel modelData
  return cb('db.create: dbModel instance could not be created') unless dbModel?

  # Save with mongoose
  dbModel.save (err, data) ->
    # Fail on errors
    return cb(err) if err?

    # Convert json on success
    cb err, SMITE.db._bbJsonFromDBJson(data.toJSON())

# SMITE.db.read
# -----------------------------------------------------------

SMITE.db.read = (modelName, modelId, cb = ->) ->
  SMITE.throw 'db.read: first argument expected String (modelName)' unless  _.isString(modelName) and modelName != ''
  SMITE.throw 'db.read: second argument expected String (modelId)' unless  _.isString(modelId) and modelId != ''
  SMITE.throw 'db.read: third argument expected Function (cb)' unless  _.isFunction(cb)

  DBModel = SMITE.db.model modelName
  return cb('db.create: db schema could not be found') unless DBModel?

  # Instance the schema
  DBModel.findById modelId, (err, data) ->
    errMessage = if err then "\n#{err}" else ''
    return cb("db.read: record not found (#{modelName}.#{modelId})#{errMessage}") if err or not data?
    cb err, SMITE.db._bbJsonFromDBJson(data.toJSON())

# SMITE.db.update
# -----------------------------------------------------------
SMITE.db.update = (modelName, modelId, modelData, cb = ->) ->
  SMITE.throw 'db.update: first argument expected String (modelName)' unless  _.isString(modelName) and modelName != ''
  SMITE.throw 'db.update: second argument expected String (modelId)' unless  _.isString(modelId) and modelId != ''
  SMITE.throw 'db.update: third argument expected Object (modelData)' unless  _.isObject(modelData)
  SMITE.throw 'db.update: fourth argument expected Function (cb)' unless  _.isFunction(cb)

  DBModel = SMITE.db.model modelName
  return cb('db.create: db schema could not be found') unless DBModel?

  # Find and update it
  dbModelData = SMITE.db._dbJsonFromBBJson modelData
  DBModel.findByIdAndUpdate modelId, dbModelData, (err, data) ->
    return cb("db.update: record not found (#{modelName}.#{modelId})\n#{err}") if err

    cb err, SMITE.db._bbJsonFromDBJson(data.toJSON())

# SMITE.db.delete
# -----------------------------------------------------------

SMITE.db.delete = (modelName, modelId, cb = ->) ->
  SMITE.throw 'db.delete: first argument expected String (modelName)' unless  _.isString(modelName) and modelName != ''
  SMITE.throw 'db.delete: second argument expected String (modelId)' unless  _.isString(modelId) and modelId != ''
  SMITE.throw 'db.delete: third argument expected Function (cb)' unless  _.isFunction(cb)

  DBModel = SMITE.db.model modelName
  return cb('db.create: db schema could not be found') unless DBModel?

  DBModel.findByIdAndRemove modelId, (err) ->
    return cb("db.delete: record not found (#{modelName}.#{modelId})\n#{err}") if err
    cb err

# SMITE.db.query
# ----------------------------------------------------------------
SMITE.db.query = (modelName, queryfu, cb = ->) ->

  DBModel = SMITE.db.model modelName
  return cb('db.create: db schema could not be found') unless DBModel?

  # Create query
  queryMongo = queryfu.toMongo()

  # Query db through mongoose
  # TODO: Possibly this should use mongodb queryies instead?
  DBModel.find queryMongo, (err, dbResults) ->
    bbResults = _.map dbResults, (result) -> SMITE.db._bbJsonFromDBJson(result.toJSON())
    cursor = SMITE.query.listCursor bbResults
    return cb("db.query: query failed (#{modelName}.#{modelId})\n#{err}") if err
    cb err, cursor

# Utilities
# ----------------------------------------------------------------

# _mapMap( {a1:1, a2: 2, a3: 3} , (v) -> v+1 ) => {a1:2, a2:3, a3, 4}
_mapMap = (map, fn) ->
  out = {}
  for k,v of map
    if (result = fn(v, k)) != undefined
      out[k] = result
  out

_isSMITEModelType = (any) ->
  any._modelArgs? and any._modelName?