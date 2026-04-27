#lang s-exp "../lang.rkt"

(staff

  ; ESTABLISH (B1, B2, B3, B4)
  ; i.e., to set all of them to 1
  (chord D2 E2 F2) ; CMD_ESTABLISH
  (chord B1 B2 B3 B4)

  ; RESET (C1, C2)
  ; i.e., to set both of them to 0
  (chord D2 F2 G2) ; CMD_RESET
  (chord C1 C2)

  (chord G2 A3 B3) ; CMD_IF
  (chord C2 F2) ; COND_EQUAL
  (chord C1 C2) ; whether both C1 and C2 are zero

  (chord G2 B3 C3) ; CMD_THEN
  (chord D2 E2 F2) ; CMD_ESTABLISH
  (chord C1)
  (chord C2 D2 E2) ; CMD_ADD
  (chord B1 B2)
  (chord B3)
  (chord E2 F2 G2) ; CMD_PRINT_INT
  (chord B3)

  (chord G2 C3 D3) ; CMD_ELSE
  (chord D2 F2 G2) ; CMD_RESET
  (chord B4)
  (chord E2 F2 G2) ; CMD_PRINT_INT
  (chord B4)

  (chord G2 D3 E3) ; CMD_END_IF

  (chord G2 A3 B3) ; CMD_IF
  (chord C2 F2) ; COND_EQUAL
  (chord C1 C2) ; whether both C1 and C2 are zero

  (chord G2 B3 C3) ; CMD_THEN
  (chord D2 E2 F2) ; CMD_ESTABLISH
  (chord C1)
  (chord C2 D2 E2) ; CMD_ADD
  (chord B1 B2)
  (chord B3)
  (chord E2 F2 G2) ; CMD_PRINT_INT
  (chord B3)

  (chord G2 C3 D3) ; CMD_ELSE
  (chord D2 F2 G2) ; CMD_RESET
  (chord B4)
  (chord E2 F2 G2) ; CMD_PRINT_INT
  (chord B4)

  (chord G2 D3 E3)) ; CMD_END_IF


