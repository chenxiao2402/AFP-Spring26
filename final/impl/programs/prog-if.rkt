#lang s-exp "../lang.rkt"

(staff

  ; ESTABLISH (B1, B2, B3, B4)
  ; i.e., to set all of them to 1
  (chord A3 A4 A5)
  (chord B1 B2 B3 B4)

  ; RESET (C1, C2)
  ; i.e., to set both of them to 0
  (chord A5 A6 A7)
  (chord C1 C2)

  #; (if (and (zero? C1) (zero? C2))
         (begin (set! C1 1) (set! B3 (+ B1 B2)) (print B3))
         (begin (set! B4 0) (print B4)))
  (chord C1 C2 C3) ; IF_ZERO
  (chord C1 C2) ; whether both C1 and C2 are zero

  (chord C2 C3 C4) ; THEN
  (chord A3 A4 A5) ; ESTABLISH (C1)
  (chord C1)
  (chord A1 A2 A3) ; B3 = ADD B1 B2
  (chord B1 B2)
  (chord B3)
  (chord A1 A2 A8) ; PRINT_INT B3
  (chord B3)

  (chord C3 C4 C5) ; ELSE
  (chord A5 A6 A7) ; RESET (B4)
  (chord B4)
  (chord A1 A2 A8) ; PRINT_INT B3
  (chord B4)


  #; (if (and (zero? C1) (zero? C2))
         (begin (set! C1 1) (set! B3 (+ B1 B2)) (print B3))
         (begin (set! B4 0) (print B4)))
  (chord C4 C5 C6) ; END_IF_ZERO

  (chord C1 C2 C3) ; IF_ZERO
  (chord C1 C2) ; whether both C1 and C2 are zero

  (chord C2 C3 C4) ; THEN
  (chord A3 A4 A5) ; ESTABLISH (C1)
  (chord C1)
  (chord A1 A2 A3) ; B3 = ADD B1 B2
  (chord B1 B2)
  (chord B3)
  (chord A1 A2 A8) ; PRINT_INT B3
  (chord B3)

  (chord C3 C4 C5) ; ELSE
  (chord A5 A6 A7) ; RESET (B4)
  (chord B4)
  (chord A1 A2 A8) ; PRINT_INT B3
  (chord B4)

  (chord C4 C5 C6) ; END_IF_ZERO
  )

