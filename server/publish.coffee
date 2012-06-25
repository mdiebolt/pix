Meteor.publish 'answers', ->
  # Don't publish if the answer if the current one
  Answers.find()

Meteor.publish 'shapes', ->
  Shapes.find()
