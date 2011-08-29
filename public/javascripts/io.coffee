gamejs = require 'gamejs'

keyToDirection = (key) ->
  switch key
    when gamejs.event.K_UP      then params.Direction.UP
    when gamejs.event.K_DOWN    then params.Direction.DOWN
    when gamejs.event.K_LEFT    then params.Direction.LEFT
    when gamejs.event.K_RIGHT   then params.Direction.RIGHT


onKeyDown = (game, key) ->
  switch key
    when gamejs.event.K_SPACE then game.fire()
    when gamejs.event.K_TAB   then game.scoreboard.show()
    else                           game.changeDirection(keyToDirection(key))


onKeyUp = (game, key) ->
  switch key
    when gamejs.event.K_TAB then game.scoreboard.hide()
    else
      if keyToDirection(key) == game.currentDirection
        game.stopMoving()

exports.processEvents = (game) ->
  byType = _(gamejs.event.get()).groupBy( (e) -> e.type )
  onKeyDown(game, e.key) for e in (byType[gamejs.event.KEY_DOWN] || [])
  onKeyUp(game, e.key) for e in (byType[gamejs.event.KEY_UP] || [])