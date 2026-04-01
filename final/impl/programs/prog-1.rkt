#lang s-exp "../lang.rkt"

(staff
 ; Set B3 and E4 to 1
 (chord A3 A4 A5)
 (chord B3 E4)
 
 ; Print B3 as int
 (chord A1 A2 A8)
 (chord B3)

 ; Add B3 and E4 1 + 1 = 2
 (chord A1 A2 A3)
 (chord B3 E4)
 (chord C4)

 ; Print C4 as int
 (chord A1 A2 A8)
 (chord C4))

; expected errors that work
#;; non-staff chord expression
(chord A3 A4)
#;; non staff expression
(+ 1 2)
#;; staff with invalid note (A11)
(staff (chord A3 A4 A5) (chord A11))

#;; second staff is valid 
(staff
 ; Set B3 and E4 to 1
 (chord A3 A4 A5)
 (chord B3 E4)
 
 ; Print B3 as int
 (chord A1 A2 A8)
 (chord B3)

 ; Add B3 and E4 1 + 1 = 2
 (chord A1 A2 A3)
 (chord B3 E4)
 (chord C4)

 ; Print C4 as int
 (chord A1 A2 A8)
 (chord C4))