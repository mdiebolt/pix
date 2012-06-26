# Template helper functions
templateHelpers =
  'canvas drawingClass': ->
    if drawing()
      "class=drawing"
    else
      ''

  'header disabled': ->
    if Shapes.find().count() > 0 then '' else 'disabled=disabled'

  'instructions time': ->
    (Session.get('time_remaining') / 1000).toFixed(1)

  'instructions word': ->
    if answer = Answers.findOne {active: true}
      answer.word.capitalize()

  'palette colors': ->
    [
      'red'
      'green'
      'blue'
      'black'
      'white'
      'purple'
      'orange'
      'gray'
      'pink'
    ].inject "", (memo, color) ->
      if Color(Session.get('color')).toHex() is Color(color).toHex()
        memo += "<span class='active' style='background-color:#{Color(color).toHex()}'></span> "
      else
        memo += "<span style='background-color:#{Color(color).toHex()}'></span> "

  'players list': ->
    users = Meteor.users.find().fetch()

    (users.inject '<table><th>Name</th><th>Points</th>', (memo, player) ->
      memo += "<tr><td>#{player.name || player.emails.first()}</td><td>#{player.score}</td></tr>"
    ) + '</table>'

  'size brushSize': ->
    parseInt(Session.get('size'))

  'tools toolList': ->
    ['rectangle', 'circle'].inject '', (memo, tool) ->
      active = if tool is Session.get('tool') then 'active' else ''
      memo += "<a href='#' class='#{tool} #{active}'>#{tool.capitalize()}</a> "

for scope, fn of templateHelpers
  [templateName, helperFn] = scope.split(' ')

  Template[templateName][helperFn] = fn

# Global helper
# TODO makes this work based on Session value so it
# is reactive and updates the page title once the dom
# has loaded
Handlebars.registerHelper 'title', ->
  'Pixtionary'

Handlebars.registerHelper 'drawing', ->
  drawing()

# Template events
templateEvents =
  canvas:
    'mousedown canvas': (e) ->
      return unless drawing()

      e.preventDefault()

      Session.set 'mousedown', true

    'touchstart': (e) ->
      return unless drawing()

      e.preventDefault()

    'mousemove canvas': (e) ->
      return unless drawing()
      return unless Session.get('mousedown')

      createShape(e)

    'touchmove': (e) ->
      return unless drawing()

      createShape(e)

    'mouseup canvas': ->
      return unless drawing()

      Session.set 'mousedown', false

    'click canvas': (e) ->
      return unless drawing()

      createShape(e)

  guesses:
    'keyup .guess': (e) ->
      return if (target = $(e.currentTarget)).val() is ''
      return unless (user = Meteor.user())

      if e.keyCode is 13
        Meteor.call('checkGuess', target.val(), user._id)

        target.val ''

        target.focus()

  header:
    'click .toggle_draw': ->
      return unless (user = Meteor.user())

      Meteor.users.update {}
        $set:
          drawing: if user then true else false
          score: user.score - 50
        {multi: true}

    'click .clear': ->
      clear()

  palette:
    'click, touchstart span': (e) ->
      e.preventDefault()

      Session.set('color', $(e.currentTarget).css('background-color'))

  size:
    'change': (e) ->
      target = $(e.currentTarget)

      Session.set('size', target.val())

  tools:
    'click a': (e) ->
      e.preventDefault()

      $('.tools a').removeClass('active')

      Session.set('tool', $(e.currentTarget).attr('class'))

      $(e.currentTarget).addClass('active')

for templateName, obj of templateEvents
  Template[templateName]['events'] = obj
