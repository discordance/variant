_ = require 'lodash'

module.exports = (phrases)->

  transitions = require('../markov').sections

  # make the markov choice tables
  balls = []
  for step in transitions
    ball_r = []
    for prob, j in step
      for i in [0..(Math.round(prob*95))]
        ball_r.push j
    balls.push ball_r

  # generate form with markov sections arrays
  generate = ()->
    sections = []
    needed = phrases
    current_section = 4

    while needed and current_section >= 0

      idx = Math.floor(Math.random()*balls[current_section].length)
      balls[current_section][idx]
      current_section = balls[current_section][idx]
      sections.push current_section
      needed--
    return sections.reverse()

  # is legit form ?
  isLegit = (sections)->
    kickin_ratio = (_.filter sections, (d)-> d is 0).length / sections.length
    out_ratio = (_.filter sections, (d)-> d is 4).length / sections.length
    break_ratio = (_.filter sections, (d)-> d is 3).length / sections.length
    return true if kickin_ratio < 0.2 and out_ratio < 0.25 and break_ratio < 0.22
    return false

  generated = generate()
  while !isLegit(generated)
    generated = generate()

  return generated
