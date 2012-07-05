# https://github.com/bnoguchi/mongoose-types

mongoose = require 'mongoose'

module.exports = (schema, options) ->
  schema.add
    createdAt: Date
    updatedAt: Date

  schema.pre 'save', (next) ->
    if !@createdAt
      @createdAt = @updatedAt = new Date
    else
      @updatedAt = new Date
    next()

