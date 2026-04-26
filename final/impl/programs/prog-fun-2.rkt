#lang s-exp "../lang.rkt"


(staff
  (chord D2 E2 F2) ; ESTABLISH
  (chord D1 D2 D3 D4)
  (chord B3 C3 D3) ; START_FUNC_DEF
  (chord C6 C7)
  (chord E3 E4)
    (chord B3 C3 D3) ; START_FUNC_DEF
    (chord E6 E7)
    (chord A1 A2)
    (chord C2 D2 E2) ; ADD
    (chord A1 A2)
    (chord C7)
    (chord B3 D3 E3) ; END_FUNC_DEF
    (chord C7)
  (chord E6 E7)
  (chord E3 E4)
  (chord C7)
  (chord B3 D3 E3) ; END_FUNC_DEF
  (chord C7)
  (chord C6 C7)
  (chord D1 D2)
  (chord D4)
  (chord E2 F2 G2) ; PRINT_INT
  (chord D4)
)
