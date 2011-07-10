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
      callback()


  getProfile: ->
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
    for employment in @gpConfig[5][2][7][1]
      employmentItems.push(
        employer: employment[0]
        position: employment[1]
        date:
          start:  employment[2][0]
          end:    employment[2][1]
      )

    educationItems = []
    for education in @gpConfig[5][2][8][1]
      educationItems.push(
        education: education[0]
        major:     education[1]
        date:
          start:   education[2][0]
          end:     education[2][1]
      )

    webProfiles = []
    for profile in @gpConfig[5][2][11][0]
      webProfiles.push(
        name:    profile[3]
        link:    profile[1]
        favicon: profile[2]
        rel:     profile[4]
      ) 
    
    userProfile =
      id:                  @gpConfig[5][2][30]
      tagline:             @gpConfig[5][2][33][1]
      name:
        fist:              @gpConfig[5][2][4][1]
        last:              @gpConfig[5][2][4][2]
        full:              @gpConfig[5][2][4][3]
        other:             @gpConfig[5][2][5][1]
        nickname:          @gpConfig[5][2][47][1]
      profilePic:          @gpConfig[5][2][3]
      introduction:        @gpConfig[5][2][14][1]
      braggingRights:      @gpConfig[5][2][19][1]
      occupation:          @gpConfig[5][2][6][1]
      employment:          employmentItems
      education:           educationItems
      places:
        names:             @gpConfig[5][2][9][2]
        map:               @gpConfig[5][2][10]
      home:
        phone:             @gpConfig[5][2][12][1]
        mobile:            @gpConfig[5][2][12][2]
        fax:               @gpConfig[5][2][12][3]
        pager:             @gpConfig[5][2][12][4]
        email:             @gpConfig[5][2][12][5]
        address:           @gpConfig[5][2][12][6]
        chat:              resolveChatServices(@gpConfig[5][2][12][7])
      work:
        phone:             @gpConfig[5][2][13][1]
        mobile:            @gpConfig[5][2][13][2]
        fax:               @gpConfig[5][2][13][3]
        pager:             @gpConfig[5][2][13][4]
        email:             @gpConfig[5][2][13][5]
        address:           @gpConfig[5][2][13][6]
        chat:              resolveChatServices(@gpConfig[5][2][13][7])
      relationship:        'tbd'
      lookingFor:          'tbd'
      gender:              gender[@gpConfig[5][2][17][1]]
      birthday:            @gpConfig[5][2][16][1]
      webProfiles:         webProfiles
      usersInCircles:      @gpConfig[5][3][2][1]
      havingUserInCircles: 'tbd'
      photos:              @gpConfig[5][10][3]
      
      
  getPosts: ->
    posts = []
    for post in @gpConfig[4][0]
      posts.push(
        permalink: gpBaseURL + post[21]
        bodyHtml: post[4]
        bodyPlain: post[20]
        attachments: post[66]
      )
    return posts
