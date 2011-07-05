jsdom = require 'jsdom'

class exports.GooglePlusScraper
	gpBaseURL = 'https://plus.google.com/'
	gpConfig = null

	constructor: (@user, callback) ->
		return new GooglePlusScraper(@user, callback) if !(this instanceof GooglePlusScraper)
		jsdom.env "#{gpBaseURL}#{@user}", (errors, window) =>
			# I'm pretty sure I'll go to hell for that!
			eval(
				window.document.getElementsByTagName('script')[5].innerHTML.replace(/window\.(.*?);/g, '')
			)
			@gpConfig = OZ_initData;
			callback.call(@)

	getProfile: ->
		webProfiles = []
		for profile in @gpConfig[5][2][11][0]
			webProfiles.push(
				name: profile[3]
				link: profile[1]
				favicon: profile[2]
			)
		
		userProfile =
			name:
				fist: @gpConfig[5][2][4][1]
				last: @gpConfig[5][2][4][1]
				full: @gpConfig[5][2][4][3]
			description: @gpConfig[5][2][33][1]
			webProfiles: webProfiles
				
			
	getPosts: ->
		posts = []
		for post in @gpConfig[4][0]
			posts.push(
				bodyHtml: post[4]
				bodyPlain: post[20]
			)
		return posts