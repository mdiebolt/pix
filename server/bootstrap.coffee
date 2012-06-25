Shapes = new Meteor.Collection 'shapes'
UserSessions = new Meteor.Collection 'userSessions'

if Meteor.is_server
  Meteor.startup ->
    Meteor.users.update {}, {$set: {score: 0}}, {multi: true}
