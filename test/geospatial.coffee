require './common'

_dbs =
  mysql:
    database: 'test'
  mongodb:
    database: 'test'

Object.keys(_dbs).forEach (db) ->
  describe 'geospatial-' + db, ->
    before (done) ->
      global.connection = new Connection db, _dbs[db]

      if Math.floor Math.random() * 2
        # using CoffeeScript extends keyword
        class Place extends Model
          @column 'name', 'string'
          @column 'location', 'geopoint'
      else
        # using Connection method
        Place = connection.model 'Place',
          name: String
          location: cormo.types.GeoPoint

      dropModels [Place], done

    beforeEach (done) ->
      deleteAllRecords [connection.Place], done

    after (done) ->
      dropModels [connection.Place], done

    require('./cases/geospatial')()

_dbs_not =
  sqlite3:
    database: __dirname + '/test.sqlite3'
  sqlite3_memory: {}
  postgresql:
    database: 'test'

Object.keys(_dbs_not).forEach (db) ->
  describe 'geospatial-' + db, ->
    before ->
      global.connection = new Connection db, _dbs_not[db]

    it 'does not support geospatial', (done) ->
      ( ->
        Place = connection.model 'Place',
          name: String
          location: cormo.types.GeoPoint
      ).should.throw 'this adapter does not support GeoPoint'
      done null