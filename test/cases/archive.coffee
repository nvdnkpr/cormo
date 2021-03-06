_compareUser = (archive, expected) ->
  archive.model.should.be.equal 'User'
  user = archive.data
  user.should.have.keys 'id', 'name', 'age'
  user.id.should.equal expected.id
  user.name.should.equal expected.name
  user.age.should.equal expected.age

_comparePost = (archive, expected) ->
  archive.model.should.be.equal 'Post'
  post = archive.data
  post.should.have.keys 'id', 'title', 'body', 'user_id'
  post.id.should.equal expected.id
  post.title.should.equal expected.title
  post.body.should.equal expected.body
  post.user_id.should.equal expected.user_id

module.exports = ->
  it 'basic', (done) ->
    users = undefined
    _g.async.waterfall [
      (callback) ->
        _g.connection.manipulate [
          { create_user: id: 'user0', name: 'John Doe', age: 27 }
          { create_user: id: 'user1', name: 'Bill Smith', age: 45 }
          { create_user: id: 'user2', name: 'Alice Jackson', age: 27 }
          { create_user: id: 'user3', name: 'Gina Baker', age: 32 }
          { create_user: id: 'user4', name: 'Daniel Smith', age: 8 }
        ], callback
      (id_to_record_map, callback) ->
        users = [0..4].map (i) -> id_to_record_map['user'+i]
        _g.connection._Archive.where callback
      (records, callback) ->
        records.should.have.length 0
        _g.connection.User.find(users[3].id).delete callback
      (count, callback) ->
        count.should.be.equal 1
        _g.connection._Archive.where callback
      (records, callback) ->
        records.should.have.length 1
        _compareUser records[0], users[3]
        _g.connection.User.delete age:27, callback
      (count, callback) ->
        count.should.be.equal 2
        _g.connection._Archive.where callback
      (records, callback) ->
        records.should.have.length 3
        records.sort (a, b) -> if a.data.id < b.data.id then -1 else 1
        users.sort (a, b) -> if a.id < b.id then -1 else 1
        _compareUser records[0], users[0]
        _compareUser records[1], users[2]
        _compareUser records[2], users[3]
        callback null
    ], done

  it 'by integrity', (done) ->
    users = undefined
    posts = undefined
    _g.async.waterfall [
      (callback) ->
        _g.connection.manipulate [
          { create_user: id: 'user0', name: 'John Doe', age: 27 }
          { create_user: id: 'user1', name: 'Bill Smith', age: 45 }
          { create_post: id: 'post0', user_id: 'user0', title: 'first post', body: 'This is the 1st post.' }
          { create_post: id: 'post1', user_id: 'user0', title: 'second post', body: 'This is the 2st post.' }
          { create_post: id: 'post2', user_id: 'user1', title: 'another post', body: 'This is a post by user1.' }
        ], callback
      (id_to_record_map, callback) ->
        users = [0..0].map (i) -> id_to_record_map['user'+i]
        posts = [0..1].map (i) -> id_to_record_map['post'+i]
        _g.connection._Archive.where callback
      (records, callback) ->
        records.should.have.length 0
        _g.connection.User.find(users[0].id).delete callback
      (count, callback) ->
        count.should.be.equal 1
        _g.connection._Archive.where callback
      (records, callback) ->
        records.should.have.length 3
        records.sort (a, b) ->
          return -1 if a.model < b.model
          return 1 if a.model > b.model
          if a.data.id < b.data.id then -1 else 1
        posts.sort (a, b) -> if a.id < b.id then -1 else 1
        _compareUser records[2], users[0]
        _comparePost records[0], posts[0]
        _comparePost records[1], posts[1]
        callback null
    ], done
