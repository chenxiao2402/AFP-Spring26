#lang s-exp "../lang.rkt"

(staff
 (chord D2 E2 F2) ; CMD_ESTABLISH
 (chord D1 D2 D3 D4 D5 D6)

 (chord C2 D2 E2) ; CMD_ADD
 (chord D1 D2)
 (chord D4 D5)

 (chord G2 A3 B3) ; CMD_IF
 (chord C2 F2) ; COND_EQUAL
 (chord D4 D5) ; D4 and D5
 (chord G2 B3 C3) ; CMD_THEN

 (chord E2 F2 G2) ; CMD_PRINT_INT
 (chord D4)
 
 (chord G2 C3 D3) ; CMD_ELSE

 (chord E2 F2 G2) ; CMD_PRINT_INT
 (chord D4)

 (chord E2 F2 G2) ; CMD_PRINT_INT
 (chord D4)
 (chord G2 D3 E3) ; CMD_END_IF

 ;; AGAIN!
  (chord G2 A3 B3) ; CMD_IF
 (chord C2 F2) ; COND_EQUAL
 (chord D4 D1) ; BUT WITH D1, so PRINTS TWICE!
 (chord G2 B3 C3) ; CMD_THEN

 (chord E2 F2 G2) ; CMD_PRINT_INT
 (chord D4)

 (chord G2 C3 D3) ; CMD_ELSE

 (chord E2 F2 G2) ; CMD_PRINT_INT
 (chord D4)

 (chord E2 F2 G2) ; CMD_PRINT_INT
 (chord D4)

 (chord G2 D3 E3)) ; CMD_END_IF

 