module.exports =
  # random integer in a scale
  randInt: (min, max) ->
    Math.floor Math.random() * (max - min + 1) + min
  # random array item
  randItem: (arr)->
    idx = Math.floor Math.random()*arr.length
    arr[idx]
