Tag Map
======

Places Instagram activity on a map

This idea came from the [Mikva Challenge](http://www.mikvachallenge.org/) Juvenile Justice Council in Chicago. This is a simple application that monitors the Instagram API for images tagged with a particular string (currently '#mikva') and adds these images to a simple map.

## Why does this exist?

The plan is to use this application over the summer of 2014 in Chicago to highlight areas of the city where young people have been arrested (e.g. '#arrestedhere').

## Setup

Heroku is your friend with a [MongoHQ addon](https://addons.heroku.com/mongohq) and [Redis To Go](https://addons.heroku.com/redistogo). We're also using the [New Relic](https://addons.heroku.com/newrelic) addon for monitoring. There's a bunch of environment variables you need to configure:

```
INSTAGRAM_CLIENT_ID:      instagram-client-id
INSTAGRAM_CLIENT_SECRET:  instagram-secret
DOMAIN:                   my-app.herokuapp.com
HUB_TOKEN:                a-secure-token
MONGOHQ_URL:              mongodb://blah:blah@nosql.rules.com:1234/awesomeapp (set by the addon)
TAG                       'mikva'
REDISTOGO_URL             redis://redistogo... (also set by the addon)
NEW_RELIC_APP_NAME        Tag Map
NEW_RELIC_LICENSE_KEY     blahblahblah
```

## Enough, show me already!

Tag a photo with '#mikva', add a location and post to Instagram. Your photo *should* then turn up on [this map](http://tag-map.herokuapp.com/map). Note, it won't work if your Instagram feed is private.

![screen shot 2014-06-20 at 07 26 28](https://cloud.githubusercontent.com/assets/4483/3337108/d600b704-f844-11e3-852c-18e86c619a40.png)


## Prior art

Heavily influenced by this rather nice example application that makes working with the Instagram realtime API a little easier https://github.com/toctan/instahust
