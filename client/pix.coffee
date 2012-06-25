Shapes = new Meteor.Collection 'shapes'
UserSessions = new Meteor.Collection 'userSessions'

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
  Session.set('tool', 'circle')
  Session.set('size', 10)
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
    halfSize = size / 2

    if Session.get('tool') is 'rectangle'
      dimensions = [x - halfSize, y - halfSize, size, size]
    else if Session.get('tool') is 'circle'
      dimensions = [x - size / 4, y - size / 4, size / 2]

    Shapes.insert
      color: Session.get('color')
      shape: Session.get('tool')
      coords: dimensions

  drawShapes = ->
    canvas = $('canvas')
    context = canvas.get(0).getContext('2d')

    Shapes.find().forEach (shape) ->
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

    #sessionId = UserSessions.insert
    #  drawing: false

    #Session.set 'sessionId', sessionId

    # TODO pick new word to draw when this runs out
    # and assign a new person as the painter. Only
    # get points by answering correctly
    intervalId = Meteor.setInterval ->
      Session.set 'time_remaining', (+ new Date()) - (Session.get('time') + 60.seconds)
    , 100
