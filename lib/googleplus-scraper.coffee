request = require 'request'

shorten = (text, chars) ->
  if text.length >= chars - 2
    text = text.substr(0, chars - 2)
    
    # To avoid cutting words in half, string will be shortend to the last word delimiter
    lastSpace = text.lastIndexOf(' ')
    text = text.substring(0, lastSpace) + ' …' if lastSpace isnt -1
  text


pad = (value, len) ->
  value = value.toString()
  new Array(len - value.length + 1).join('0') + value


Date::toRFCString = ->
  "#{pad(@getFullYear(), 4)}-#{pad(@getMonth()+1, 2)}-#{pad(@getDate(), 2)}T#{pad(@getHours(), 2)}:#{pad(@getMinutes(), 2)}:#{pad(@getSeconds(), 2)}Z"


class exports.GooglePlusScraper
  gpBaseURL = 'https://plus.google.com/'

  constructor: (@user, callback) ->
    return new GooglePlusScraper(@user, callback) if !(this instanceof GooglePlusScraper)

    request {uri: "#{gpBaseURL}#{@user}"}, (err, res, body) ->
      err = if res.statusCode is 200 then err else res.statusCode
      if err
        callback(err)
        return
      
      gpConfig = body.match(/OZ_initData = {[\u000a\u000d\u2028\u2029\w\W]+?}/m)
      if not gpConfig or not gpConfig[0]
        callback('Could not load Google+ data') 
        return

      # Must be eval()'ed as it's not valid JSON. Bummer.
      eval(gpConfig[0])
      callback(null, OZ_initData)


  getProfile: (data) ->
    gender = ['', 'male', 'female', 'other'];

    resolveChatServices = (chatIds) ->
      chatServices = ['', '', 'AIM', 'MSN', 'Yahoo', 'Skype', 'QQ', 'Google Talk', 'ICQ', 'Jabber', 'Net Meeting']
      chats = []
      for chat in chatIds
        chats.push(
          service: chatServices[chat[1]]
          id: chat[0]
        )
      return chats


    employmentItems = []
    for employment in data[5][2][7][1]
      employmentItems.push(
        employer: employment[0]
        position: employment[1]
        date:
          start:  employment[2][0]
          end:    employment[2][1]
      )

    educationItems = []
    for education in data[5][2][8][1]
      educationItems.push(
        education: education[0]
        major:     education[1]
        date:
          start:   education[2][0]
          end:     education[2][1]
      )

    webProfiles = []
    for profile in data[5][2][11][0]
      webProfiles.push(
        name:    profile[3]
        link:    profile[1]
        favicon: profile[2]
        rel:     profile[4]
      )


    userProfile =
      id:                  data[5][2][30]
      tagline:             data[5][2][33][1]
      name:
        first:             data[5][2][4][1]
        last:              data[5][2][4][2]
        full:              data[5][2][4][3]
        other:             data[5][2][5][1]
        nickname:          data[5][2][47][1]
      profilePic:          data[5][2][3]
      introduction:        data[5][2][14][1]
      braggingRights:      data[5][2][19][1]
      occupation:          data[5][2][6][1]
      employment:          employmentItems
      education:           educationItems
      places: if not data[5][2][9][2] or data[5][2][9][2].length is 0 then [] else
        names:             data[5][2][9][2]
        map:               data[5][2][10]
      home:
        phone:             data[5][2][12][1]
        mobile:            data[5][2][12][2]
        fax:               data[5][2][12][3]
        pager:             data[5][2][12][4]
        email:             data[5][2][12][5]
        address:           data[5][2][12][6]
        chat:              resolveChatServices(data[5][2][12][7])
      work:
        phone:             data[5][2][13][1]
        mobile:            data[5][2][13][2]
        fax:               data[5][2][13][3]
        pager:             data[5][2][13][4]
        email:             data[5][2][13][5]
        address:           data[5][2][13][6]
        chat:              resolveChatServices(data[5][2][13][7])
      relationship:        null
      lookingFor:          null
      gender:              gender[data[5][2][17][1]]
      birthday:            data[5][2][16][1]
      webProfiles:         webProfiles
      usersInCircles: if not data[5][3] or not data[5][3][0] or data[5][3][0].length is 0 then [] else
        count:             data[5][3][0][0]
        randomUsers:       data[5][3][0][1]
        allUsers:          "//plus.google.com/_/socialgraph/lookup/visible/?o=%5Bnull%2Cnull%2C%22#{@user}%22%5D&n=100000"
      havingUserInCircles: if not data[5][3] or not data[5][3][2] or data[5][3][2].length is 0 then [] else
        count:             data[5][3][2][0]
        randomUsers:       data[5][3][2][1]
        allUsers:          "//plus.google.com/_/socialgraph/lookup/incoming/?o=%5Bnull%2Cnull%2C%22#{@user}%22%5D&n=100000"
      photos:              data[5][10][3]


  getPosts: (data) ->
    posts = []
    for post in data[4][0]
      posts.push(
        permalink:      gpBaseURL + post[21]
        date:
          epoch:        post[5]
          utc:          new Date(post[5]).toUTCString()
          rfc:          new Date(post[5]).toRFCString()
        title:          shorten post[20], 120
        bodyHtml:       post[4]
        bodyPlain:      post[20]
        attachments:    post[66]
        votes:          post[73][16]
        sharedBy:       post[25]
        latestComments: post[7]
      )
    return posts