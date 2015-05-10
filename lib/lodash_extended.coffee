_ = require 'lodash'

module.exports = _.mixin
  fill: (destination, source) ->
    _.each source, (value) ->
      destination.push value
      return
    destination
  batch: (items, batchSize) ->
    if batchSize <= 0
      throw new Exception('batch must be > 0 in _.batch')
    batched = []
    while items.length
      batched.push items.splice(0, Math.ceil(batchSize))
    batched
  log: (returnValue) ->
    console = window.console
    console.log.apply console, arguments
    returnValue
  not: ->
    cb = _.createCallback.apply(_, arguments)
    ->
      !cb.apply(null, arguments)
  clamp: (value, minimum, maximum) ->
    if maximum == null
      maximum = Number.MAX_VALUE
    if maximum < minimum
      swap = maximum
      maximum = minimum
      minimum = swap
    Math.max minimum, Math.min(value, maximum)
