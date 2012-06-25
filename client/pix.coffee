Shapes = new Meteor.Collection 'shapes'
UserSessions = new Meteor.Collection 'userSessions'
Answers = new Meteor.Collection 'answers'

if Meteor.is_client
  Session.set('color', 'black')
  Session.set('tool', 'circle')
  Session.set('size', 10)
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
    setTimeout ->
      Session.set('word', Answers.find().fetch().rand().word)
    , 1000

    $(document).on 'mouseup', (e) ->
      return if $(e.target).is('canvas')

      Session.set 'mousedown', false

    startUpdateListener()

    intervalId = Meteor.setInterval ->
      Session.set 'time_remaining', (+ new Date()) - (Session.get('time') + 60.seconds)
    , 100
