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

  if gpRequest
    showPosts = (gpRequest[2] is 'posts')
    gp = googleplus.GooglePlusScraper gpRequest[1], () =>
      gpResponse = if showPosts then gp.getPosts() else gp.getProfile()
      res.writeHead 200,
        'Content-Type': 'application/json; charset=utf-8'
        'Access-Control-Allow-Origin': '*'
        'Access-Control-Allow-Headers': 'X-Requested-With'
      res.end JSON.stringify gpResponse
  else
    res.writeHead 200,
      'Content-Type': 'text/html; charset=utf-8'
      'Access-Control-Allow-Origin': '*'
      'Access-Control-Allow-Headers': 'X-Requested-With'
    res.end '''
            <pre>
            <strong>Google+ Scraper</strong>
            by Frederic Hemberger (<a href="https://github.com/fhemberger/googleplus-scraper/">GitHub</a>)
            
            Usage:
            /<em>[Google+ User ID]</em>/                 &mdash; or &mdash;
            /<em>[Google+ User ID]</em>/profile          Return user's public profile
            
            /<em>[Google+ User ID]</em>/posts            Return user's posts
            </pre>
            '''

server.listen SERVER_PORT

util.puts "Google+ Scraper running on port #{SERVER_PORT}"
