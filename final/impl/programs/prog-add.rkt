#lang s-exp "../lang.rkt"


(staff
  (chord D2 E2 F2) ; CMD_ESTABLISH
  (chord D#1 D2 D3 D4)

  (chord C2 D2 E2) ; CMD_ADD
  (chord D#1 D2)
  (chord D4)
  
  (chord E2 F2 G2) ; CMD_PRINT_INT
  (chord D4))
