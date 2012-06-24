Shapes = new Meteor.Collection 'shapes'

if Meteor.is_client
  clear = ->
    shapes = Shapes.find().fetch()

    shapes.each (shape) ->
      Shapes.remove {}

  createShape = (e) ->
    canvasOffset = $('canvas').offset()

    x = e.offsetX || (e.changedTouches[0].clientX - canvasOffset.left)
    y = e.offsetY || (e.changedTouches[0].clientY - canvasOffset.top)

    size = Session.get('size')

    Shapes.insert
      color: Session.get('current_color')
      shape: Session.get('tool')
      coords: [x, y, size, size]

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
        context.arc(x, y, radius, 0, 2 * Math.PI, true)
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

    Session.set('current_color', 'black')
    Session.set('tool', 'rectangle')
    Session.set('size', 4)

  Template.size.events =
    'change': (e) ->
      e.preventDefault()

      target = $(e.currentTarget)

      target.prev().text("Brush Size (#{target.val()})")

      Session.set('size', target.val())

  Template.tools.events =
    'click a': (e) ->
      e.preventDefault()

      Session.set('tool', $(e.currentTarget).attr('class'))

      $('.tools a').removeClass('active')

      $(e.currentTarget).addClass('active')

  Template.palette.events =
    'click, touchstart': (e) ->
      Session.set('current_color', $(e.currentTarget).css('background-color'))

  Template.canvas.events =
    'mousedown, touchstart': ->
      Session.set 'mousedown', true

    'mousemove, touchmove': (e) ->
      return unless Session.get('mousedown')

      e.preventDefault()

      createShape(e)

      drawShapes()

    'mouseup, touchend': ->
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
