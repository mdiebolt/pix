Shapes = new Meteor.Collection 'shapes'
Answers = new Meteor.Collection 'answers'

Meteor.startup ->
  if Answers.find().count() <= 1
    for word in [
      'cat'
      'dog'
      'bunny'
      'horse'
      'monkey'
      'cow'
      'chicken'
    ]
      Answers.insert
        word: word
        active: false
