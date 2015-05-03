module.exports = {
  # transitions, building sections
  sections: [
    # A    # B   # C   # D   # E
    [1.00, 0.00, 0.00, 0.00, 0.00],# A
    [0.35, 0.60, 0.05, 0.00, 0.00],# B
    [0.00, 0.10, 0.70, 0.20, 0.00],# C
    [0.00, 0.11, 0.31, 0.57, 0.01],# D
    [0.00, 0.00, 0.26, 0.02, 0.72] # E
  ],
  # for each section, track presence rates
  # for now this is a test
  track_presence: [
    # A    # B   # C   # D   # E
    [0.80, 1.00, 1.00, 0.42, 0.90],# 0
    [0.22, 0.85, 0.95, 0.50, 0.25],# 1
    [0.32, 0.55, 0.75, 0.75, 0.30],# 2
    [0.15, 0.22, 0.95, 0.67, 0.50],# 3
    [0.55, 0.65, 0.25, 0.75, 0.68],# 4
    [0.50, 0.35, 0.15, 0.80, 0.70],# 5
    [0.25, 0.25, 0.10, 0.90, 0.25] # 6
  ],
  # probability of new pattern appearing in one section
                       # A    # B   # C   # D   # E
  new_pattern_section: [0.40, 0.15, 0.04, 0.12, 0.07],

  # Probability distributions for new patterns occurring
  # in the first phrase of a section
  new_pattern_phrase: [
    # A    # B   # C   # D   # E
    [0.90, 0.85, 0.93, 0.72, 0.41], # beginning
    [0.10, 0.05, 0.03, 0.07, 0.17], # middle
    [0.00, 0.10, 0.04, 0.21, 0.41]  # end
  ]
}
