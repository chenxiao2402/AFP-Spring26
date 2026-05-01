#lang s-exp "../lang.rkt"

(staff
 (chord B3 C3 D3) ; CMD_START_FUNC_DEF
 (chord C6 C7)
 (chord C2)
 (chord D2 E2 F2) ; CMD_ESTABLISH
 (chord E3 E4 B3)
 (chord C2 F2 G2) ; CMD_MUL
 (chord C2 E3)
 (chord E3)
 (chord A3 B3 C3) ; CMD_WHILE
 (chord C2 E2) ; COND_GREATER_THAN
 (chord C2 A2)
 (chord A3 C3 D3) ; CMD_WHILE_BODY
 (chord C2 F2 G2) ; CMD_MUL
 (chord E3 E4)
 (chord E4)
 (chord C2 E2 F2) ; CMD_SUB
 (chord C2 B3)
 (chord C2 E3)
 (chord A3 D3 E3) ; CMD_END_WHILE
 (chord B3 D3 E3) ; CMD_END_FUNC_DEF
 (chord E4)
 (chord D2 E2 F2) ; CMD_ESTABLISH
 (chord A1 A2 E2 B3 C3 D3 E3)
 (chord C2 D2 E2) ; CMD_ADD
 (chord A1 A2 E2 B3 C3 D3 E3)
 (chord C3)
 (chord E2 F2 G2) ; CMD_PRINT_INT
 (chord C3)
 (chord C6 C7) ; FUNCTION_CALL
 (chord C3)
 (chord A2)
 (chord E2 F2 G2) ; CMD_PRINT_INT
 (chord A2))