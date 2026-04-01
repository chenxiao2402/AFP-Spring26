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
 (chord C4)
 )