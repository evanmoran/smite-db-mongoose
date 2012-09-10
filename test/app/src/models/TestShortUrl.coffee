SMITE = require 'smite-client'

module.exports = SMITE.model 'TestShortUrl',
  name: type: String, required: false
  url: type: String, require: true, validate: SMITE.lengthMoreThan(0)
  slug: type: String, require: true, validate: SMITE.lengthMoreThan(0)
  shorturl: ->
    "http://sh.rt/#{slug}"