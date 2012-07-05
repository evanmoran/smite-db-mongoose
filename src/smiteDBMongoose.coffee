#──────────────────────────────────────────────────────
# smite-db-mongoose
#──────────────────────────────────────────────────────

_ = require 'underscore'
as = require 'async'
Mongoose = require 'mongoose'
mongooseTimestamps = require './mongooseTimestamps'

#──────────────────────────────────────────────────────
# Export
#──────────────────────────────────────────────────────

module.exports = SMITEDB = {}
SMITEDB.models = {}
SMITEDB.schemas = {}

#──────────────────────────────────────────────────────
# SMITE.db.settings
#──────────────────────────────────────────────────────

SMITEDB.settings = (obj) ->
  if _.isObject(obj)
    _.extend SMITEDB.settings, obj
  SMITEDB.settings

# SMITEDB.settings.url
Object.defineProperty SMITEDB.settings, 'url'
  get: ->
    "mongodb://#{SMITEDB.settings.host}:#{SMITEDB.settings.port}/#{SMITEDB.settings.database}"
# ('mongodb://localhost/my_database');
# SMITEDB.settings.all
Object.defineProperty SMITEDB.settings, 'all'
  get: -> _.clone SMITEDB.settings

# SMITEDB.settings.defaults
_settingDefaults = {}
Object.defineProperty SMITEDB.settings, 'defaults'
  get: ->
    _settingDefaults
  set: (defaults) ->
    _.extend _settingDefaults, defaults
    _.defaults SMITEDB.settings, _settingDefaults

SMITEDB.settings.defaults =
  host: 'localhost'
  port: 4000
  database: 'database'

#───────────────────────────
# Utilities
#───────────────────────────

# _mapMap( {a1:1, a2: 2, a3: 3} , (v) -> v+1 ) => {a1:2, a2:3, a3, 4}
_mapMap = (map, fn) ->
  out = {}
  for k,v of map
    if (result = fn(v, k)) != undefined
      out[k] = result
  out

#──────────────────────────────────────────────────────
# SMITE.db.connect
# Connect to the db using SMITE.db.settings
#──────────────────────────────────────────────────────
SMITEDB.connect = (cb) ->
  SMITEDB.connection = Mongoose.createConnection SMITEDB.settings.url
  cb? SMITEDB.connection



#──────────────────────────────────────────────────────
# SMITE.db.dbModelFromBBModel
# Connect to the db using SMI
#──────────────────────────────────────────────────────

SMITEDB.bbModelFromDBModel = (dbModel, BBModel, BBModelView) ->
  args = dbModel.toObject()
  args.id = args._id
  delete args._id

  # Construct bb model
  bbModel = new BBModel args

  # Convert to model view if necessary
  if BBModelView and BBModelView != BBModel
    return new BBModelView bbModel

  bbModel

  # TODO IMPORTANT: Convert ids to partials of the right type

#──────────────────────────────────────────────────────
# SMITE.db.model
# Get or create the db model object
#──────────────────────────────────────────────────────

# Create db model type from backbone model or backbone model instance
SMITEDB.model = (bbModel) ->

  modelName = bbModel._modelName
  modelBaseName = bbModel._modelBaseName

  console.log 'modelName: ', modelName
  console.log 'modelBaseName: ', modelBaseName
  BBModel = bbModel._model()
  BBBaseModel = bbModel._modelBase()
  console.log 'BBmodel: ', BBModel
  console.log 'BBBaseModel: ', BBBaseModel

  # Succeed with model if it already has been made
  if SMITEDB.models[modelName]?
    return SMITEDB.models[modelName]

  modelDefinition = _mapMap bbModel._modelArgs, (v, attr) ->
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
    # TODO: Support required

  console.log 'modelDefinition: ', modelDefinition
  # Define schema
  SchemaNew = SMITEDB.schemas[modelName] = new Mongoose.Schema(
    modelDefinition
    strict: true
  )

  # SchemaNew.plugin(mongooseTimestamps)

  # Define model on this connection
  ModelNew = SMITEDB.models[modelName] = SMITEDB.connection.model modelName, SchemaNew
  ModelNew


# Those options are functions that are called on each SchemaType. If you want to define options later on, you could access a certain key through the path function:

# Person.path('age').max(400);

# Person.path('meta.birth').set(function (v) {
#   // this is a setter
# });

# Person.path('title').validate(function (v) {
#   return v.length > 50;
# });

#──────────────────────────────────────────────────────
# SMITE.db.create
#──────────────────────────────────────────────────────

SMITEDB.create = (bbModel, options) ->
  console.log 'bbModel: ', bbModel

  # Get the DbModel
  DBModel = SMITEDB.model bbModel

  console.log 'DBModel: ', DBModel
  # console.log 'DBModel.methods: ', DBModel.methods

  # Convert attributes to the format dbModel desires
  console.log 'attributes before: ', bbModel.attributes
  attributes = _mapMap bbModel.attributes, (v, k) ->

    if _.isObject(v) and v.id
      return v.id
    else if k == 'id' or k == 'cid'
      return undefined
    v

  # console.log 'attributes previous: ', bbModel.attributes
  console.log 'attributes after: ', attributes

  # Construct mongoose schema
  dbModel = new DBModel attributes

  console.log 'dbModel (before save): ', dbModel

  # Save with mongoose
  dbModel.save (err, data) ->
    console.log 'data (after save)': data
    console.log 'dbModel (after save): ', dbModel

    if err?
      return options.error?(err, 'error')
    bbModelOut = SMITEDB.bbModelFromDBModel(data, bbModel._model(), bbModel._modelBase())
    options.success?(bbModelOut.toJSON(), 'success')

#──────────────────────────────────────────────────────
# SMITE.db.read
#──────────────────────────────────────────────────────

# SMITEDB.read = (bbModelPartial, options) ->
#   dbModel = SMITEDB.model bbModelPartial._modelName



#   # data = model
#   # textStatus = "success"

#   # Get the DbModel
#   # Create a DbModel with model.attributes (convertion possibly)
#   #
#   as.nextTick ->
#     # model.trigger('sync', 'success', model)
#     options.success model.toJSON(), textStatus


#──────────────────────────────────────────────────────
# SMITE.db.update
#──────────────────────────────────────────────────────

# SMITEDB.create = (model, options) ->
#   data = model
#   textStatus = "success"

#   # Get the DbModel
#   # Create a DbModel with model.attributes (convertion possibly)
#   #
#   as.nextTick ->
#     # model.trigger('sync', 'success', model)
#     options.success model.toJSON(), textStatus

#──────────────────────────────────────────────────────
# SMITE.db.delete
#──────────────────────────────────────────────────────



  # Define a db schema

  # Convert from backboneModel -> dbModel

  # Convert from dbModel -> backboneModel


  # Routes

  #   create
  #     New bb model object
  #     sync

  #   read
  #     Convert from request.body to backbone model
  #     Create
  #     Create model in database
  #     Convert dbModel to bbModel
  #     Send bbModel to client

  #   update
  #     Convert from request.body to backbone model
  #     Apply changes
  #     Update the database
  #     Update the client

  #   delete


  #   new DemoModel()

  #   sync() / save()
  #     fetch and update values if they changed

  #   fetch()
  #     model with id and query db and fill out

  # SMITE.db.




