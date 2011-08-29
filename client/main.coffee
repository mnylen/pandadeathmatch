gamejs  = require 'gamejs'
tick    = require 'tick'
sprites = require 'sprites'
params  = window.params

scaleToFitWindow = ->
  areaWidth    = $(window).width()
  areaHeight   = $(window).height() - $("#header").height() - 140
  resizeFactor = Math.min((areaWidth/params.gameWidth), (areaHeight/params.gameHeight))
  scaledWidth  = Math.floor(resizeFactor * params.gameWidth)
  scaledHeight = Math.floor(resizeFactor * params.gameHeight)
  
  # Scale canvas
  $("#gjs-canvas").css(
    height : scaledHeight
    width  : scaledWidth
  )
  
  # TODO: HACKHACK, cleanup
  
  # Set width wrapper and instructions ul so that layout centering works
  for el in [$("#gjs-canvas"), $("#wrapper"), $("#instructions")]
    el.css(width : scaledWidth)
    
  # Position wrapper to center
  leftOffset = Math.floor((areaWidth - (window.params.gameWidth * resizeFactor))/2)
  $("#wrapper").css(
    position : "absolute"
    left     : leftOffset
  )


$(->
  alreadyStarted = false
  
  # Establish connection to server
  socket = io.connect()
  
  main = ->
    # Switch to game layout
    $("#login-splash").remove()
    $("#wrapper").show()

    # Scale game area
    scaleToFitWindow()
    $(window).resize( -> scaleToFitWindow() )
    
    # Start game
    gamejs.display.setMode([window.params.gameWidth, window.params.gameHeight]);
    tick.start(socket)
  
  
  onStart = ->
    return if alreadyStarted
    alreadyStarted = true
      
    nick = $("#nick").val()
    socket.emit('join', nick, (ok) ->
      if ok
        sprites.preload()
        gamejs.ready(main)
      else
        alreadyStarted = false
        $("#login-fail").show()
    )
    
  $("#start").click(onStart)
  $("#nick").keyup( (e) -> onStart() if e.keyCode == 13 )
)
