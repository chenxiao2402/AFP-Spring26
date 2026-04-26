#lang s-exp "../lang.rkt"


(staff
 (chord D2 E2 F2) ; ESTABLISH
 (chord D1 D2 D5)

 (chord C2 D2 E2) ; ADD
 (chord D1 D2)
 (chord D1 D2)

 (chord C2 E2 F2) ; MUL
 (chord D1 D2)
 (chord D1 D2)

 
 (chord G2 A3 B3) ; WHILE
 (chord D2 F2) ; LESS_THAN
 (chord D3 D1) ; D3 < D1

 (chord C3 D3 E3) ; WHILE_BODY

  (chord G2 A3 B3) ; INNER WHILE
  (chord D2 F2)
  (chord D4 D1)

  (chord C3 D3 E3) ; INNER WHILE BODY

  (chord E2 F2 G2) ; PRINT_INT
  (chord D4)

  (chord C2 D2 E2) ; ADD
  (chord D4 D5)
  (chord D4)

  (chord F3 A3 C3) ; END INNER WHILE

 (chord C2 D2 E2) ; ADD
 (chord D3 D5) ; D3 + 1
 (chord D3)

 (chord D2 G2 C3) ; RESET
 (chord D4)
 
 (chord F3 A3 C3) ; END_WHILE

 )