_ = require 'underscore'


module.exports =

  #──────────────────────────────────────────────────────
  # itShouldBeAFunction
  #──────────────────────────────────────────────────────

  itShouldBeAFunction: (fn) ->
    it 'should be a function', ->
      fn.should.be.a 'function'

  subsetEqual: (small, big) ->
    throw 'subsetEqual: arguments are not objects' unless _.isObject(small) and _.isObject(big)
    for k,v of small
      return false unless _.isEqual small[k], big[k]
    true

  sortBy: (arrayOfObjects, key) ->
    # for obj in arrayOfObjects
    throw 'sortBy: Array expected for first argument (arrayOfObjects)' unless _.isArray arrayOfObjects
    throw 'sortBy: String expected for second argument (key)' unless _.isString key
    arrayOfObjects.sort (left, right) ->
      return 0 if left[key] == right[key]
      return -1 if left[key] < right[key]
      1
  toStringShallow: (thing, indent = '') ->

    if _.isNull thing
      return 'null'
    if _.isUndefined thing
      return 'undefined'
    if _.isString thing
      return "'#{thing}'"
    if _.isNumber thing
      return "#{thing}"
    if (_.isFunction thing)
      return thing.toString()

    if _.isArray thing
      str = "[array #{thing.length}\n]"
      return str
    if _.isObject thing
      str = "{object}\n"
      return str
    # Function, regexp
    return thing.toString()

  toStringDeep: (thing, indent = '') ->
    recurse = (thing2) ->
      arguments.callee thing2, (indent + '  ')

    if _.isNull thing
      return 'null'
    if _.isUndefined thing
      return 'undefined'
    if _.isString thing
      return "'#{thing}'"
    if _.isNumber thing
      return "#{thing}"
    if (_.isFunction thing)
      return thing.toString()

    if _.isArray thing
      str = "[\n"
      comma = ''
      for v in thing
        str += "#{comma}#{indent}#{recurse v}"
        comma = ',\n'
      str += "\n#{indent}]"
      return str
    if _.isObject thing
      str = "{\n"
      comma = ''
      for k, v of thing
        str += "#{comma}#{indent}#{recurse k}: #{recurse v}"
        comma = ',\n'
      str += "\n#{indent}}"
      return str
    # Function, regexp
    return thing.toString()
