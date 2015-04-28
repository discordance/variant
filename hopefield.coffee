fs = require 'fs'
synaptic = require 'synaptic'
_ = require 'lodash'

Trainer = synaptic.Trainer
Architect = synaptic.Architect

tech_house = [
  1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,
  0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,
  0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0
]

tech_pi = [
  1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,
  0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,
  1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
]

break_bit = [
  1,0,0,0,0,0,0,1,0,1,0,0,0,1,0,0,
  0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,
  0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0
]

rock = [
  1,0,0,0,0,0,0,0,1,0,1,0,0,0,0,0,
  0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,
  1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0
]

chaos = [
  0,0,0,1,0,0,0,1,1,1,0,0,0,1,0,0,
  0,0,1,0,1,0,0,0,0,0,0,0,1,1,0,0,
  0,0,1,0,0,1,1,0,0,0,0,0,0,0,0,0
]

map = {}
map[tech_house.toString()] = 'tech_house'
map[tech_pi.toString()] = 'tech_pi'
map[break_bit.toString()] = 'break_bit'
map[rock.toString()] = 'rock'
map[chaos.toString()] = 'chaos'

# load the data to classify
hopfield = new Architect.Hopfield(48)
hopfield.learn [tech_house,
                tech_pi,
                break_bit,
                rock,
                chaos]


# load the patterns
fs.readFile './data/labelized_1307.json', 'utf8', (err, file)->
  beats = JSON.parse file

  classified =
    tech_house:[]
    tech_pi:[]
    break_bit:[]
    rock:[]
    chaos:[]
    unknown:[]

  _.each beats, (beat)->
    # relevant parts
    to_analysis = []
    # kick
    to_analysis = to_analysis.concat _.take beat[0], 16
    # snare
    to_analysis = to_analysis.concat _.take beat[3], 16
    # hh
    to_analysis = to_analysis.concat _.take beat[5], 16

    type = map[hopfield.feed(to_analysis).toString()]
    if !type
      classified.unknown.push beat
    else
      classified[type].push beat

  console.log classified
  fs.writeFile './data/classified.json', JSON.stringify(classified), (err)->
    console.log 'classified'

