Shapes = new Meteor.Collection 'shapes'

if Meteor.is_client
  words = [
    'Cat'
    'Dog'
    'Bunny'
    'Horse'
    'Monkey'
    'Cow'
    'Chicken'
  ]

  Session.set('color', 'black')
  Session.set('tool', 'rectangle')
  Session.set('size', 4)
  Session.set('word', words.rand())
  Session.set('time', +new Date())
  Session.set('time_remaining', -60.seconds)

  clear = ->
    Shapes.remove {}

  createShape = (e) ->
    canvasOffset = $('canvas').offset()

    x = e.offsetX || (e.changedTouches[0].clientX - canvasOffset.left)
    y = e.offsetY || (e.changedTouches[0].clientY - canvasOffset.top)

    size = Session.get('size')

    if Session.get('tool') is 'rectangle'
      dimensions = [x, y, size, size]
    else if Session.get('tool') is 'circle'
      dimensions = [x, y, size / 2]

    Shapes.insert
      color: Session.get('color')
      shape: Session.get('tool')
      coords: dimensions

  drawShapes = ->
    canvas = $('canvas')
    context = canvas.get(0).getContext('2d')

    context.fillStyle = '#ffffff'
    context.fillRect(0, 0, canvas.attr('width'), canvas.attr('height'))

    Shapes.find().fetch().each (shape) ->
      context.fillStyle = shape.color

      if shape.shape is 'rectangle'
        [x, y, width, height] = shape.coords

        context.fillRect(x, y, width, height)
      else if shape.shape is 'circle'
        [x, y, radius] = shape.coords

        context.beginPath()
        context.arc(x, y, radius, 0, 1.turn, true)
        context.closePath()
        context.fill()

  startUpdateListener = ->
    redrawCanvas = ->
      context = new Meteor.deps.Context()
      context.on_invalidate(redrawCanvas)
      context.run ->
        drawShapes()

    redrawCanvas()

  Meteor.startup ->
    startUpdateListener()

    # TODO pick new word to draw when this runs out
    # and assign a new person as the painter. Only
    # get points by answering correctly
    intervalId = Meteor.setInterval ->
      Session.set 'time_remaining', (+ new Date()) - (Session.get('time') + 60.seconds)
    , 100

  Template.instructions.time = ->
    -(Session.get('time_remaining') / 1000).toFixed(1)

  Template.instructions.word = ->
    Session.get('word')

  Template.header.disabled = ->
    if Shapes.find().count() > 0 then '' else 'disabled=disabled'

  Template.size.brushSize = ->
    parseInt(Session.get('size'))

  Template.size.events =
    'change': (e) ->
      target = $(e.currentTarget)

      Session.set('size', target.val())

  Template.tools.events =
    'click a': (e) ->
      e.preventDefault()

      Session.set('tool', $(e.currentTarget).attr('class'))

      $('.tools a').removeClass('active')

      $(e.currentTarget).addClass('active')

  Template.palette.colors = ->
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

    return output

  Template.palette.events =
    'click span': (e) ->
      Session.set('color', $(e.currentTarget).css('background-color'))

  Template.canvas.events =
    'mousedown, touchstart canvas': (e) ->
      e.preventDefault()

      Session.set 'mousedown', true

    'mousemove, touchmove canvas': (e) ->
      return unless Session.get('mousedown')

      createShape(e)

      drawShapes()

    # todo set mousedown session property
    # to false whenever the mouse is let go
    # even if it isn't on top of the canvas
    'mouseup, touchend canvas': ->
      Session.set 'mousedown', false

    'click canvas': (e) ->
      createShape(e)

      drawShapes()

  Template.header.events =
    'click .clear': ->
      clear()

if Meteor.is_server
  Meteor.startup ->
    ;
