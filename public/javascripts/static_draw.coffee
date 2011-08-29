gamejs          = require 'gamejs'
params          = window.params
palmCoordinates = require('./gen/palm_coordinates').coords
sandCoordinates = require('./gen/sand_coordinates').coords
rockCoordinates = require('./gen/rock_coordinates').coords

drawImagesToSurface = (img, coordinates, surface, rect) ->
  surface = surface || new gamejs.Surface(params.gameWidth, params.gameHeight)
  size    = img.getSize();
  rect    = rect || new gamejs.Rect([0,0],img.getSize())
  
  for coord in coordinates
    [x, y, r, left, top] = [coord[0], coord[1], coord[2], rect.left, rect.top]
    x_ = Math.min(params.gameWidth - x, rect.width)
    y_ = Math.min(params.gameHeight - y, rect.height)
    r_ = new gamejs.Rect([left, top], [x_, y_])
    
    surface.blit(img, new gamejs.Rect([x+left, y+top], [x_, y_]), r_)
    
  surface
  
createAndFillSurface = (img) ->
  size      = img.getSize()
  [x,y,w,h] = [0, 0, size[0], size[1]]
  
  surface = new gamejs.Surface(params.gameWidth, params.gameHeight)
  
  x = 0
  while x < params.gameWidth
    y = 0
    while y < params.gameHeight
      surface.blit(img, new gamejs.Rect([x, y]))
      
      y += h
    
    x += w
    
  surface



backgroundSurface = null
topSurface        = null

exports.init = ->
  grassImage = gamejs.image.load("images/grass_tile.png")
  palmImage  = gamejs.image.load("images/palm.png")
  sandImage  = gamejs.image.load("images/sand.png")
  rockImage  = gamejs.image.load("images/rock.png")

  # Predraw background surface (grass + sand + half of the palms)
  backgroundSurface = createAndFillSurface(grassImage)
  drawImagesToSurface(sandImage, sandCoordinates, backgroundSurface)
  drawImagesToSurface(rockImage, rockCoordinates, backgroundSurface)
  drawImagesToSurface(palmImage, palmCoordinates, backgroundSurface, new gamejs.Rect([0,25],[50,22]))

  # Predraw top surface (other half of the palms)
  topSurface = drawImagesToSurface(palmImage, palmCoordinates, undefined, new gamejs.Rect([0,0],[50,25]))

exports.blitBackgroundSurface = (mainSurface) -> mainSurface.blit(backgroundSurface)
exports.blitTopSurface        = (mainSurface) -> mainSurface.blit(topSurface)

