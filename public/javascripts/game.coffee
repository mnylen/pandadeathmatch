gamejs       = require 'gamejs'
sprites      = require 'sprites'
params       = window.params
static_draw  = require 'static_draw'
{Scoreboard} = require 'scoreboard'

class Game
  constructor: (width, height, socket) ->
    @socket           = socket
    @elements         = {}
    @currentDirection = params.Direction.NONE
    @scoreboard       = new Scoreboard()
    static_draw.init()
    
  update: (msDuration) ->
    for own id, el of @elements
      el.update(msDuration)
      
  changeDirection: (newDirection) ->
    return if newDirection == -1
    return if newDirection == @currentDirection
    
    @.stopMoving() if @currentDirection != params.Direction.NONE
    @currentDirection = newDirection
    @socket.emit('startMoving', newDirection)
    
  stopMoving: ->
    @socket.emit('stopMoving')
    @currentDirection = params.Direction.NONE
    
  fire: ->
    @socket.emit('fire')
  
  draw: (mainSurface) ->
    # Draw bottom layer
    mainSurface.fill("#FFFFFF")
    static_draw.blitBackgroundSurface(mainSurface)
    
    # Group elements by type and draw sprites in correct order
    byType = _(_(@elements).values()).groupBy( (el) -> el.getType() )
    
    for type in ["PROJECTILE", "PANDA", "EXPLOSION", "PALM"]
      for el in (byType[type] || [])
        el.draw(mainSurface)
    
    # Draw top layer       
    static_draw.blitTopSurface(mainSurface)
  
  updateState: (state) ->
    @._createElements(state.newElements) if state.newElements != undefined
    @._applyDeltas(state.deltas) if state.deltas != undefined
    @._removeElements(state.removedElements) if state.removedElements != undefined
  
    
  # PRIVATE METHODS
  
  _createElementOfType: (type) ->
    switch (type)
      when "PANDA"      then new sprites.Panda()
      when "EXPLOSION"  then new sprites.Bloodsplash()
      when "PROJECTILE" then new sprites.Projectile()
  
  _updateElement: (id, el, deltaUpdates) ->
    for own attr, val of deltaUpdates
      el.set(attr, val)
      
      if el.getType() == 'PANDA' && attr == 'score'
        @scoreboard.updateScore(id, val)
  
  _createElements : (newElements) ->
    for own elementType, elements of newElements
      @._createElementsOfType(elementType, elements)
  
  _createElementsOfType : (type, newElements) ->
    for own id, elementData of newElements
      el = @._createElementOfType(type)
      @scoreboard.addPanda(id, elementData.nick, elementData.score) if el.getType() == 'PANDA'
      
      @._updateElement(id, el, elementData)
      @elements[id] = el
      
  _removeElements: (ids) ->
    for id in ids
      el = @elements[id]
      @scoreboard.removePanda(id) if el.getType() == "PANDA"
      
      delete @elements[id]
  
  _applyDeltas: (deltas) ->
    for own id, deltaUpdates of deltas
      @._updateElement(id, @elements[id], deltaUpdates)
  

exports.Game = Game