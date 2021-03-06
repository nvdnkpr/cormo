require './common'

_dbs =
  mysql:
    database: 'test'
  mongodb:
    database: 'test'
  sqlite3:
    database: __dirname + '/test.sqlite3'
  sqlite3_memory: {}
  postgresql:
    database: 'test'

Object.keys(_dbs).forEach (db) ->
  describe 'association-' + db, ->
    before (done) ->
      _g.connection = new _g.Connection db, _dbs[db]

      if Math.floor Math.random() * 2
        # using CoffeeScript extends keyword
        class User extends _g.Model
          @column 'name', String
          @column 'age', Number
          @hasMany 'posts'
          @hasOne 'computer'

        class Post extends _g.Model
          @column 'title', String
          @column 'body', String
          @belongsTo 'user'
          @hasMany 'comments', type: 'Post', foreign_key: 'parent_post_id'
          @belongsTo 'parent_post', type: 'Post'

        class Computer extends _g.Model
          @column 'brand', String
          @belongsTo 'user'
      else
        # using Connection method
        User = _g.connection.model 'User',
          name: String
          age: Number

        Post = _g.connection.model 'Post',
          title: String
          body: String

        Computer = _g.connection.model 'Computer',
          brand: String

        User.hasMany Post
        Post.belongsTo User

        Post.hasMany Post, as: 'comments', foreign_key: 'parent_post_id'
        Post.belongsTo Post, as: 'parent_post'

        User.hasOne Computer
        Computer.belongsTo User

      _g.dropModels [User, Post, Computer], done

    beforeEach (done) ->
      _g.deleteAllRecords [_g.connection.User, _g.connection.Post, _g.connection.Computer], done

    after (done) ->
      _g.dropModels [_g.connection.User, _g.connection.Post, _g.connection.Computer], done

    describe '#hasMany', ->
      require('./cases/association_has_many')()
    describe '#hasOne', ->
      require('./cases/association_has_one')()
    describe '#belongsTo', ->
      require('./cases/association_belongs_to')()
    describe '#as', ->
      require('./cases/association_as')()
    describe '#fetch', ->
      require('./cases/association_fetch')()
    describe '#include', ->
      require('./cases/association_include')()
