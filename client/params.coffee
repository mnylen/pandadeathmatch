params =
  gameWidth:           700
  gameHeight:          438
  pandaWidth:          15
  pandaHeight:         15
  pandaStartHealth:    100
  projectileWidth:     15
  projectileHeight:    5
  projectileFireDelay: 1200
  projectileDamage:    35
  projectileKillScore: 1
  expolosionDuration:  1000
  respawnTicks:        50
  explosionDuration:   1000
  frameRate:           10
  Direction:
    NONE:              0
    UP:                1
    DOWN:              2
    LEFT:              3
    RIGHT:             4
    
  Speed:
    PANDA:             6
    PROJECTILE:        12

if typeof window == 'undefined'
  module.exports = params
else
  window.params = params