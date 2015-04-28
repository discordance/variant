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
  #console.log c

  sections_g = sections(c)
  console.log sections_g


