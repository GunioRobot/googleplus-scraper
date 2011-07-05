googlePlusUserId = '100654235311706890740'

gp = require('./lib/googleplus-scraper.coffee').GooglePlusScraper googlePlusUserId, () =>
	console.log gp.getProfile()
	# console.log gp.getPosts()