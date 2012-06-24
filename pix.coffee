Shapes = new Meteor.Collection 'shapes'

if Meteor.is_client
  drawShapes = ->
    context = $('canvas').get(0).getContext('2d')

    _.each Shapes.find().fetch(), (shape) ->
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
    'click': (e) ->
      Session.set('current_color', $(e.currentTarget).css('background-color'))

  Template.canvas.events =
    'click': (e) ->
      Shapes.insert
        color: Session.get('current_color')
        coords: [e.offsetX, e.offsetY, 3, 3]

      context = $(e.currentTarget).get(0).getContext('2d')

      context.fillStyle = '#ffffff'
      context.fillRect(0, 0, 300, 300)

      drawShapes()

if Meteor.is_server
  Meteor.startup ->
    ;
