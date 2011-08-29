gamejs  = require 'gamejs'
sprites = require 'sprites'
{Game}  = require 'game'
params  = window.params
ipad    = require 'ipad'
io      = require 'io'

exports.start = (socket) ->
  # Listen for delta updates
  socket.on('gameStateDelta', (state) -> game.updateState(state) )
	
  # Start game and receiving delta updates, initialize game
  game = new Game(params.gameWidth, params.gameHeight, socket)
  ipad.start(game, socket)

  socket.emit('startGame', (gameInit) -> game.updateState(gameInit) )
  
  # Start client side main loop
  tick = (msDuration) ->
    io.processEvents(game)

    mainSurface = gamejs.display.getSurface()
    game.update(msDuration)
    game.draw(mainSurface)
  
  gamejs.time.fpsCallback(tick, this, 25)
