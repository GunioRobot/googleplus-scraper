#!/usr/bin/env coffee

path       = require 'path'
url        = require 'url'
util       = require 'util'

googleplus = require './lib/googleplus-scraper.coffee'
view       = require './lib/view.coffee'


SERVER_PORT   = '4567'
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
    [userId, view, format] = route[1..3]
    view   ||= 'profile'
    format ||= 'json'
    format = 'json' if view is 'profile'

    gp = googleplus.GooglePlusScraper userId, (err, data) =>
      if err
        gpResponse = 
          error: err
      else
        if format is 'rss' or format is 'atom'
          gpResponse =
            profile: gp.getProfile(data)
            posts:   gp.getPosts(data)
        else
          gpResponse = if view is 'posts' then gp.getPosts(data) else gp.getProfile(data)

      views[view][format].render(res, gpResponse)

  else
    views.index.render(res)


server.listen SERVER_PORT

util.puts "Google+ Scraper running on port #{SERVER_PORT}"
