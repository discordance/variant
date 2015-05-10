###*
# @author Aymeric Nunge [dscrd]
#
# Utility functions and algorithms or other chunck og code that will never be used again in the package, but yet functionnal.
###


module.exports = {
  ###*
  # Lee distance.
  # Algorithm to compute string similarity score.
  ###
  lee: (s1, s2) ->
    n = s1.length
    m = s2.length
    q = 16
    i = 0
    sum = 0
    a = 0
    b = 0
    c = 0
    abs = Math.abs
    min = Math.min

    ### strings must be of equal size and non-zero length ###

    if n == 0 or n != m
      return -1.0
    i = 0
    while i < n
      a = parseInt(s1[i], 16)
      b = parseInt(s2[i], 16)
      c = abs(a - b)
      sum += min(c, q - c)
      i++
    sum

  ###*
  # Minkowski distance.
  # Algorithm to compute string similarity score.
  ###
  minkowski: (s1, s2) ->
    p = 1
    k = 0
    i = 0
    j = 0
    n = s1.length
    m = s2.length
    cost = 0
    d = []
    distance = 0
    a = 0
    b = 0
    uncost = 0
    pow = Math.pow
    abs = Math.abs
    min = Math.min
    max = Math.max
    c = 0
    #Step 1
    if n != 0 and m != 0
      d = []
      m++
      n++
      #Step 2
      k = 0
      while k < n
        d[k] = k
        k++
      k = 0
      while k < m
        d[k * n] = k
        k++
      #Step 3 and 4
      i = 1
      while i < n
              j = 1
        while j < m
          #Step 5
          uncost = pow(abs(parseInt(s1[i - 1], 16) - parseInt(s2[j - 1], 16)), p)
          if parseInt(s1[i - 1], 16) == parseInt(s2[j - 1], 16)
            cost = 0
          else
            cost = uncost
          #Step 6
          a = d[(j - 1) * n + i] + uncost
          b = d[j * n + i - 1] + uncost
          c = d[(j - 1) * n + i - 1] + cost
          d[j * n + i] = min(a, min(b, c))
          j++
        distance = d[n * m - 1]
        i++
      distance
    else
      max m, n

  ###*
  # Levenshtein distance.
  # Algorithm to compute string similarity score.
  ###
  levenshtein: (s1, s2) ->
    n = s1.length
    m = s2.length
    matrice = []
    i = 0
    j = 0
    min = Math.min
    res = 0

    ### strings must be of equal size and non-zero length ###

    if n == 0 or n != m
      return -1.0

    minimum = (arr) ->
      min.apply null, arr

    i = -1
    while i < n
      matrice[i] = []
      matrice[i][-1] = i + 1
      i++
    j = -1
    while j < m
      matrice[-1][j] = j + 1
      j++
    i = 0
    while i < n
          j = 0
      while j < m
        cout = if s1.charAt(i) == s2.charAt(j) then 0 else 1
        matrice[i][j] = minimum([
          1 + matrice[i][j - 1]
          1 + matrice[i - 1][j]
          cout + matrice[i - 1][j - 1]
        ])
        j++
      i++
    res = matrice[n - 1][m - 1]
    res / n

  ###*
  # Jaccard distance.
  # Algorithm to compute string similarity score.
  ###
  jaccard: (s1, s2) ->
    n = s1.length
    m = s2.length
    same = 0
    diff = 0
    ct = 0

    ### strings must be of equal size and non-zero length ###

    if n == 0 or n != m
      return -1.0
    if s1 == s2
      return 0
    while ct != n
      if s1[ct] == s2[ct]
        same++
      else
        diff++
      ct++
    1 - (same / (diff + same))


  wjaccard: (s1, s2) ->
    n = s1.length
    m = s2.length
    same = 0
    diff = 0
    abs = Math.abs
    pow = Math.pow
    a = 0
    b = 0
    ct = 0

    ### strings must be of equal size and non-zero length ###

    if n == 0 or n != m
      return -1.0
    if s1 == s2
      return 0
    while ct != n
      if s1[ct] == s2[ct]
        same++
      else
        a = pow(parseInt(s1[ct], 16), 2)
        b = pow(parseInt(s2[ct], 16), 2)
        diff += abs(a - b)
      ct++
    1 - (same / (diff + same))

}
