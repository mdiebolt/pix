Shapes = new Meteor.Collection 'shapes'
UserSessions = new Meteor.Collection 'userSessions'

if Meteor.is_server
  Meteor.startup ->
    ;
