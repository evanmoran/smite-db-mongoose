SMITE = require 'smite-client'

module.exports = RequiredModel = SMITE.model 'RequiredModel'
  intDefaulted: type: Number, default: 1
  intRequired:  type: Number,             required: true
  intBoth:      type: Number, default: 1, required: true

