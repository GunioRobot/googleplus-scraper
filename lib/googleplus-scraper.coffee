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
		employments = []
		for employment in @gpConfig[5][2][7][1]
			# TODO
			employments.push(employment)

		webProfiles = []
		for profile in @gpConfig[5][2][11][0]
			webProfiles.push(
				name: profile[3]
				link: profile[1]
				favicon: profile[2]
			) 
		
		userProfile =
			name:
				first: @gpConfig[5][2][4][1]
				last: @gpConfig[5][2][4][2]
				full: @gpConfig[5][2][4][3]
			description: @gpConfig[5][2][33][1]
			occupation: @gpConfig[5][2][6][1]
			employments: employments
			education: @gpConfig[5][2][8][1][0][0] if @gpConfig[5][2][8][1].length > 0
			places: @gpConfig[5][2][9][2]
			home:
				phone: 'n/a'
			work:
				phone: @gpConfig[5][2][13][1][0]
				email: @gpConfig[5][2][13][5][0]
			relationship: 'n/a'
			lookingFor: 'n/a'
			gender: 'n/a'
			birthday:  @gpConfig[5][2][16][1]
			alias: @gpConfig[5][2][47][1]
			webProfiles: webProfiles
			usersInCircles: 'n/a'
			havingUserInCircles: 'n/a'
			
			
	getPosts: ->
		posts = []
		for post in @gpConfig[4][0]
			posts.push(
				bodyHtml: post[4]
				bodyPlain: post[20]
			)
		return posts