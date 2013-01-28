module.exports = () ->
  it 'get associated object', (done) ->
    connection.User.create { name: 'John Doe', age: 27 }, (error, user) ->
      return done error if error
      connection.Post.create { title: 'first post', body: 'This is the 1st post.', user_id: user.id }, (error, post) ->
        return done error if error
        post.user (error, record) ->
          return done error if error
          user.should.eql record
          done null
