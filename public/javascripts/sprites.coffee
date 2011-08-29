gamejs = require('gamejs')
params = window.params;

exports.preload = ->
  gamejs.preload(
      ["images/panda_side_1.png", "images/panda_side_2.png",
       "images/panda_down_1.png", "images/panda_down_2.png",
       "images/panda_up_1.png", "images/panda_up_2.png",
       "images/panda_sitting_down.png",
       "images/panda_sitting_up.png",
       "images/panda_sitting_right.png",
       "images/flame_bolt_vert_1.png", "images/flame_bolt_vert_2.png",
       "images/grass_tile.png",
       "images/flame_bolt_horizontal_1.png", "images/flame_bolt_horizontal_2.png",
       "images/blood_splash.png", "images/palm.png",
       "images/dead_panda.png", "images/rock.png",
       "images/sand.png"
      ]);

class BaseElement extends gamejs.sprite.Sprite
  constructor: ->
    super()
    
    @attrs   = {}
    @changes = {}
    @rect    = new gamejs.Rect([0, 0])
    @type    = null
  
  get: (attr) ->
    @attrs[attr]
  
  set: (attr, val) ->
    @attrs[attr]   = val
    @changes[attr] = true
  
  getType: ->
    @type
    
  update: (msDuration) ->
    @rect.left = @.get('x')
    @rect.top  = @.get('y')


class Animated extends BaseElement
  constructor: ->
    super()
    
    @image        = null
    @imageGroups  = {}
    @currentImage = 0
    @updatesCount = -2
    
  
  isMoving: ->
    @.get('moving') == 1
  
  hasChanged: (attr) ->
    @changes['dir'] == true
  
  update: (msDuration) ->
    super(msDuration)
    
    dir = @.get('dir')
    if not @.isMoving()
      @image = @imageGroups[dir][0]
    else
      @updatesCount += 1
      
      if @updatesCount == 3 || @.hasChanged('dir')
        nextImage = @currentImage + 1
        nextImage = 0 if nextImage >= @imageGroups[dir].length
        
        @image        = @imageGroups[dir][nextImage]
        @currentImage = nextImage
        @updatesCount = 0


class Panda extends Animated
  constructor: ->
    super()  
    @type = "PANDA"
    
    @deadImage        = gamejs.image.load("images/dead_panda.png")
    
    rightFacingFrame1 = gamejs.image.load("images/panda_side_1.png")
    rightFacingFrame2 = gamejs.image.load("images/panda_side_2.png")
    @imageGroups[params.Direction.RIGHT] = [rightFacingFrame1, rightFacingFrame2]
    
    leftFacingFrame1  = gamejs.transform.flip(rightFacingFrame1, true)
    leftFacingFrame2  = gamejs.transform.flip(rightFacingFrame2, true)
    @imageGroups[params.Direction.LEFT] = [leftFacingFrame1, leftFacingFrame2]
    
    upFacingFrame1    = gamejs.image.load("images/panda_up_1.png")
    upFacingFrame2    = gamejs.image.load("images/panda_up_2.png")
    upFacingFrame3    = gamejs.transform.flip(upFacingFrame1, true)
    @imageGroups[params.Direction.UP] = [upFacingFrame1, upFacingFrame2, upFacingFrame3]
    
    downFacingFrame1  = gamejs.image.load("images/panda_down_1.png")
    downFacingFrame2  = gamejs.image.load("images/panda_down_2.png")
    downFacingFrame3  = gamejs.transform.flip(downFacingFrame1, true)
    @imageGroups[params.Direction.DOWN] = [downFacingFrame1, downFacingFrame2, downFacingFrame3]
    
    stationaryUp      = gamejs.image.load("images/panda_sitting_up.png")
    stationaryDown    = gamejs.image.load("images/panda_sitting_down.png")
    stationaryRight   = gamejs.image.load("images/panda_sitting_right.png")
    stationaryLeft    = gamejs.transform.flip(stationaryRight, true)
    @imageGroups[params.Direction.NONE] = [stationaryDown, stationaryUp, stationaryDown, stationaryLeft, stationaryRight]
    
  isAlive: ->
    @.get('alive') == 1
  
  update: (msDuration) ->
    BaseElement.prototype.update.call(@, msDuration)
    
    if not @.isAlive()
      @image = @deadImage
    else if not @.isMoving()
      @image = @imageGroups[0][@.get('dir')]
    else
      super(msDuration)

  draw: (mainSurface) ->
    mainSurface.blit(@image, @rect)
    
    # Draw health bar
    if @.isAlive() and @.get('health') >= 0
      maxHbWidth   = @image.getSize()[0]
      hbWidth      = Math.floor(@.get('health') / 100 * maxHbWidth)
      hbHeight     = 4
      srArray      = new gamejs.surfacearray.SurfaceArray([hbWidth, hbHeight])
      borderColor = [0, 0, 0]
      healthColor = [0, 255, 0]
      
      x = 0
      while x < hbWidth
        y = 0
        
        while y < hbHeight
          if y == 0 or y == hbHeight - 1 or x == 0 or x == hbWidth - 1
            srArray.set(x, y, borderColor)
          else
           srArray.set(x, y, healthColor)
          
          y += 1
          
        x += 1
      
      mainSurface.blit(srArray.surface, new gamejs.Rect([@rect.left, @rect.top-5]));

exports.Panda = Panda;


class Projectile extends Animated
  constructor: ->
    super()
    @type = "PROJECTILE"
    
    horizontalFrame1 = gamejs.image.load("images/flame_bolt_horizontal_1.png")
    horizontalFrame2 = gamejs.image.load("images/flame_bolt_horizontal_2.png")
    @imageGroups[params.Direction.LEFT] = @imageGroups[params.Direction.RIGHT] = [horizontalFrame1, horizontalFrame2]
    
    verticalFrame1   = gamejs.image.load("images/flame_bolt_vert_1.png")
    verticalFrame2   = gamejs.image.load("images/flame_bolt_vert_2.png")
    @imageGroups[params.Direction.UP] = @imageGroups[params.Direction.DOWN] = [verticalFrame1, verticalFrame2]

exports.Projectile = Projectile;


class Bloodsplash extends BaseElement
  constructor: ->
    super()
    @type  = "EXPLOSION"
    @image = gamejs.image.load("images/blood_splash.png")

exports.Bloodsplash = Bloodsplash;