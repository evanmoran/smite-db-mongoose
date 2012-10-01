SMITE = require 'smite-client'

module.exports = MethodsModel = SMITE.model 'MethodsModel'
  int: type: Number, default: 1, required: true
  str: type: String, default: 'MethodsModel default', required: true
  # Methods should be passed through
  method: ->
    @str + @int
