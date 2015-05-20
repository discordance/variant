module.exports = {
    "style": "group_3", // .. tech_pi, break_bit, rock, group_0..8
    "shuffle": false, // shuffle
    "bpm": 120, // tempo
    "length": 8.0, // desired length in mins if possible
    "phrase": 8, // how many bars is a phrase
    "patterns": 4, // different beat main patterns
    "track_weights": [0, 6, 6, 1, 3, 2, 1], // importance of each track
    "track_lengths": [1, 1, 1, 1, 1, 1, 1], // length of each track, in bar
    "track_fades": [0.0, 0.5, 0.5, 0.5, 0.3, 0.5, 0.8], // chance to demute-fade per track
    "track_varys": [0.1, 0.3, 0.3, 0.8, 0.7, 0.7, 0.7], // chance to have a variation
    "evolution_curve": "bell1", // evolution curve
    "variation_time": 3, // pattern of variations, in bars
    "fills": 3,// number of different fills
    "fills_per_phrase": 2, // number of different fills in a phrase
    "variations_per_phrase": 2, // number of different variations in a phrase
    "presence_scale": 0.99,
    // goodies
    "groove": 0.0, // groove, mpc like
    "groove_kernel": "jam1", // groove recorded
    "groove_map": [0, 1, 2, 3, 4, 5, 6], // map tracks to grooves
    "groove_mod": 8, // groove loop
    "humanize": true, // makes the velocity less deterministic
    "humanize_rate": 0.1,
    "compress_kick": true,
    "tech_mode": false
}
