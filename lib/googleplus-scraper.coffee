request= require 'request'

class exports.GooglePlusScraper
  gpBaseURL = 'https://plus.google.com/'
  gpConfig = null

  constructor: (@user, callback) ->
    return new GooglePlusScraper(@user, callback) if !(this instanceof GooglePlusScraper)
    
    request {uri: "#{gpBaseURL}#{@user}"}, (err, res, body) ->
      gpConfig = body.match(/OZ_initData = {[\u000a\u000d\u2028\u2029\w\W]+?}/m)
      if gpConfig[0]
        # Must be eval()'ed as it's not valid JSON. Bummer.
        eval(gpConfig[0])
        callback(null, OZ_initData)
      else
        callback(err)


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
        fist:              data[5][2][4][1]
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
      places:
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
      relationship:        'tbd'
      lookingFor:          'tbd'
      gender:              gender[data[5][2][17][1]]
      birthday:            data[5][2][16][1]
      webProfiles:         webProfiles
      usersInCircles:      data[5][3][2][1]
      havingUserInCircles: 'tbd'
      photos:              data[5][10][3]
      
      
  getPosts: (data) ->
    posts = []
    for post in data[4][0]
      posts.push(
        permalink:   gpBaseURL + post[21]
        bodyHtml:    post[4]
        bodyPlain:   post[20]
        attachments: post[66]
      )
    return posts
