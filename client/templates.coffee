if Meteor.is_client
  # Template helper functions
  templateHelpers =
    'header disabled': ->
      if Shapes.find().count() > 0 then '' else 'disabled=disabled'
    'instructions time': ->
      -(Session.get('time_remaining') / 1000).toFixed(1)
    'instructions word': ->
      Session.get 'word'
    'palette colors': ->
      output = ""

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
      ].each (color) ->
        if Color(Session.get('color')).toHex() is Color(color).toHex()
          output += "<span class='active' style='background-color:#{Color(color).toHex()}'></span> "
        else
          output += "<span style='background-color:#{Color(color).toHex()}'></span> "

      output
    'size brushSize': ->
      parseInt(Session.get('size'))
    'tools toolList': ->
      output = ''

      ['rectangle', 'circle'].each (tool) ->
        active = if tool is Session.get('tool') then 'active' else ''
        output += "<a href='#' class='#{tool} #{active}'>#{tool.capitalize()}</a> "

      output

  for scope, fn of templateHelpers
    [templateName, helperFn] = scope.split(' ')

    Template[templateName][helperFn] = fn

  # Global helper
  Handlebars.registerHelper 'title', ->
    'Pixtionary'

  # Template events
  templateEvents =
    canvas:
      'mousedown canvas': (e) ->
        e.preventDefault()

        Session.set 'mousedown', true

      'touchstart': (e) ->
        e.preventDefault()

      'mousemove canvas': (e) ->
        return unless Session.get('mousedown')

        createShape(e)

        drawShapes()

      'touchmove': (e) ->
        createShape(e)

        drawShapes()

      # todo set mousedown session property
      # to false whenever the mouse is let go
      # even if it isn't on top of the canvas
      'mouseup canvas': ->
        Session.set 'mousedown', false

      'click canvas': (e) ->
        createShape(e)

        drawShapes()
    header:
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
