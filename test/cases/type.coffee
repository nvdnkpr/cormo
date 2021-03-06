module.exports = () ->
  it 'number', (done) ->
    data = [
      [ '30', 30 ]
      [ '12.8', 12.8 ]
      [ '8a', null ]
      [ 'abc', null ]
    ]
    _g.async.forEach data, (item, callback) ->
        _g.connection.Type.create { number: item[0] }, (error, type) ->
          if item[1] is null
            should.exist error
            error.message.should.be.equal "'number' is not a number"
            return callback null
          return callback error if error
          type.number.should.be.equal item[1]
          _g.connection.Type.find type.id, (error, type) ->
            return callback error if error
            type.number.should.be.equal item[1]
            callback null
      , (error) ->
        done error

  it 'integer', (done) ->
    data = [
      [ '30', 30 ]
      [ '9876543210', null ]
      [ '12.8', null ]
      [ '8a', null ]
      [ 'abc', null ]
    ]
    _g.async.forEach data, (item, callback) ->
        _g.connection.Type.create { int_c: item[0] }, (error, type) ->
          if item[1] is null
            should.exist error
            error.message.should.be.equal "'int_c' is not an integer"
            return callback null
          return callback error if error
          type.int_c.should.be.equal item[1]
          _g.connection.Type.find type.id, (error, type) ->
            return callback error if error
            type.int_c.should.be.equal item[1]
            callback null
      , (error) ->
        done error

  it 'date', (done) ->
    data = [
      [ '2012/10/12 21:32:54', new Date('2012/10/12 21:32:54').getTime() ]
      [ '2012-09-11 20:31:53', new Date('2012/09/11 20:31:53').getTime() ]
      [ '2012/11/02', new Date('2012/11/02 00:00:00').getTime() ]
      [ '2012/10/12 34:00:00', null ]
      [ '2012/13/01', null ]
      [ new Date('2013/01/12 03:42:21').getTime(), new Date('2013/01/12 03:42:21').getTime() ]
    ]
    _g.async.forEach data, (item, callback) ->
        _g.connection.Type.create { date: item[0] }, (error, type) ->
          if item[1] is null
            should.exist error
            error.message.should.be.equal "'date' is not a date"
            return callback null
          return callback error if error
          new should.Assertion(type.date).be.an.instanceof Date
          type.date.getTime().should.be.equal item[1]
          _g.connection.Type.find type.id, (error, type) ->
            return callback error if error
            new should.Assertion(type.date).be.an.instanceof Date
            type.date.getTime().should.be.equal item[1]
            callback null
      , (error) ->
        done error

  it 'boolean', (done) ->
    data = [
      [ true, true ]
      [ false, false ]
      [ 'str', null ]
      [ 5, null ]
    ]
    _g.async.forEach data, (item, callback) ->
        _g.connection.Type.create { boolean: item[0] }, (error, type) ->
          if item[1] is null
            should.exist error
            error.message.should.be.equal "'boolean' is not a boolean"
            return callback null
          return callback error if error
          type.boolean.should.be.equal item[1]
          _g.connection.Type.find type.id, (error, type) ->
            return callback error if error
            type.boolean.should.be.equal item[1]
            callback null
      , (error) ->
        done error

  it 'object', (done) ->
    data = [
      [ '30', '30' ]
      [ 30, 30 ]
      [ true, true ]
      [ false, false ]
      [ {a: 5, b: ['oh']}, {a: 5, b: ['oh']} ]
    ]
    _g.async.forEach data, (item, callback) ->
        _g.connection.Type.create { object: item[0] }, (error, type) ->
          return callback error if error
          if typeof item[1] is 'object'
            type.object.should.be.eql item[1]
          else
            type.object.should.be.equal item[1]
          _g.connection.Type.find type.id, (error, type) ->
            return callback error if error
            if typeof item[1] is 'object'
              type.object.should.be.eql item[1]
            else
              type.object.should.be.equal item[1]
            callback null
      , (error) ->
        done error

  it 'array of integer', (done) ->
    data = [
      [ [9,'30'], [9,30] ]
      [ 9, null ]
      [ [9,'12.8'], null ]
    ]
    _g.async.forEach data, (item, callback) ->
        _g.connection.Type.create { int_array: item[0] }, (error, type) ->
          if item[1] is null
            should.exist error
            error.message.should.be.equal "'int_array' is not an array"
            return callback null
          return callback error if error
          type.int_array.should.be.eql item[1]
          _g.connection.Type.find type.id, (error, type) ->
            return callback error if error
            type.int_array.should.be.eql item[1]
            callback null
      , (error) ->
        done error
