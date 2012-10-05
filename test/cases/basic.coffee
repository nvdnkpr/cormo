should = require 'should'

module.exports = (models) ->
  it 'create one', (done) ->
    user = new models.User()
    user.name = 'John Doe'
    user.age = 27
    user.should.have.property 'name', 'John Doe'
    user.should.have.property 'age', 27
    done null

  it 'initialize in constructor', (done) ->
    user = new models.User name: 'John Doe', age: 27
    user.should.have.property 'name', 'John Doe'
    user.should.have.property 'age', 27
    done null

  it 'build method', (done) ->
    user = models.User.build name: 'John Doe', age: 27
    user.should.have.property 'name', 'John Doe'
    user.should.have.property 'age', 27
    done null

  it 'add a new record to the database', (done) ->
    user = new models.User name: 'John Doe', age: 27
    user.save (error) ->
      return done error if error
      user.should.have.property 'id'
      done null

  it 'create method', (done) ->
    models.User.create { name: 'John Doe', age: 27 }, (error, user) ->
      return done error if error
      user.should.have.property 'id'
      done null

  it 'find a record', (done) ->
    user = new models.User name: 'John Doe', age: 27
    user.save (error) ->
      return done error if error

      models.User.find user.id, (error, record) ->
        return done error if error
        should.exist record
        record.should.be.an.instanceOf models.User
        record.should.have.property 'id', user.id
        record.should.have.property 'name', user.name
        record.should.have.property 'age', user.age
        done null