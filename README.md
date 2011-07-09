# Google+ Scraper

Retrieve data from Google+ profiles with [NodeJS](http://nodejs.org/) and [CoffeeScript](http://jashkenas.github.com/coffee-script/).

The technique used is called “[web scraping](http://en.wikipedia.org/wiki/Web_scraping)”.
That means: If Google+ changes anything on their HTML, the script is going to fail.

**Note: This script is very very basic at the moment and very very beta.**  
It only took me a few minutes and is more a proof of concept. Of cause you're very welcome to contribute. ;-)


## Requirements

1. NodeJS: see https://github.com/joyent/node/wiki/Installation
2. npm: `$ curl http://npmjs.org/install.sh | sh`
3. CoffeeScript: `$ npm install -g coffee-script`
4. jsdom: `$ npm install jsdom`

Running `app.coffee` launches the server process. At the moment, profile information or posts are supported:

/[Google+ User ID]/                 — or —  
/[Google+ User ID]/profile          Return user's public profile  

/[Google+ User ID]/posts            Return user's posts  


## How it works

Instead of scraping the HTML code itself, this script fights its way through `OZ_initData`, a big, mean and ugly inline JavaScript array containing the profile information.


## License

(The MIT-License)

Copyright (c) 2011 Frederic Hemberger

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.