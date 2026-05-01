#lang s-exp "../lang.rkt"

(staff
 ; ESTABLISH (B1, B2)
 ; i.e., to set both of them to 1
 (chord D2 E2 F2) ; CMD_ESTABLISH
 (chord B1 B2 B3)
 ; B1 = ADD B1 B1, repeat 3 times
 (chord C2 D2 E2) ; B1 = ADD B1 B1
 (chord B1 B2)
 (chord B1 B2)
 (chord C2 D2 E2) ; CMD_ADD ; B1 = ADD B1 B1
 (chord B1 B2)
 (chord B1 B2)
 (chord C2 D2 E2) ; CMD_ADD ; B1 = ADD B1 B1
 (chord B1 B2)
 (chord B1 B2)
 (chord A3 B3 C3) ; CMD_WHILE
 (chord C2 E2) ; COND_GREATER_THAN
 (chord B1 E6) ; loop until C1 is zero
 (chord A3 C3 D3) ; CMD_WHILE_BODY
 (chord E2 F2 G2) ; CMD_PRINT_INT
 (chord B1)
 (chord C2 E2 F2) ; CMD_SUB
 (chord B1 B3)
 (chord B1)
 (chord A3 D3 E3)) ; CMD_END_WHILE

