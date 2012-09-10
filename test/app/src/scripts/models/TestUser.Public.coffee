SMITE = require 'smite-client'

module.exports = SMITE.modelview 'TestUser.Public',
  name: type: String, required: true, validate: SMITE.lengthMoreThan(0), readonly: true
  male: type: Boolean
  friendCount: type: Number, required: true, validate: SMITE.lengthMin(0), readonly: true
  fromModel: (m) ->
    @friendCount = m.friendList.size()

  use: (user) ->
    user.customerService
    return 'read' if not user



