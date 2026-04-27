#lang s-exp "../lang.rkt"

(staff
 ; define an addition function
 (chord B3 C3 D3) ; CMD_START_FUNC_DEF
 (chord C6 C7)
 (chord E3 E4)
 (chord C2 D2 E2) ; CMD_ADD  (chord E3 E4)
 (chord B3)
 (chord B3 D3 E3) ; CMD_END_FUNC_DEF
 (chord B3)

 ; set B3 and E4 to 1
 (chord D2 E2 F2) ; CMD_ESTABLISH
 (chord B3 E4)
 ; call function C6 C7 with args B3 E4
 (chord C6 C7)
 (chord B3 E4)
 (chord C7)


 ; Print C7 as int
 (chord E2 F2 G2) ; CMD_PRINT_INT
 (chord C7)

 ; Print B3 to make sure stack saved
 (chord E2 F2 G2) ; CMD_PRINT_INT
 (chord B3)

  
 ; call function C6 C7 with args B3 E4
 (chord C6 C7)
 (chord B3 E4)
 (chord C7)


 ; Print C7 as int
 (chord E2 F2 G2) ; CMD_PRINT_INT
 (chord C7)

 ; Print B3 to make sure stack saved
 (chord E2 F2 G2) ; CMD_PRINT_INT
 (chord B3))

; expected errors that work
#; ; non-staff chord expression
(chord A3 A4)
#; ; non staff expression
(+ 1 2)
#; ; staff with invalid note (A11)
(staff (chord A3 A4 A5) (chord A11))

#; ; second staff is valid
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