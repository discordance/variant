MIDI = require 'midijs'
File = MIDI.File
Fs = require 'fs'
Eden = require 'node-eden'
_ = require './lodash_extended'

# load the grooves
grooves = require '../data/grooves.json'


module.exports = (song, config)->

  # setup tracks and header
  sixth = 32*4
  file = new File()
  file.getHeader().setTicksPerBeat(128*4)
  for i in [0..7]
    file.addTrack i

  counter = 0
  _.each song, (section, i)->

    # iterates through tracks
     _.each section, (track, j)->
        track_events = []

        # store last drift for groove kernels
        last_drift = 0
        # iterates through steps
        _.each track, (step, k)->
          # get note
          getnote = (note, step, track, delta, type = File.ChannelEvent.TYPE.NOTE_ON)->
            return new File.ChannelEvent(type, {
              note: note
              velocity: Math.floor step*127
            }, track, delta)

          # normal groove
          if !config.groove_kernel
            if step
              if !(k%2)
                track_events.push getnote(64, step, j, 0, File.ChannelEvent.TYPE.NOTE_ON)
                track_events.push getnote(64, step, j, sixth+(sixth*config.groove), File.ChannelEvent.TYPE.NOTE_OFF)
              else
                track_events.push getnote(64, step, j, 0, File.ChannelEvent.TYPE.NOTE_ON)
                track_events.push getnote(64, step, j, sixth-(sixth*config.groove)+1, File.ChannelEvent.TYPE.NOTE_OFF)
            else
              if !(k%2)
                track_events.push getnote(64, step, j, 0, File.ChannelEvent.TYPE.NOTE_OFF)
                track_events.push getnote(64, step, j, sixth+(sixth*config.groove), File.ChannelEvent.TYPE.NOTE_OFF)
              else
                track_events.push getnote(64, step, j, 0, File.ChannelEvent.TYPE.NOTE_OFF)
                track_events.push getnote(64, step, j, sixth-(sixth*config.groove)+1, File.ChannelEvent.TYPE.NOTE_OFF)

          # kernel groove
          else
            groove = grooves[config.groove_kernel]
            next_drift = groove[(k+1)%groove.length][config.groove_map[j]%groove.length]

            if step
              track_events.push getnote(64, step, j, 0, File.ChannelEvent.TYPE.NOTE_ON)
              track_events.push getnote(64, step, j, sixth+(sixth*next_drift)-(sixth*last_drift), File.ChannelEvent.TYPE.NOTE_OFF)
            else
              track_events.push getnote(64, step, j, 0, File.ChannelEvent.TYPE.NOTE_OFF)
              track_events.push getnote(64, step, j, sixth+(sixth*next_drift)-(sixth*last_drift), File.ChannelEvent.TYPE.NOTE_OFF)

            last_drift = next_drift

          # end song
          if i is song.length-1 and k is track.length-1
            track_events.push new File.MetaEvent(File.MetaEvent.TYPE.END_OF_TRACK)


        file.getTrack(j)._events = file.getTrack(j)._events.concat track_events

  file.getData (err, data) ->
    if err
      throw err
    Fs.writeFile './data/rendered/'+Eden.eve()+'.mid', data, (err) ->
      if err
        throw err
