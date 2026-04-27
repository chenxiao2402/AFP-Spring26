#lang s-exp "../lang.rkt"

(staff
 (chord D2 E2 F2) ; CMD_ESTABLISH
 (chord C1 C2 C3 C4 C5)
 (chord C2 D2 E2) ; CMD_ADD
 (chord C1 C2 C3 C5)
 (chord C5)
 (chord C2 F2 G2) ; CMD_MUL
 (chord C5 C1)
 (chord C1)
 (chord C2 D2 E2) ; CMD_ADD
 (chord C2 C3)
 (chord C2)
 (chord C2 F2 G2) ; CMD_MUL
 (chord C5 C1 C2)
 (chord C3 C6)
 (chord C2 E2 F2) ; CMD_SUB
 (chord C3 C4)
 (chord D5)
 (chord C2 E2 F2) ; CMD_SUB
 (chord D1 C4)
 (chord D1)
 (chord C2 F2 G2) ; CMD_MUL
 (chord C1 C2)
 (chord F5)
 (chord C2 D2 E2) ; CMD_ADD
 (chord F5 C2)
 (chord F5)
 (chord C2 D2 E2) ; CMD_ADD
 (chord C1 C2)
 (chord F1)
 (chord C2 D2 E2) ; CMD_ADD
 (chord F1 C4)
 (chord F2)
 (chord C2 F2 G2) ; CMD_MUL
 (chord F1 F2)
 (chord F1)
 (chord A3 B3 C3) ; CMD_WHILE
 (chord C2 E2) ; COND_GREATER_THAN
 (chord D5 D1)
 (chord A3 C3 D3) ; CMD_WHILE_BODY
 (chord C2 F2 G2) ; CMD_MUL
 (chord D5 C4)
 (chord E6)
 (chord D2 F2 G2) ; CMD_RESET
 (chord G5 G4)
 (chord A3 B3 C3) ; CMD_WHILE
 (chord C2 E2) ; COND_GREATER_THAN
 (chord E6 G4)
 (chord A3 C3 D3) ; CMD_WHILE_BODY
 (chord E2 G2 A3) ; CMD_PRINT_CHAR
 (chord C3)
 (chord C2 E2 F2) ; CMD_SUB
 (chord E6 C4)
 (chord E6)
 (chord A3 D3 E3) ; CMD_END_WHILE
 (chord C2 E2 F2) ; CMD_SUB
 (chord C3 D5)
 (chord G6)
 (chord A3 B3 C3) ; CMD_WHILE
 (chord C2 D2) ; COND_LESS_THAN
 (chord G5 G6)
 (chord A3 C3 D3) ; CMD_WHILE_BODY
 (chord C2 A3 B3) ; CMD_BITWISE_AND
 (chord G5 D5)
 (chord A1)
 (chord G2 A3 B3) ; CMD_IF
 (chord C2 F2) ; COND_EQUAL
 (chord A1 G4)
 (chord G2 B3 C3) ; CMD_THEN
 (chord E2 G2 A3) ; CMD_PRINT_CHAR
 (chord F1 C3)
 (chord G2 C3 D3) ; CMD_ELSE
 (chord E2 G2 A3) ; CMD_PRINT_CHAR
 (chord C3 C6)
 (chord G2 D3 E3) ; CMD_END_IF
 (chord C2 D2 E2) ; CMD_ADD
 (chord G5 C4)
 (chord G5)
 (chord A3 D3 E3) ; CMD_END_WHILE
 (chord E2 G2 A3) ; CMD_PRINT_CHAR
 (chord F5)
 (chord C2 E2 F2) ; CMD_SUB
 (chord D5 C4)
 (chord D5)
 (chord A3 D3 E3)) ; CMD_END_WHILE