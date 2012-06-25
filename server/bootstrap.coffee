Shapes = new Meteor.Collection 'shapes'
Answers = new Meteor.Collection 'answers'

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
