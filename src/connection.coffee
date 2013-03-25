EventEmitter = require('events').EventEmitter
Model = require './model'
_ = require 'underscore'
async = require 'async'

_bindDomain = (fn) -> if d = process.domain then d.bind fn else fn

##
# Manages connection to a database
# @uses ConnectionAssociation
# @uses ConnectionManipulate
class Connection extends EventEmitter
  ##
  # Default connection
  # @property defaultConnection
  # @type Connection
  # @static
  # @see Connection::constructor

  ##
  # Indicates the adapter associated to this connection
  # @property _adapter
  # @type AdapterBase
  # @private
  # @see Connection::constructor

  ##
  # Model lists using this connection.
  # Maps from model name to model class
  # @property models
  # @type StringMap<Class<Model>>
  # @see Connection::constructor

  ##
  # Creates a connection
  # @param {String} adapater_name
  # @param {Object} settings connection settings & adapter specific settings
  # @param {Boolean} [settings.is_default=true] Connection.defaultConnection will be set to this if true
  # @see MySQLAdapter::connect
  # @see MongoDBAdapter::connect
  # @see PostgreSQLAdapter::connect
  # @see SQLite3Adapter::connect
  # @see RedisAdapter::connect
  constructor: (adapter_name, settings) ->
    if settings.is_default isnt false
      Connection.defaultConnection = @

    @connected = false
    @models = {}
    @_pending_associations = []
    @_schema_changed = false

    @_adapter = require(__dirname + '/adapters/' + adapter_name) @
    @_adapter.connect settings, _bindDomain (error) =>
      if error
        @_adapter = null
        @emit 'error', error
        return
      @connected = true
      @emit 'connected'

  ##
  # Creates a model class
  # @param {String} name
  # @param {Object} schema
  # @return {Class<Model>}
  model: (name, schema) ->
    return Model.newModel @, name, schema

  _waitingForConnection: (object, method, args) ->
    return false if @connected
    @once 'connected', ->
      method.apply object, args
    return true

  _waitingForApplyingSchemas: (object, method, args) ->
    return false if not @_applying_schemas and not @_schema_changed
    @once 'schemas_applied', ->
      method.apply object, args
    if not @_applying_schemas
      @applySchemas()
    return true

  _checkArchive: ->
    for model, modelClass of @models
      if modelClass.archive and not modelClass._connection.models.hasOwnProperty '_Archive'
        class _Archive extends Model
          @connection modelClass._connection
          @column 'model', String
          @column 'data', Object

  ##
  # Applies schemas
  # @param {Function} [callback]
  # @param {Error} callback.error
  # @see AdapterBase::applySchema
  applySchemas: (callback) ->
    return callback? null if not @_schema_changed

    @_applyAssociations()

    if not @_applying_schemas
      @_applying_schemas = true

      @_checkArchive()

      callAdapter = =>
        async.forEach Object.keys(@models), (model, callback) =>
          modelClass = @models[model]
          return callback null if not modelClass._schema_changed
          @_adapter.applySchema model, (error) ->
            modelClass._schema_changed = false if not error
            callback error
        , _bindDomain (error) =>
          @_applying_schemas = false
          @_schema_changed = false
          @emit 'schemas_applied'
          callback? error
      return if @_waitingForConnection @, callAdapter, arguments
      callAdapter()
    else
      callback? null

  ##
  # Logs
  # @param {String} model
  # @param {String} type
  # @param {Object} data
  log: (model, type, data) ->

_use = (file) ->
  MixClass = require "./connection/#{file}"
  _.extend Connection, MixClass
  _.extend Connection::, MixClass::
_use 'association'
_use 'manipulate'

Model._Connection = Connection

module.exports = Connection
