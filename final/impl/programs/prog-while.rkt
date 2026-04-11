#lang s-exp "../lang.rkt"

(staff

  ; ESTABLISH (B1, B2)
  ; i.e., to set both of them to 1
  (chord A3 A4 A5)
  (chord B1 B2)

  ; B1 = ADD B1 B1, repeat 3 times
  (chord A1 A2 A3) ; B1 = ADD B1 B1
  (chord B1 B1)
  (chord B1)

  (chord A1 A2 A3) ; B1 = ADD B1 B1
  (chord B1 B1)
  (chord B1)

  (chord A1 A2 A3) ; B1 = ADD B1 B1
  (chord B1 B1)
  (chord B1)


  (chord B1 B2 B3) ; WHILE
  (chord B1) ; loop until C1 is zero

  (chord B2 B3 B4) ; WHILE_BODY

  (chord A1 A2 A8) ; PRINT_INT B1
  (chord B1)

  (chord A1 A2 A4) ; B1 = SUB B1 B2
  (chord B1 B2)
  (chord B1)

  (chord B3 B4 B5) ; END_WHILE

  )

