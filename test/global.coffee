#──────────────────────────────────────────────────────
# Globals for mocha testing
#──────────────────────────────────────────────────────

# Include common testing modules
_ = global._ = require 'underscore'
supertest = global.supertest = require 'supertest'

# Include chai
global.chai = chai = require "chai"
global.assert = assert = chai.assert
global.expect = expect = chai.expect

# Extend global object with chai.should
chai.should()

