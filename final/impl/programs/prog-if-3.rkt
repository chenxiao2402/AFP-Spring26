#lang s-exp "../lang.rkt"


(staff
 (chord G2 A3 B3)            ; IF
 (chord C2 F2) (chord D1 D3) ;   EQUAL D1 = D3
 (chord G2 B3 C3)            ; THEN
 (chord D2 E2 F2) (chord A1) ;   ESTABLISH (SET ONE) A1
 (chord G2 A3 B3)            ;   IF
 (chord C2 F2) (chord D1 D3) ;     EQUAL D1 = D3
 (chord G2 B3 C3)            ;   THEN
 (chord E2 F2 G2) (chord A1) ;     PRINT_INT A1
 (chord G2 C3 D3)            ;   ELSE
 (chord E2 F2 G2) (chord D3) ;     PRINT_INT D3
 (chord G2 D3 E3)            ;   END_IF
 (chord G2 C3 D3)            ; ELSE
 (chord E2 F2 G2) (chord A1) ;   PRINT_INT A1
 (chord G2 D3 E3))           ; END_IF