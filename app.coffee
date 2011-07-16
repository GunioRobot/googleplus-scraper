#!/usr/bin/env coffee

path       = require 'path'
url        = require 'url'
util       = require 'util'
googleplus = require './lib/googleplus-scraper.coffee'


SERVER_PORT   = '4567'


# Process life vest. Just in case.
process.addListener 'uncaughtException', (err) ->
  util.log err


server = require('http').createServer (req, res) ->
  gpRequest = url.parse(req.url).pathname.match(/\/(\d{21})\/?(profile|posts)?\/?$/)

  write = (body, mimetype = 'text/html') ->
    res.writeHead 200,
      'Content-Type': "#{mimetype}; charset=utf-8"
      'Content-Length': Buffer.byteLength(body, 'utf-8')
      'Access-Control-Allow-Origin': '*'
      'Access-Control-Allow-Headers': 'X-Requested-With'
    res.end body


  if gpRequest
    showPosts = (gpRequest[2] is 'posts')
    gp = googleplus.GooglePlusScraper gpRequest[1], (err, data) =>
      if err
        gpResponse = { 'error': err }
      else  
        gpResponse = if showPosts then gp.getPosts(data) else gp.getProfile(data)
      write JSON.stringify(gpResponse), 'application/json'

  else
    body = '''
      <!DOCTYPE html>
      <html><head><meta charset="utf-8" />
      <title>Google+ Scraper</title>
      </head><body>
      <pre>
      <strong>Google+ Scraper</strong>
      by Frederic Hemberger (<a href="https://github.com/fhemberger/googleplus-scraper/">GitHub</a>)

      Usage:
      /<em>[Google+ User ID]</em>/                 &mdash; or &mdash;
      /<em>[Google+ User ID]</em>/profile          Return user's public profile

      /<em>[Google+ User ID]</em>/posts            Return user's posts
      </pre>
      </body></html>
      '''
    write body


server.listen SERVER_PORT

util.puts "Google+ Scraper running on port #{SERVER_PORT}"
