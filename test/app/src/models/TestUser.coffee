SMITE = require 'smite-client'

module.exports = SMITE.model 'TestUser',
    name: type: String, required: true, validate: SMITE.lengthMoreThan(0)
    male: type: Boolean
    height: type: Number
    password: type: String, required: true
    email: type: String
    phoneNumber: type: String

    #friends: type: 'TestUser.Friend.Collection'