fs = require 'fs'
_ = require 'lodash'

sections = require './lib/sections'

# load the patterns
fs.readFile './data/kmeaned.json', 'utf8', (err, file)->
  beats = JSON.parse file
  config = require './conf_exemple.js'

  # how many phrases needed ?
  c = (60/config.bpm)*4
  c = c*config.phrase
  c = Math.floor (config.length*60)/c

  # generate markov sections
  # according to the wanted
  # phrase number
  sections_g = sections(c)

  # randomly select a pattern base, according to the style
  len = beats[config.style].length
  base = beats[config.style][Math.floor Math.random()*len]

  if !base
    console.log "style probably wrong, no style ..."

  # select different possible patterns according to the config
  # max length of for a track, in bar
  max_trk_len = _.max config.track_lengths
  # how many block (loop of 1, 2 o more bars) per phrase ?
  blocks = config.phrase/max_trk_len
  # construct building blocks
  # -> {main: 1, variations: 2+, fills: 2+}






