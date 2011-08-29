class Scoreboard
  constructor: ->
    @el     = $("#player-list")
    @showing = false
  
  removePanda: (pandaId) ->
    @el.find(@._itemId(pandaId, true)).remove()
  
  addPanda: (pandaId, nick, initialScore) ->
    initialScore  = initialScore || 0
    appendBefore = @._findItemWithLowerScore(initialScore)
    newItem      = @._createItem(pandaId, nick, initialScore)
    
    if appendBefore
      $(appendBefore).before(newItem)
    else
      @el.append(newItem)
  
  updateScore: (pandaId, newScore) ->
    nick = this.el.find(@._itemId(pandaId, true)).find(".nick").text();
    @.removePanda(pandaId)
    @.addPanda(pandaId, nick, newScore)
    
  show: ->
    return if @showing
    @showing = true
    
    canvas = $("#gjs-canvas")
    cW   = parseInt(canvas.css('width'), 10)    # canvas width
    cH   = parseInt(canvas.css('height'), 10)   # canvas height
    cPos = canvas.position()                    # canvas position
    sbW  = cW - 40                              # scoreboard width
    sbH  = cH - 40                              # scoreboard height
    sbX  = cPos.left + Math.floor((cW-sbW)/2)   # scoreboard left x coordinate
    sbY  = cPos.top + Math.floor((cH-sbH)/2)    # scoreboard top y coordinate
    
    @el.css(
      width:     sbW
      height:    sbH
      position:  "absolute"
      opacity:   0.8
      top:       sbY + "px"
      left:      sbX + "px"
      "z-index": 100000
    );
    
    @el.fadeIn();
  
  hide: ->
    return if not @showing
    
    @el.fadeOut()
    @showing = false

  # PRIVATE METHODS
  
  _itemId: (pandaId, hashMark) ->
    if hashMark
      "#panda-#{pandaId}"
    else
      "panda-#{pandaId}"
        
  _findItemWithLowerScore: (score) ->
    items = _($(this.el).find("li").get())
    items.detect( (item) -> parseInt($(item).attr("data-score"), 10) <= score )
  
  _createItem: (pandaId, nick, initialScore) ->
    item = $("<li>")
            .attr("id", @._itemId(pandaId))
            .attr("data-score", initialScore)
            
    nick = $("<div>")
            .addClass("nick")
            .text(nick)
    
    score = $("<div>")
            .addClass("score")
            .text(initialScore)
      
    item.append(nick)
    item.append(score);
    
    return item
        

exports.Scoreboard = Scoreboard;