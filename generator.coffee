fs = require 'fs'
_ = require 'lodash'

sections = require './lib/sections'
tools = require './lib/tools'

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
  # pats is selected uniq chuncks to build
  pats = []
  fills = []

  # mains
  for i in [0..config.patterns-1]
    rnd = tools.randInt 0, 7
    while rnd in pats
      rnd = tools.randInt 0, 7
    pats.push rnd
  # fills
  for i in [0..config.fills-1]
    rnd = tools.randInt 0, 7
    while rnd in pats or rnd in fills
      rnd = tools.randInt 0, 7
    fills.push rnd

  # make blocks, main or fills
  make_blocks = (pats)->
    blocks = []
    # make blocks, according to each track loop length in bar
    _.each pats, (pat)->
      block = []
      _.each config.track_lengths, (length, i)->
        # chunk by 16
        #@TODO scramble chunks ?
        chunks = _.chunk base[i], 16
        # we start at pat and take length to merge
        ct = 0
        res = []
        while ct < length
          if pat+ct < chunks.length
            res = res.concat chunks[pat+ct]
          else
            res = res.concat chunks[pat]
          ct++
        if res.length < max_trk_len*16
          while res.length < max_trk_len*16
            res = res.concat res
        block.push res
      blocks.push block
    return blocks


  blocks = []
  # build the complete blocks
  mains_pats = make_blocks(pats)
  fills_pats = make_blocks(fills)

  _.each mains_pats, (main) ->
    # create variation function
    variation = (mn, fll)->
      variation = []
      _.each mn, (track, i)->
        # chance to vary
        if Math.random() < config.track_varys[i]
          console.log "var", i
        else
          variation.push track
          console.log track.length


    # main and fills
    block = {main:main, fills:[]}
    while block.fills.length < config.fills_per_phrase
      block.fills.push tools.randItem fills_pats
    # variations
    variation main, tools.randItem block.fills










