class MapObject
  constructor: (x, y, image, rotation, backgroundArea, foregroundArea) ->
    @x              = x
    @y              = y
    @rotation       = rotation
    @backgroundArea = backgroundArea
    @foregroundArea = foregroundArea
    
    if rotation
      @image = gamejs.transform.rotate(image, rotation)
    else
      @image = image
      
    @size           = @image.getSize()
  
  draw: (backgroundSurface, foregroundSurface) ->
    if @backgroundArea
      @._drawPartial(backgroundSurface, @backgroundArea)
    
    if @foregroundArea
      @._drawPartial(foregroundSurface, @foregroundArea)
      
    if not @backgroundarea and not @foregroundArea
      @._drawPartial(backgroundSurface, null)
    
  _drawPartial: (surface, partialArea) ->
    partialArea   = partialArea || new gamejs.Rect([0, 0], @size)
    partialLeft   = partialArea.left
    partialTop    = partialArea.top
    partialWidth  = Math.min(params.gameWidth - @x, partialArea.width)
    partialHeight = Math.min(params.gameHeight - @y, partialArea.height)
    destRect      = new gamejs.Rect([@x+partialLeft, @y+partialTop])
    partialArea   = new gamejs.Rect([partialLeft, partialTop], [partialWidth, partialHeight])
    
    surface.blit(@image, destRect, partialArea)