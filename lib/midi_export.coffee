MIDI = require 'midijs'
File = MIDI.File
Fs = require 'fs'
_ = require './lodash_extended'

module.exports = (song, config)->
  # setup tracks and header
  file = new File()
  file.getHeader().setTicksPerBeat(128)
  for i in [0..7]
    file.addTrack i

  # 32 is one 16th note
  #
  counter = 0
  _.each song, (section, i)->
     _.each section, (track, j)->
        track_events = []
        _.each track, (step, k)->
          # get note
          getnote = (note, step, track, delta, type = File.ChannelEvent.TYPE.NOTE_ON)->
            return new File.ChannelEvent(type, {
              note: note
              velocity: Math.floor step*127
            }, track, delta)

          if step
            if !(k%2)
              track_events.push getnote(64, step, j, 0, File.ChannelEvent.TYPE.NOTE_ON)
              track_events.push getnote(64, step, j, 32+(32*config.groove), File.ChannelEvent.TYPE.NOTE_OFF)
            else
              track_events.push getnote(64, step, j, 0, File.ChannelEvent.TYPE.NOTE_ON)
              track_events.push getnote(64, step, j, 32-(32*config.groove)+1, File.ChannelEvent.TYPE.NOTE_OFF)
          else
            if !(k%2)
              track_events.push getnote(64, step, j, 0, File.ChannelEvent.TYPE.NOTE_OFF)
              track_events.push getnote(64, step, j, 32+(32*config.groove), File.ChannelEvent.TYPE.NOTE_OFF)
            else
              track_events.push getnote(64, step, j, 0, File.ChannelEvent.TYPE.NOTE_OFF)
              track_events.push getnote(64, step, j, 32-(32*config.groove)+1, File.ChannelEvent.TYPE.NOTE_OFF)

          if i is song.length-1 and k is track.length-1
            track_events.push new File.MetaEvent(File.MetaEvent.TYPE.END_OF_TRACK)


        file.getTrack(j)._events = file.getTrack(j)._events.concat track_events

  file.getData (err, data) ->
    if err
      throw err
    Fs.writeFile 'test.mid', data, (err) ->
      if err
        throw err
