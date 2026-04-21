#lang s-exp "../lang.rkt"

(staff
 (chord E3 E4 E5) ; ESTABLISH
 (chord D1 D2 D3 D4 D5 D6)

 (chord A1 A2 A3)
 (chord D1 D2)
 (chord D4 D5)

 (chord C1 C2 C3) ; IF
 (chord C4 C5) ; =
 (chord D4 D5) ; D4 and D5
 (chord C2 C3 C4) ; THEN

 (chord A1 A2 A8) ; PRINT
 (chord D4)

 (chord C3 C4 C5) ; ELSE

 (chord A5 A6 A7) ; PRINT x2
 (chord D4)

 (chord A1 A2 A8)
 (chord D4)

 (chord C4 C5 C6) ; END IF

 ;; AGAIN!
 (chord C1 C2 C3)
 (chord C4 C5)
 (chord D4 D1) ; BUT WITH D1, so PRINTS TWICE!
 (chord C2 C3 C4)

 (chord A1 A2 A8)
 (chord D4)

 (chord C3 C4 C5)

 (chord A1 A2 A8)
 (chord D4)

 (chord A1 A2 A8)
 (chord D4)

 (chord C4 C5 C6))

 