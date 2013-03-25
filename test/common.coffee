# common modules to test cases

global.async = require 'async'

global.cormo = require '../index'
global.Connection = cormo.Connection
global.Model = cormo.Model
global.connection = undefined

Model.dirty_tracking = Math.floor(Math.random() * 2) isnt 0
Model.eliminate_null = Math.floor(Math.random() * 2) isnt 0

# 'global.should =' does not work because should module override Object.prototype.should
Object.defineProperty global, 'should', value: require 'should'

global.dropModels = (models, callback) ->
  async.forEach models, (model, callback) ->
    return callback null if not model
    model.drop callback
  , callback

global.deleteAllRecords = (models, callback) ->
  async.forEach models, (model, callback) ->
    return callback null if not model
    archive = model.archive
    model.archive = false
    model.deleteAll (error, count) ->
      model.archive = archive
      callback error
  , callback
