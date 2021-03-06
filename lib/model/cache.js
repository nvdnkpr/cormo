// Generated by CoffeeScript 1.6.2
(function() {
  var ModelCache, tableize;

  tableize = require('../inflector').tableize;

  ModelCache = (function() {
    function ModelCache() {}

    ModelCache._loadFromCache = function(key, refresh, callback) {
      var _this = this;

      if (refresh) {
        return callback('error');
      }
      return this._connection._connectRedisCache(function(error, redis) {
        if (error) {
          return callback(error);
        }
        key = 'CC.' + tableize(_this._name) + ':' + key;
        return redis.get(key, function(error, data) {
          if (error || (data == null)) {
            return callback('error');
          }
          return callback(null, JSON.parse(data));
        });
      });
    };

    ModelCache._saveToCache = function(key, ttl, data, callback) {
      var _this = this;

      return this._connection._connectRedisCache(function(error, redis) {
        if (error) {
          return callback(error);
        }
        key = 'CC.' + tableize(_this._name) + ':' + key;
        return redis.setex(key, ttl, JSON.stringify(data), function(error) {
          return callback(error);
        });
      });
    };

    ModelCache.removeCache = function(key, callback) {
      var _this = this;

      return this._connection._connectRedisCache(function(error, redis) {
        if (error) {
          return callback(error);
        }
        key = 'CC.' + tableize(_this._name) + ':' + key;
        return redis.del(key, function(error) {
          return callback(null);
        });
      });
    };

    return ModelCache;

  })();

  module.exports = ModelCache;

}).call(this);
