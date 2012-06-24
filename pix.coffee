Shapes = new Meteor.Collection 'shapes'

if Meteor.is_client
  clear = ->
    shapes = Shapes.find().fetch()

    shapes.each (shape) ->
      Shapes.remove {}

  iPadCreateShape = (e) ->
    canvasOffset = $('canvas').offset()

    touchX = e.changedTouches[0].clientX - canvasOffset.left
    touchY = e.changedTouches[0].clientY - canvasOffset.top

    Shapes.insert
      color: Session.get('current_color')
      coords: [touchX, touchY, 8, 8]

  createShape = (e) ->
    Shapes.insert
      color: Session.get('current_color')
      coords: [e.offsetX, e.offsetY, 8, 8]

  drawShapes = ->
    canvas = $('canvas')
    context = canvas.get(0).getContext('2d')

    context.fillStyle = '#ffffff'
    context.fillRect(0, 0, canvas.attr('width'), canvas.attr('height'))

    Shapes.find().fetch().each (shape) ->
      context.fillStyle = shape.color

      [x, y, width, height] = shape.coords

      context.fillRect(x, y, width, height)

  startUpdateListener = ->
    redrawCanvas = ->
      context = new Meteor.deps.Context()
      context.on_invalidate(redrawCanvas)
      context.run ->
        drawShapes()

    redrawCanvas()

  Meteor.startup ->
    startUpdateListener()

    Session.set('current_color', 'black')

  Template.palette.events =
    'click, touchstart': (e) ->
      Session.set('current_color', $(e.currentTarget).css('background-color'))

  Template.canvas.events =
    'mousedown': ->
      Session.set 'mousedown', true

    'touchstart': ->
      Session.set 'mousedown', true

    'mousemove': (e) ->
      return unless Session.get('mousedown')

      e.preventDefault()

      createShape(e)

      drawShapes()

    'touchmove': (e) ->
      return unless Session.get('mousedown')

      e.preventDefault()

      iPadCreateShape(e)

      drawShapes()

    'mouseup': ->
      Session.set 'mousedown', false

    'touchend': ->
      Session.set 'mousedown', false

    'click canvas': (e) ->
      createShape(e)

      drawShapes()

    'touchstart canvas': (e) ->
      iPadCreateShape(e)

      drawShapes()

    'click .clear': ->
      clear()

    'touchstart clear': ->
      clear()

if Meteor.is_server
  Meteor.startup ->
    ;
