Fs = require 'fs'
_ = require 'lodash'
synaptic = require 'synaptic'

Trainer = synaptic.Trainer
Architect = synaptic.Architect

MIDI = require 'midijs'
File = MIDI.File


# the big function
extract_groove = (data)->

  file = new MIDI.File data
  per_sixtheens = file.getHeader().getTicksPerBeat()/4

  track = file.getTrack(0).getEvents()

  ct = 0
  while !(_.where(track,{type:9})).length
    ct++
    track = file.getTrack(ct).getEvents()

  track = _.filter track, (onset)->
    return onset.type is 9 or onset.type is 8

  ct = 0
  track.map (onset)->
    ct += onset.delay
    onset.time = ct

  track = _.filter track, (onset)->
    return onset.type is 9

  # partition
  groove_map = {}
  partitions = _.groupBy track, 'note'

  for k,v of partitions
    if !groove_map[k]
      groove_map[k] = (0 for i in [0..(_.last(partitions[k]).time/per_sixtheens)])

    _.each partitions[k], (onset)->
      curr = onset.time/per_sixtheens
      last = Math.floor(onset.time/per_sixtheens)
      next = Math.ceil(onset.time/per_sixtheens)
      ld = curr-last
      rd = next-curr

      if rd < ld
        groove_map[k][next] = -rd
      else if ld <= rd
        groove_map[k][last] = ld


  sample_size = 64
  sizes = []
  # cut to good length
  for k, v of groove_map
    if groove_map[k].length >= 64
      groove_map[k] = _.take groove_map[k], 64
      sizes.push 64
    else if groove_map[k].length >= 32 and groove_map[k].length < 64
      groove_map[k] = _.take groove_map[k], 32
      sample_size = 32
      sizes.push 32
    else if groove_map[k].length >= 16 and groove_map[k].length < 32
      groove_map[k] = _.take groove_map[k], 16
      sample_size = 16
      sizes.push 16
    else
      groove_map[k] = _.take groove_map[k], 8
      sample_size = 8
      sizes.push 8


  groove_set = null

  for k, v of groove_map
    if !groove_set
      groove_set = ([] for i in [0..(_.max(sizes))-1])
    _.each groove_map[k], (drift, i)->
      groove_set[i].push drift


  # normalize
  beg_size = groove_set[0].length
  groove_set.map (step)->
    while step.length < beg_size
      step.push 0
    step

  return groove_set

# get all the midi files
Fs.readdir './data/midi/', (err, files)->
  files = _.filter files, (file)->
    return file isnt '.DS_Store'

  grooves = {}
  _.each files, (file)->

    midi_data = Fs.readFileSync './data/midi/'+file

    set = extract_groove midi_data
    name = file.split('.')[0]
    grooves[name] = set

  if grooves
    Fs.writeFileSync './data/grooves.json', JSON.stringify(grooves, null, 2)









