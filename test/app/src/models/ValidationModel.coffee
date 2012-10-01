SMITE = require 'smite-client'

str8 = 'eight###'
str9 = 'nine#####'
str10 = 'ten#######'
str11 = 'eleven#####'
str12 = 'twelve######'

module.exports = ValidationModel = SMITE.model 'ValidationModel'
  intMin10:             type: Number, default: 10,      validate: SMITE.min(10)
  intMax10:             type: Number, default: 10,      validate: SMITE.max(10)
  intMoreThan10:        type: Number, default: 11,      validate: SMITE.moreThan(10)
  intLessThan10:        type: Number, default: 9,       validate: SMITE.lessThan(10)
  strLengthMax10:       type: String, default: str10,   validate: SMITE.lengthMax(10)
  strLengthMin10:       type: String, default: str10,   validate: SMITE.lengthMin(10)
  strLengthMoreThan10:  type: String, default: str11,   validate: SMITE.lengthMoreThan(10)
  strLengthLessThan10:  type: String, default: str9,    validate: SMITE.lengthLessThan(10)
  intInEnum:            type: Number, default: 1,       validate: SMITE.inEnum [1,2,3]
  strInList:            type: String, default: 'red',   validate: SMITE.inList ['red', 'green', 'blue']
  intCustomIsInteger:   type: Number, default: 10,      validate: (v) -> if Math.floor(v) != v then "intOnlyInt: {v} is not an integer"

