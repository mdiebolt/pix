Meteor.methods
  checkGuess: (guess, userId) ->
    if Meteor.is_server
      user = Meteor.users.findOne(userId)
      answer = Answers.findOne {word: guess.trim().toLowerCase()}

      points = -5

      if answer.active
        points = 10

        # TODO combine this update with the new random assignment
        # active: if user._id is newAnswerId then true else false
        Answers.update {},
          $set:
            active: false
          {multi: true}

        newAnswerId = Answers.find().fetch().rand()._id

        Answers.update {_id: newAnswerId}
          $set: active: true

        Session.set('time_remaining', 60.seconds)

        Shapes.remove {}

      Meteor.users.update {_id: userId}
        $set:
          score: user.score + points
