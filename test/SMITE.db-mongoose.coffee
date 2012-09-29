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

TestUser = SMITE.models.TestUser

describe 'SMITE.db-mongoose', ->

  users =
    Evan: name: 'Evan', height: 3, password: 'evanpassword', male: true
    James: name: 'James', height: 3.12, password: 'jamespassword', male: true
    Laura: name: 'Laura', height: 2.7, password: 'laurapassword', male: false
    Sarah: name: 'Sarah', height: 1.5, password: 'sarahpassword', male: false
    Nick: name: 'Nick', height: 3.1, password: 'nickpassword', male: true

  batman = name: 'Batman', height: 5, password: '**********', male: true, id: 'idbatman'

  models = {}

  modelNameUser = 'TestUser'

  beforeEach (done) ->
    done_ = _.after (_.size (users)), done
    models = {}
    # Create all users that aren't missing
    for userName, user of users
      do(userName, user) ->
        # Create them all
        SMITE.db.create modelNameUser, user, (err, model) ->
          models[model.name] = model
          done_()

  afterEach (done) ->
    models = {}
    SMITE.db.drop modelNameUser, done

  it 'connect', (done) ->
    SMITE.db.connect.should.be.a 'function'
    SMITE.db.connect (err, data) ->
      SMITE.db.connection.should.be.an 'object'
      done()

  it 'create', ->
    # Verify beforeEach created them right
    for userName, user of users
      models[userName].should.be.an 'object'
      models[userName].id.should.be.a 'string'
      (shared.subsetEqual users[userName], models[userName]).should.equal true

  it 'read', (done) ->
    SMITE.db.read.should.be.a 'function'
    done_ = _.after (_.size users), -> done()
    for userName, user of users
      do(userName, user) ->
        SMITE.db.read modelNameUser, models[userName].id, (err, dataRead) ->
          dataRead.should.deep.equal models[userName]
          dataRead.should.not.deep.equal users[userName]
          done_()

  it 'read (missing record)', (done) ->
    SMITE.db.read modelNameUser, batman.id, (err, data) ->
      err.should.equal "db.read: record not found (#{modelNameUser}.#{batman.id})\nError: Invalid ObjectId"
      done()

  it 'update', (done) ->

    SMITE.db.update.should.be.a 'function'

    # Update all of their heights to +10 and password appent '_updated'
    done_ = _.after (_.size users), -> done()
    for userName, user of users
      do (userName, user) ->
        SMITE.db.update modelNameUser, models[userName].id, height: user.height + 10, password: user.password + '_updated', (err, dataUpdate) ->
          expected = _.clone models[userName]
          _.extend expected,
            height: user.height + 10
            password: user.password + '_updated'

          dataUpdate.should.deep.equal expected

          # Verify all the heights were updated in the db
          SMITE.db.read modelNameUser, models[userName].id, (err, dataRead) ->
            dataRead.should.deep.equal expected
            done_()

  it 'update (missing record)', (done) ->
    SMITE.db.update modelNameUser, batman.id, {}, (err, data) ->
      err.should.equal "db.update: record not found (#{modelNameUser}.#{batman.id})\nError: Invalid ObjectId"
      done()

  it 'delete', (done) ->

    SMITE.db.delete.should.be.a 'function'

    # Delete all records
    done_ = _.after (_.size users), -> done()
    for userName, user of users
      do (userName, user) ->
        SMITE.db.delete modelNameUser, models[userName].id, (err, arg2) ->
          assert.equal err, null, 'delete should succeed'
          assert.equal arg2, null, 'delete should only return error'

          # Verify they are deleted
          SMITE.db.read modelNameUser, models[userName].id, (err, arg2) ->
            assert.equal arg2, null, 'data should not have been found'

            err.should.equal "db.read: record not found (#{modelNameUser}.#{models[userName].id})"
            done_()

  it 'delete (missing record)', (done) ->
    SMITE.db.delete modelNameUser, batman.id, (err, data) ->
      err.should.equal "db.delete: record not found (#{modelNameUser}.#{batman.id})\nError: Invalid ObjectId"
      done()

  it 'query all', (done) ->
      query = SMITE.query()
      expected = _.values models
      SMITE.db.query modelNameUser, query, (err, cursor) ->
        result = cursor.toArray()
        (shared.sortBy result, 'name').should.deep.equal shared.sortBy(expected, 'name')
        done()

  it 'query =', (done) ->
    query = SMITE.query(name: 'James')
    expected = [models.James]
    SMITE.db.query modelNameUser, query, (err, cursor) ->
      result = cursor.toArray()
      (shared.sortBy result, 'name').should.deep.equal shared.sortBy(expected, 'name')
      done()

  it 'query <', (done) ->
    query = SMITE.query(height: '<': 3)
    expected = [models.Sarah, models.Laura]
    SMITE.db.query modelNameUser, query, (err, cursor) ->
      result = cursor.toArray()
      (shared.sortBy result, 'name').should.deep.equal shared.sortBy(expected, 'name')
      done()

  it 'query <=', (done) ->
    query = SMITE.query(height: '<=': 3)
    expected = [models.Evan, models.Sarah, models.Laura]
    SMITE.db.query modelNameUser, query, (err, cursor) ->
      result = cursor.toArray()
      (shared.sortBy result, 'name').should.deep.equal shared.sortBy(expected, 'name')
      done()

require('./SMITE.db-mongoose.model')(SMITE)