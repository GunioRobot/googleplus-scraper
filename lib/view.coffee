jade = require 'jade'
fs   = require 'fs'


class View
  @_mimeType = 'text/plain'

  constructor: (filename, options = {}) ->
    templateFile = fs.readFileSync(filename, 'utf8')
    @_template   = jade.compile(templateFile, options)

  render: (context = undefined, locals = {}) ->
    body = @_template.call(@, locals)
    
    if context
      context.writeHead 200,
        'Content-Type': "#{@_mimeType}; charset=utf-8"
        'Content-Length': Buffer.byteLength(body, 'utf-8')
        'Access-Control-Allow-Origin': '*'
        'Access-Control-Allow-Headers': 'X-Requested-With'
      context.end body
    else
      body
    

class HTMLView extends View
  @_mimeType = 'text/html'


class JSONView extends View
  @_mimeType = 'application/json'

  constructor: () ->
    
  render: (context = undefined, locals = {}) ->
    @_template = (locals) ->
      JSON.stringify locals
    super context, locals


class RSSView extends View
  @_mimeType = 'application/rss+xml'


class ATOMView extends View
  @_mimeType = 'application/atom+xml'


class ViewFactory
  load: (filename = '') ->
    matches = filename.match /\.(\w+)\.?\w*$/
    
    # Default to JSON
    return new JSONView if (!matches or matches.length < 2)
    
    extension = matches[1]
    switch extension
      when "html" then return new HTMLView(filename)
      when "rss"  then return new RSSView(filename)
      when "atom" then return new ATOMView(filename)
      else return new View(filename)


module.exports = new ViewFactory