SMITE = require 'smite-client'

module.exports = SMITE.model 'TestUser',
    name: type: String, required: true, validate: SMITE.lengthMoreThan(0)
    password: type: String, required: true
    email: type: String
    height: type: Number
    male: type: Boolean
    friendList: type: 'User.Collection'

    # use: (user) ->
    #   if user.role == 'admin'
    #     'all'
    #   else if @id == user.id
    #     'all'
    #   else if @friends.includes(user)
    #     'read'

    # @abilities
    #   user.role == 'admin', 'all'
    #   user.role == 'service'



