#lang s-exp "../lang.rkt"

(staff
 (chord D2 E2 F2) ; ESTABLISH
 (chord A1 A2 A3 A4 A5 D1 D2)
 (chord C2 D2 E2) ; CMD_ADD
 (chord A1 A2)
 (chord A1 A2)
 (chord C2 F2 G2) ; CMD_MUL
 (chord A1 A2)
 (chord A3 A4)
 (chord C2 F2 G2) ; CMD_MUL
 (chord A3 A1)
 (chord A4)
 (chord C2 D2 E2) ; CMD_ADD
 (chord A3 A5)
 (chord A1 A2)
 (chord C2 F2 G2) ; CMD_MUL
 (chord A1 A2 A3)
 (chord A1)
 (chord C2 F2 G2) ; CMD_MUL
 (chord A4 A3)
 (chord A2)
 (chord C2 D2 E2) ; CMD_ADD
 (chord A1 A3)
 (chord C1)
 (chord C2 D2 E2) ; CMD_ADD
 (chord A1 A5)
 (chord C2)
 (chord C2 D2 E2) ; CMD_ADD
 (chord A1 A4)
 (chord C3 E4 D3)
 (chord C2 D2 E2) ; CMD_ADD
 (chord C3 A5 D1 D2)
 (chord C4 E5)
 (chord C2 D2 E2) ; CMD_ADD
 (chord C4 A4)
 (chord C5)
 (chord C2 D2 E2) ; CMD_ADD
 (chord C4 A5 D1 D2)
 (chord C6)
 (chord E2 G2 A3) ; CMD_PRINT_CHAR
 (chord C1 C2 E4 C3 C4 A2 C5 E5 C6 D3 A1))

 