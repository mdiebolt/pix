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
    Session.get 'word'
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
    output = '<table><th>Name</th><th>Score</th>'

    Meteor.users.find().forEach (player) ->
      output += "<tr><td>#{player.name || player.emails.first()}</td><td>#{player.score}</td></tr>"

    output += '</table>'

    output

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
  header:
    'click .toggle_draw': ->
      Meteor.users.update {}
        $set:
          drawing: not Meteor.user().drawing

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
