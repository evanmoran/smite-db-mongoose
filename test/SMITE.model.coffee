module.exports = (SMITE) ->
  describe 'SMITE.model (db-mongoose)', ->

    TestUser = SMITE.models.TestUser
    users =
      Evan: name: 'Evan', height: 3, password: 'evanpassword', male: true
      James: name: 'James', height: 3.12, password: 'jamespassword', male: true
      Laura: name: 'Laura', height: 2.7, password: 'laurapassword', male: false
      Sarah: name: 'Sarah', height: 1.5, password: 'sarahpassword', male: false
      Nick: name: 'Nick', height: 3.1, password: 'nickpassword', male: true

    # Create users before every test
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
      SMITE.db.clear modelNameUser, done
      models = {}

    it 'query (Model)', (done) ->
      query = height: '<': 3
      expected = shared.sortBy [models.Sarah, models.Laura], 'name'
      TestUser.query query, (err, cursor) ->
        expect(err).to.be.null
        cursor.should.be.an 'object'
        result = shared.sortBy (_.map cursor.all(), (v) ->
          expect(v instanceof SMITE.Backbone.Model).to.equal true
          v.toJSON()
        ), 'name'
        result.should.deep.equal expected
        done()

    it 'queryOne (Model)', (done) ->
      query = name: 'Evan'
      expected = models.Evan
      TestUser.queryOne query, (err, model) ->
        expect(err).to.be.null
        model.should.be.an 'object'
        model.toJSON().should.deep.equal expected
        done()

