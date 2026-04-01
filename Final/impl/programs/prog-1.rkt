#lang s-exp "../lang.rkt"

(staff
  (chord A1 A2 A7)
  (chord B1)
  (chord A1 A2)


  ; B2 = 7 + 19 = 26
  (chord A1 A2 A7)
  (chord B2)
  (chord E1 E2)

  ; B3 = ADD B1 B2
  (chord A1 A2 A3)
  (chord B1 B2)
  (chord B3)

  ; Print B3 as int
  (chord A1 A2 A8)
  (chord B3)
  )