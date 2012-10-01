SMITE = require 'smite-client'

dateNow = new Date

module.exports = BasicModel = SMITE.model 'BasicModel',
  bool: type: Boolean, default: false
  int: type: Number, default: 1, validate: SMITE.range(0, 100)
  real: type: Number, default: 1.1, validate: (v) -> if v < 0 or 100 < v then "real: {v} is not in range [0,100]" else null
  str: type: String, default: "BasicModel default", required: true, trim: true, validate: SMITE.lengthRange(0, 20)
  date: type: Date, default: dateNow


BasicModel.dateNow = dateNow
