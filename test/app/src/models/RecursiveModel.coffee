SMITE = require 'smite-client'

module.exports = RecursiveModel = SMITE.model 'RecursiveModel'
  model: type: 'RecursiveModel',  default: null
  str: type: String, default: "RecursiveModel default"
