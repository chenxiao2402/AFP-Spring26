#lang s-exp "../lang.rkt"


(staff
  (chord E3 E4 E5) ; ESTABLISH
  (chord D1 D2 D3 D4)
  (chord F1 F2 F3) ; START_FUNC_DEF
  (chord C6 C7)
  (chord E3 E4)
    (chord F1 F2 F3) ; START_FUNC_DEF
    (chord E6 E7)
    (chord A1 A2)
    (chord A1 A2 A3) ; ADD
    (chord A1 A2)
    (chord C7)
    (chord F2 F3 F4) ; END_FUNC_DEF
    (chord C7)
  (chord E6 E7)
  (chord E3 E4)
  (chord C7)
  (chord F2 F3 F4) ; END_FUNC_DEF
  (chord C7)
  (chord C6 C7)
  (chord D1 D2)
  (chord D4)
  (chord A1 A2 A8) ; PRINT_INT
  (chord D4)
)
