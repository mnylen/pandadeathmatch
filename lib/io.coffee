game = require './game'
uid  = require './uid'
_    = require 'underscore'

eventHandler = (game, id, nick) ->
  onStartGame: (callback) ->
    game.playerJoined(id, nick)
    callback(game.getState())
    
  onStartMoving: (dir, callback) ->
    game.playerStartedMoving(id, dir)
    callback() if callback
    
  onStopMoving: (callback) ->
    game.playerStoppedMoving(id)
    callback() if callback
    
  onFire: (callback) ->
    game.playerFired(id)
    callback() if callback
    
  onDisconnect: ->
    game.playerLeft(id)

module.exports = (io) ->
  io.sockets.on('connection', (socket) ->
    joined = false
    
    socket.on('join', (nick, callback) ->
      nick = nick.trim()
      allowJoin = nick.length > 0 and not joined and not _(game.getNicks()).include(nick)
      
      if allowJoin
        joined  = true
        id      = uid()
        handler = eventHandler(game, id, nick)
        
        socket.on('startGame', handler.onStartGame)
        socket.on('startMoving', handler.onStartMoving)
        socket.on('stopMoving', handler.onStopMoving)
        socket.on('fire', handler.onFire)
        socket.on('disconnect', handler.onDisconnect)
        
        callback(true)
      else
        callback(false)
    )
  )
  
  game.on('stateDelta', (stateDelta) -> io.sockets.emit('gameStateDelta', stateDelta))
