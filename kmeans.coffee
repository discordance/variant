fs = require 'fs'
_ = require 'lodash'
kMeans = require 'kmeans-js'

# load the patterns
fs.readFile './data/classified.json', 'utf8', (err, file)->
  beats = JSON.parse file
  unknows = beats.unknown

  analysis = []
  _.each unknows, (beat)->
    # relevant parts
    to_analysis = []
    # kick
    to_analysis = to_analysis.concat _.take beat[0], 16
    # snare
    to_analysis = to_analysis.concat _.take beat[3], 16
    # hh
    to_analysis = to_analysis.concat _.take beat[5], 16
    analysis.push to_analysis

  #console.log unknows.length
  km = new kMeans { K: 8 }
  km.cluster analysis

  while km.step()
    km.findClosestCentroids()
    km.moveCentroids()

    if km.hasConverged
      break

   _.each km.clusters, (klust, i)->
      gname = "group_#{i}"
      beats[gname] = []
      _.each klust, (unit)->
        beats[gname].push unknows[unit]

   delete beats['unknown']
   fs.writeFile './data/kmeaned.json', JSON.stringify(beats, null, 2), (err)->
      console.log 'kmeaned'
