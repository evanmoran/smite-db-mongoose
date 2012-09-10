module.exports = (SMITE) ->
  describe 'SMITE.rest', ->

    ShortUrl = require ('./app/src/scripts/models/ShortUrl')

    it 'get', (done) ->

      url1 = new ShortUrl name: 'url1', url:'http://long/name/url1'
      SMITE.db.create 'ShortUrl', url1.toJSON(), (err, model) ->

        supertest(SMITE.app)
          .get("/api/ShortUrl/#{model.id}")
          # TODO: Should this be `text/json`?
          .expect('Content-Type', 'application/json; charset=utf-8')
          .expect(SMITE.HTTP.SuccessOk)
          .end (err, res) ->
            throw err if err
            json = JSON.parse res.res.text
            (shared.subsetEqual url1.toJSON(), json).should.be.true
          done()

    it 'get (missing record)', (done) ->
      supertest(SMITE.app)
        .get("/api/ShortUrl/idmissing")
        # .expect('Content-Type', 'text/html')
        .expect(SMITE.HTTP.ClientErrorNotFound)
        .end (err, res) ->
          throw err if err
          res.res.text.should.equal 'db.read: record not found (ShortUrl.idmissing)'
          done()

    it 'create', (done) ->
      url2 = new ShortUrl name: 'url2', url:'http://long/name/url2'
      supertest(SMITE.app)
        .post("/api/ShortUrl")
        .send(url2.toJSON())
        .expect('Content-Type', 'application/json; charset=utf-8')
        .expect(SMITE.HTTP.SuccessCreated)
        .end (err, res) ->
          throw err if err
          json = JSON.parse res.res.text

          SMITE.db.read 'ShortUrl', json.id, (err, data) ->
            expect(err).to.be.null
            data.should.deep.equal json
            done()

    it 'create (not a model)', (done) ->
      supertest(SMITE.app)
        .post("/api/NotAModel")
        .expect('Content-Type', 'text/plain')
        .expect(SMITE.HTTP.ClientErrorNotFound)
        .end (err, res) ->
          throw err if err
          done()

    it 'create (with id)', (done) ->
      supertest(SMITE.app)
        .post("/api/ShortUrl")
        .send(name: 'HasId', url: 'http://has/id', id: 'idshouldnotexist')
        .expect(SMITE.HTTP.ClientErrorBadRequest)
        .end (err, res) ->
          throw err if err
          done()

    it 'update', (done) ->
      model = new ShortUrl name: 'url3', url:'http://long/name/url3'
      SMITE.db.create 'ShortUrl', model.toJSON(), (err, data) ->
        supertest(SMITE.app)
          .put("/api/ShortUrl/#{data.id}")
          .send(name:'url3_changed', url: data.url)
          .expect('Content-Type', 'application/json; charset=utf-8')
          .expect(SMITE.HTTP.SuccessOk)
          .end (err, res) ->
            throw err if err
            json = JSON.parse res.res.text
            json.should.deep.equal id: data.id, url: data.url, name: 'url3_changed'
            done()

    it 'update (partial)', (done) ->

      model = new ShortUrl name: 'url3', url:'http://long/name/url3'
      SMITE.db.create 'ShortUrl', model.toJSON(), (err, data) ->
        supertest(SMITE.app)
          .put("/api/ShortUrl/#{data.id}")
          .send(name:'url3_changed') # no url!
          .expect('Content-Type', 'application/json; charset=utf-8')
          .expect(SMITE.HTTP.SuccessOk)
          .end (err, res) ->
            throw err if err
            json = JSON.parse res.res.text
            json.should.deep.equal id: data.id, url: data.url, name: 'url3_changed'
            done()

    it 'delete', (done) ->
      model = new ShortUrl name: 'url4', url:'http://long/name/url4'
      SMITE.db.create 'ShortUrl', model.toJSON(), (err, data) ->
        supertest(SMITE.app)
          .del("/api/ShortUrl/#{data.id}")
          .expect(SMITE.HTTP.SuccessNoContent)
          .end (err, res) ->
            throw err if err
            SMITE.db.read 'ShortUrl', data.id, (err, data2) ->
              err.should.equal "db.read: record not found (ShortUrl.#{data.id})"
              done()

      # supertest(SMITE.app)
      #   .post("/api/ShortUrl/#{url1.id}")
      #   .send(url1.toJSON())
      #   .expect('Content-Type', 'application/json; charset=utf-8')
      #   .expect(SMITE.HTTP.SuccessOk)
      #   .end (err, res) ->
      #     throw err if err
      #     json = JSON.parse res.res.text

      #     SMITE.db.read 'ShortUrl', json.id, (err, data) ->
      #       expect(err).to.be.null
      #       data.should.deep.equal json
      #       done()

