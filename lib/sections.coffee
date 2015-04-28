_ = require 'lodash'

module.exports = (phrases)->

  transitions = [
    # A   # B  # C  # D  # E
    [1.00, 0.00, 0.00, 0.00, 0.00],# A
    [0.35, 0.60, 0.05, 0.00, 0.00],# B
    [0.00, 0.10, 0.70, 0.20, 0.00],# C
    [0.00, 0.11, 0.31, 0.57, 0.01],# D
    [0.00, 0.00, 0.26, 0.02, 0.72],# E
  ]

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
    return true if kickin_ratio < 0.2 and out_ratio < 0.2 and break_ratio < 2.0
    return false

  generated = generate()
  while !isLegit(generated)
    generated = generate()

  return generated
