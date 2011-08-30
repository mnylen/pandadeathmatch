express = require 'express'
app     = express.createServer()
io      = require('socket.io').listen(app)
gameIo  = require './lib/io'

app.configure(->
  app.set('views', __dirname + '/views')
  app.set('view engine', 'jade')
  app.use(express.bodyParser())
  app.use(express.methodOverride())
  app.use(app.router)
  app.use(express.static(__dirname + '/public'))
  
  io.set('transports', ['websocket', 'flashsocket', 'htmlfile', 'xhr-polling', 'jsonp-polling'])
  io.set('browser client minification', true)
  io.set('browser client etag', true)
)

port = 3000

app.configure('development', ->
  app.use(express.errorHandler(
    dumpExceptions: true
    showStack: true
  ))
  
  io.set('log level', 3)
)

app.configure('production', ->
  app.use(express.errorHandler())
  port = 80
)

app.get('/', (req, res) ->
  res.render('index')
)

app.listen(port)
gameIo(io)

console.log("Express server listening on port %d in %s mode", app.address().port, app.settings.env)
