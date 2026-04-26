#lang s-exp "../lang.rkt"


(staff
 ; (chord D2 E2 F2) ; ESTABLISH
 ; (chord D1)
 (chord G2 A3 B3) ; CMD_IF
 (chord C2 F2) ; COND_EQUAL
 (chord D1 D3) ; D1 == D3 ?
 (chord G2 B3 C3) ; CMD_THEN

 (chord D2 E2 F2) ; CMD_ESTABLISH
 (chord D#1)

 (chord G2 A3 B3) ; CMD_IF
 (chord C2 F2) ; COND_EQUAL
   (chord D1 D3) ; D1 = D3 ?
 (chord G2 B3 C3) ; CMD_THEN

 (chord E2 F2 G2) ; CMD_PRINT_INT
   (chord D#1)

 (chord G2 C3 D3) ; CMD_ELSE

 (chord G2 D3 E3) ; CMD_END_IF
 

 (chord G2 C3 D3) ; CMD_ELSE

 ; no establish
 
 (chord E2 F2 G2) ; CMD_PRINT_INT
 (chord D#1)

 (chord G2 D3 E3) ; CMD_END_IF
 

 
 )