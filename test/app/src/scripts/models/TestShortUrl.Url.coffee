SMITE = require 'smite-client'

module.exports = SMITE.modelview 'TestShortUrl.Url',
  url: type: String, require: true, validate: SMITE.lengthMoreThan(0), readonly: true
  shorturl: type: String, required: true, validate: SMITE.lengthMoreThan(0), readonly: true
  fromModel: (m) ->
    @url = m.url
    @shorturl = "http://sh.rt/#{m.shorturl()}"