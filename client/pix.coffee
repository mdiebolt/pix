Shapes = new Meteor.Collection 'shapes'
Answers = new Meteor.Collection 'answers'

Shapes.find().observe
  added: (shape) ->
    drawShape(shape)

Meteor.users.find().observe
  added: (user) ->
    # TODO update the user by id
    name = user.name

    unless user.score?
      Meteor.users.update
        name: name
        $set:
          score: 0

    unless user.drawing?
      Meteor.users.update
        name: name
        $set:
          drawing: false

Session.set('color', 'black')
Session.set('tool', 'circle')
Session.set('size', 10)
Session.set('time', +new Date())
Session.set('time_remaining', 60.seconds)

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

drawing = ->
  if Meteor.user()
    Meteor.user().drawing
  else
    false

drawShape = (shape) ->
  canvas = $('canvas')
  context = canvas.get(0).getContext('2d')

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

Meteor.startup ->
  Meteor.subscribe 'answers', ->
    Session.set('word', Answers.find().fetch().rand().word)

  Meteor.subscribe 'shapes', ->
    Shapes.find()

  $(document).on 'mouseup', (e) ->
    return if $(e.target).is('canvas')

    Session.set 'mousedown', false

  intervalId = Meteor.setInterval ->
    Session.set 'time_remaining', Session.get('time') + 60.seconds - (+new Date())
  , 100
