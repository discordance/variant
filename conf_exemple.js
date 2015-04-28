module.exports = {
  "style":"tech_house", // .. tech_pi, break_bit, rock, group_0..8
  "bpm": 120, // tempo
  "length": 8.0, // desired length in mins if possible
  "phrase": 8, // how many bars is a phrase
  "patterns": 2, // different beat main patterns
  "track_weights": [1.0, 0.1, 0.2, 0.5, 0.3, 0.8, 0.4], // ratio of importance of each tracks
  "fade_weight": [0.0, 0.1, 0.1, 0.2, 0.7, 0.2, 0.8], // chance to demute-fade per track
  "evolution_curve": "bell1", // evolution curve
  "variation_pat": [3,1], // pattern of variations, in bars
  "fills_per_phrase": 1, // number of fills in a phrase
  "groove": 0.0, // groove, mpc like
}
