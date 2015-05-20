fs = require 'fs'
_ = require './lib/lodash_extended'


sections = require './lib/sections'
tools = require './lib/tools'
markov = require './markov'

midi = require './lib/midi_export'

# load the patterns
fs.readFile './data/kmeaned.json', 'utf8', (err, file)->
  beats = JSON.parse file
  config = require './conf.js'

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

  # shuffle base
  if config.shuffle
    rebase = []
    _.each base, (track, i)->
      chunks = _.chunk track, 16
      chunks = _.shuffle chunks
      flat = _.flatten chunks
      # not on the kick
      if i
        rebase.push flat
      else
        rebase.push track

    base = rebase

  # select different possible patterns according to the config
  # max length of for a track, in bar
  max_trk_len = _.max config.track_lengths
  # how many block (loop of 1, 2 o more bars) per phrase ?
  blocks = config.phrase/max_trk_len
  # construct building blocks
  # -> {main: 1, variations: 1+, fills: 1+}
  # pats is selected uniq chuncks to build
  pats = []
  fills = []

  # mains, picked random in patterns from db
  for i in [0..config.patterns-1]
    rnd = _.random 0, 7
    while rnd in pats
      rnd = _.random 0, 7
    pats.push rnd
  # fills
  for i in [0..config.fills-1]
    rnd = _.random 0, 7
    while rnd in pats or rnd in fills
      rnd = _.random 0, 7
    fills.push rnd

  # make blocks, main or fills
  make_blocks = (pats)->
    blocks = []
    # make blocks, according to each track loop length in bar
    _.each pats, (pat)->
      block = []
      _.each config.track_lengths, (length, i)->
        # chunk by 16
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


  # build the complete blocks
  mains_pats = make_blocks(pats)
  fills_pats = make_blocks(fills)

  # create the blocks
  create_blocks = (mains_pats)->
    blocks = []
    _.each mains_pats, (main) ->
      # main and fills
      block = {main:main, fills:[], variations: []}
      while block.fills.length < config.fills_per_phrase
        block.fills.push _.sample fills_pats
      # variations
      while block.variations.length < config.variations_per_phrase
        block.variations.push tools.variation(main, block.fills, config)
      # block is ready
      blocks.push block
    return blocks

  # call blocks creation
  blocks = create_blocks mains_pats

  # create sections with tracks
  create_section = (blocks, config)->
    section_build = []
    # which main ?
    pattern_iterator = 0
    # which fill ?
    fill_iterator = 0
    # which var ?
    var_iterator = 0

    _.each sections_g, (section, i)->
      # pre build tracks
      section_tracks = ([] for t in [0..6])
      # build section
      block = blocks[pattern_iterator%config.patterns]

      for it in [0..config.phrase-1]
        # which chunk of patterns
        chunk = it%max_trk_len

        if !((it+1)%config.variation_time) and (it isnt config.phrase-1) # variation
          _.each block.variations[var_iterator%block.variations.length], (tr, k)->
            section_tracks[k] = section_tracks[k].concat _.chunk(tr, 16)[chunk]

        # @TODO ouais ..
        else if it is config.phrase-1
          _.each block.fills[fill_iterator%block.fills.length], (tr, k)->
            section_tracks[k] = section_tracks[k].concat _.chunk(tr, 16)[chunk]

        else
          _.each block.main, (tr, k)->
            section_tracks[k] = section_tracks[k].concat _.chunk(tr, 16)[chunk]

      # change iterators
      # pattern according to markov
      if Math.random() < markov.new_pattern_section[section]
        pattern_iterator++
      if Math.random() < markov.new_pattern_section[section]*2
        fill_iterator++
        var_iterator++

      # manage mutes per sections
      _.each section_tracks, (track, ti)->
        # scaled matrix
        mat = tools.scale_matrix markov.track_presence, config.presence_scale
        if Math.random() > mat[config.track_weights[ti]][section]
          section_tracks[ti] = (0 for step in [0..section_tracks[ti].length-1])

      section_build.push section_tracks

    return section_build
  # call section filling
  song = create_section blocks, config

  # some candies
  # humanize
  humanize = (song, config)->
    n_song = []
    _.each song, (section)->
      n_section = []
      _.each section, (track)->
        n_track = []
        _.each track, (step)->
          if step
            hum = tools.normalRand step, config.humanize_rate
            n_track.push _.clamp hum, 0, 1
          else
            n_track.push 0
        n_section.push n_track
      n_song.push n_section
    return n_song

  # humanize a bit
  if config.humanize
    song = humanize song, config


  # is the track muted ?
  is_mute = (track)->
    answer = true
    _.each track, (step)->
      if step
        answer = false
    return answer

  # create fades
  create_fades = (song, config)->
    chunks = _.chunk song, 2
    c = 0
    _.each chunks, (pair)->
      if pair[1] # can be an odd number
        _.each pair[0], (track0, i)->
          if is_mute(track0) and !is_mute(pair[1][i])
            if Math.random() < config.track_fades[i]
              ipolated = _.clone pair[1][i]
              _.each ipolated, (step, j)->
                if step
                  ipolated[j] = tools.map j, 0, ipolated.length, 0, 0.75
              # replace
              song[c][i] = ipolated
        c += 2

  # fadin
  create_fades song, config

  # compress
  compress = (track, tech_mode = false)->
    ratios = [1, 0.5, 0.75, 0.5]
    ratios_tech = [1, 0, 0.5, 0]
    n_track = []
    _.each track, (step, i)->
      if step
        if !tech_mode
          comp = (ratios[i%4]-step)/2
          n_track.push step+comp
        else
          comp = (ratios_tech[i%4]-step)/2
          n_track.push step+comp
      else
        if !(i%4) and tech_mode and !is_mute(track)
          n_track.push 1
        else n_track.push 0

    return n_track

  # apply compress and tech mode
  if config.compress_kick
    _.each song, (section, i)->
      song[i][0] = compress song[i][0], config.tech_mode

  # generate midi
  midi song, config
















