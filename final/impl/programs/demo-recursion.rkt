#lang s-exp "../lang.rkt"

(staff
 (chord B3 C3 D3) ; CMD_START_FUNC_DEF
 (chord C6 C7)
 (chord C2)
 (chord E2 F2 G2) ; CMD_PRINT_INT
 (chord C2)
 (chord G2 A3 B3) ; CMD_IF
 (chord C2 F2) ; COND_EQUAL
 (chord C2 E3)
 (chord G2 B3 C3) ; CMD_THEN
 (chord D2 E2 F2) ; CMD_ESTABLISH
 (chord C2)
 (chord G2 C3 D3) ; CMD_ELSE
 (chord D2 E2 F2) ; CMD_ESTABLISH
 (chord E4)
 (chord C2 E2 F2) ; CMD_SUB
 (chord C2 E4)
 (chord C2)
 (chord C6 C7) ; !! RECURSIVE CALL OF C6 C7
 (chord C2)
 (chord C2)
 (chord G2 D3 E3) ; CMD_END_IF
 (chord B3 D3 E3) ; CMD_END_FUNC_DEF
 (chord C2)
 (chord D2 E2 F2) ; CMD_ESTABLISH
 (chord D1 D2 D3 D4)
 (chord C2 D2 E2) ; CMD_ADD
 (chord D1 D2 D3 D4)
 (chord D1)
 (chord C6 C7) ; FUNCTION_CALL
 (chord D1)
 (chord D2))