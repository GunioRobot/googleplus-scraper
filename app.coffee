googlePlusUserId = 'INSERT_GOOGLE+_ID'

gp = require('./lib/googleplus-scraper.coffee').GooglePlusScraper googlePlusUserId, () =>
	console.log gp.getProfile()
	console.log gp.getPosts()