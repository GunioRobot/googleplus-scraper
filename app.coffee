#!/usr/bin/env coffee

path       = require 'path'
url        = require 'url'
util       = require 'util'

cache      = require('./lib/pico.coffee').Pico()
googleplus = require './lib/googleplus-scraper.coffee'
view       = require './lib/view.coffee'

arguments  = process.argv.splice(2)
port       = parseInt(arguments[0], 10) if arguments[0]

SERVER_PORT   = port || '4567'
SERVER_VIEWS  = path.join __dirname, 'views'


views =
  error:  view.load()
  index:  view.load("#{SERVER_VIEWS}/index.html.jade")
  posts:
    json: view.load()
    rss:  view.load("#{SERVER_VIEWS}/posts.rss.jade")
    atom: view.load("#{SERVER_VIEWS}/posts.atom.jade")
  profile:
    json: view.load()


# Process life vest. Just in case.
httpResponse = undefined 
process.addListener 'uncaughtException', (err) ->
  util.log err
  views.error.render(httpResponse, {error: err.message}) if httpResponse?


renderGooglePlusData = (res, [err, data]) ->
  if err
    gpResponse =
      error: err
  else
    if res.format is 'rss' or res.format is 'atom'
      gpResponse =
        profile: googleplus.getProfile(data)
        posts:   googleplus.getPosts(data)
    else
      gpResponse = if res.view is 'posts' then googleplus.getPosts(data) else googleplus.getProfile(data)

  views[res.view][res.format].render(res, gpResponse)


server = require('http').createServer (req, res) ->
  httpResponse = res
  uri = url.parse(req.url).pathname
  
  # We don't serve your kind here ...
  return if uri is '/favicon.ico'

  route = uri.match(///
    /(\d{21})             # userid
    /?(profile|posts)?    # view
    \.?(json|rss|atom)?$  # format
    ///)
  
  if route and route[1]
    [res.userId, res.view, res.format] = route[1..3]
    res.view   ||= 'profile'
    res.format ||= 'json'
    res.format = 'json' if res.view is 'profile'

    googleplusResponse = cache.get res.userId
    if googleplusResponse
      renderGooglePlusData res, googleplusResponse
    else 
      googleplus.scrape res.userId, (err, data) =>
        renderGooglePlusData res, [err, data]
        cache.set res.userId, [err, data]

  else
    views.index.render(res)

try
  server.listen SERVER_PORT
  util.puts "Google+ Scraper running on port #{SERVER_PORT}"
catch e
  util.puts "\033[31mERROR:\033[0m Cannot start server on port #{SERVER_PORT}"


