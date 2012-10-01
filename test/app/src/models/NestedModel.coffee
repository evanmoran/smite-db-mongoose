SMITE = require 'smite-client'

module.exports = NestedModel = SMITE.model 'NestedModel'
  model: type: 'NestedModel',  default: null
  model2: type: 'NestedModel',  default: null
  str: type: String, default: "NestedModel default"
