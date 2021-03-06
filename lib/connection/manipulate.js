// Generated by CoffeeScript 1.6.2
(function() {
  var ConnectionManipulate, async, console_future, inflector, types;

  async = require('async');

  console_future = require('../console_future');

  inflector = require('../inflector');

  types = require('../types');

  ConnectionManipulate = (function() {
    function ConnectionManipulate() {}

    ConnectionManipulate.prototype._manipulateCreate = function(model, data, callback) {
      model = inflector.camelize(model);
      if (!this.models[model]) {
        return callback(new Error("model " + model + " does not exist"));
      }
      model = this.models[model];
      return model.create(data, {
        skip_log: true
      }, function(error, record) {
        return callback(error, record);
      });
    };

    ConnectionManipulate.prototype._manipulateDelete = function(model, data, callback) {
      model = inflector.camelize(model);
      if (!this.models[model]) {
        return callback(new Error("model " + model + " does not exist"));
      }
      model = this.models[model];
      return model.where(data)["delete"]({
        skip_log: true
      }, function(error, count) {
        return callback(error);
      });
    };

    ConnectionManipulate.prototype._manipulateDeleteAllModels = function(callback) {
      var _this = this;

      return async.forEach(Object.keys(this.models), function(model, callback) {
        if (model === '_Archive') {
          return callback(null);
        }
        model = _this.models[model];
        return model.where()["delete"]({
          skip_log: true
        }, function(error, count) {
          return callback(error);
        });
      }, callback);
    };

    ConnectionManipulate.prototype._manipulateDropModel = function(model, callback) {
      model = inflector.camelize(model);
      if (!this.models[model]) {
        return callback(new Error("model " + model + " does not exist"));
      }
      model = this.models[model];
      return model.drop(callback);
    };

    ConnectionManipulate.prototype._manipulateDropAllModels = function(callback) {
      var _this = this;

      return async.forEach(Object.keys(this.models), function(model, callback) {
        model = _this.models[model];
        return model.drop(callback);
      }, callback);
    };

    ConnectionManipulate.prototype._manipulateFind = function(model, data, callback) {
      model = inflector.camelize(inflector.singularize(model));
      if (!this.models[model]) {
        return callback(new Error("model " + model + " does not exist"));
      }
      model = this.models[model];
      return model.where(data).exec({
        skip_log: true
      }, function(error, records) {
        return callback(error, records);
      });
    };

    ConnectionManipulate.prototype._manipulateConvertIds = function(id_to_record_map, model, data) {
      var column, property, record, _ref, _results;

      model = inflector.camelize(model);
      if (!this.models[model]) {
        return;
      }
      model = this.models[model];
      _ref = model._schema;
      _results = [];
      for (column in _ref) {
        property = _ref[column];
        if (property.record_id && data.hasOwnProperty(column)) {
          record = id_to_record_map[data[column]];
          if (record) {
            _results.push(data[column] = record.id);
          } else {
            _results.push(void 0);
          }
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    ConnectionManipulate.prototype.manipulate = function(commands, callback) {
      var _this = this;

      this.log('<conn>', 'manipulate', commands);
      return console_future.execute(callback, function(callback) {
        var id_to_record_map;

        id_to_record_map = {};
        if (!Array.isArray(commands)) {
          commands = [commands];
        }
        return async.forEachSeries(commands, function(command, callback) {
          var data, id, key, model;

          if (typeof command === 'object') {
            key = Object.keys(command);
            if (key.length === 1) {
              key = key[0];
              data = command[key];
            } else {
              key = void 0;
            }
          } else if (typeof command === 'string') {
            key = command;
          }
          if (!key) {
            return callback(new Error('invalid command: ' + JSON.stringify(command)));
          }
          if (key.substr(0, 7) === 'create_') {
            model = key.substr(7);
            id = data.id;
            delete data.id;
            _this._manipulateConvertIds(id_to_record_map, model, data);
            return _this._manipulateCreate(model, data, function(error, record) {
              if (error) {
                return callback(error);
              }
              if (id) {
                id_to_record_map[id] = record;
              }
              return callback(null);
            });
          } else if (key.substr(0, 7) === 'delete_') {
            model = key.substr(7);
            return _this._manipulateDelete(model, data, callback);
          } else if (key === 'deleteAll') {
            return _this._manipulateDeleteAllModels(callback);
          } else if (key.substr(0, 5) === 'drop_') {
            model = key.substr(5);
            return _this._manipulateDropModel(model, callback);
          } else if (key === 'dropAll') {
            return _this._manipulateDropAllModels(callback);
          } else if (key.substr(0, 5) === 'find_') {
            model = key.substr(5);
            id = data.id;
            delete data.id;
            if (!id) {
              return callback(null);
            }
            return _this._manipulateFind(model, data, function(error, records) {
              if (error) {
                return callback(error);
              }
              id_to_record_map[id] = records;
              return callback(null);
            });
          } else {
            return callback(new Error('unknown command: ' + key));
          }
        }, function(error) {
          return callback(error, id_to_record_map);
        });
      });
    };

    return ConnectionManipulate;

  })();

  module.exports = ConnectionManipulate;

}).call(this);
