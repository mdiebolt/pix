Meteor.methods
  checkGuess: (guess, userId) ->
    if Meteor.is_server
      user = Meteor.users.findOne(userId)
      answer = Answers.findOne {word: guess}

      points = -5

      if answer.active
        points = 10

      Meteor.users.update {_id: userId}
        $set:
          score: user.score + points

      # TODO set new active word
      Answers.update {},
        $set:
          active: false
        {multi: true}
