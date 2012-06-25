Shapes = new Meteor.Collection 'shapes'
UserSessions = new Meteor.Collection 'userSessions'
Answers = new Meteor.Collection 'answers'

if Meteor.is_server
  Meteor.startup ->
    if Answers.find().count() is 0
      for word in [
        'Cat'
        'Dog'
        'Bunny'
        'Horse'
        'Monkey'
        'Cow'
        'Chicken'
      ]
        Answers.insert
          word: word
          active: false

    Meteor.users.update {}, {$set: {score: 0}}, {multi: true}
