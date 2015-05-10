_ = require 'lodash'

module.exports = {

  # generate a random from gaussian
  normalRand: (mean, stdev)->
    random = Math.random
    rnd = random() * 2 - 1 + random() * 2 - 1 + random() * 2 - 1
    rnd * stdev + mean

  # create variation function
  variation: (mn, flls, config)->
    # strategies
    cherry_pick = (track, fill)->
      chk_sizes = []
      s = 4
      while s < fill.length
        chk_sizes.push s
        s = s*2
      s = _.sample chk_sizes
      inv_s = track.length - s
      res = _.take(track, s).concat(_.takeRight(fill, inv_s))
      return res

    variations = []
    _.each mn, (track, i)->
      # chance to vary
      if Math.random() < config.track_varys[i]
        #@TODO integrate delay ?
        variations.push cherry_pick track, _.sample(flls)[i]
      else
        variations.push track
    return variations

  # processing-like map
  map: (value, start1, stop1, start2, stop2) ->
    start2 + (stop2 - start2) * (value - start1) / (stop1 - start1)

  # add delay on a track
  delay: (track, timediv = 2, fade = 0.5)->
    map_func = @map
    new_track = _.clone track
    _.each track, (step_vel, i) ->
      if step_vel
        delay_line = []
        max_step = i + Math.ceil(fade*track.length)
        steps = max_step - i
        ct = 0
        while ct <= steps
          vel = map_func ct, 0, steps, step_vel, 0
          if !(ct % timediv)
            delay_line.push vel
          else
            delay_line.push 0
          ct++
        # merge
        _.each delay_line, (dly_step, j)->
          new_track[(i+j)%track.length] = _.max([new_track[(i+j)%track.length], dly_step])

     return new_track
}
