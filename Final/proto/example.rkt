#lang racket

(require "music.rkt")

(stave
 (play (chord (sharp "C4") (sharp "D4"))) ; sharp increments. C4=0+1 D4=0+1
 (play (chord "A3" "D3")) ; multiply. next chord is args
 (play (chord (sharp "C4") (sharp "D4"))) ; args C4=1+1 D4=1+1
 (play "E4") ; result of multiply E4=4
 (play (chord "A3" "B3")) ; add. next chord is args etc.
 (play (chord (sharp "D4") "C4")) ; args D4=2+1 C4=2
 (play "F4") ; result of add F4=5
 (play (chord "A3" "D3")) ; multiply
 (play (chord "C4" "E4")) ; C4=2 E4=4
 (play "B5") ; result so multiply B5=8
 (play (chord "A3" "D3")) ; multiply
 (play (chord "E4" "B5")) ; E4=4 B5=8
 (play "A6") ; A6=32
 (play (chord "A3" "D3")) ; multiply
 (play (chord "A6" "C4")) ; A6=32 C4=2
 (play "B6") ; B6=62
 (play (chord "A3" "B3")) ; add
 (play (chord "B6" "B5")) ; B6=72 B5=8
 (play "B6") ; B6=72
 (play (chord "A3" "D3")) ; multiply
 (play (chord (sharp "E4") "F4")) ; E4=4+1 F4=5
 (play "F6") ; F6=25
 (play (chord "A3" "D3")) ; multiply
 (play (chord (flat "E4") "F6")) ; E4=5-1 F6=25
 (play "F6") ; F6=100
 (play (chord "A3" "B3")) ; add
 (play (chord (sharp "F5") "F6")) ; F5=0+1 F6=100
 (play "G6") ; G6=101
 (play (chord "A3" "B3")) ; add
 (play (chord "F6" "B5")) ; F6=100 B5=8
 (play "A4") ; A4=108
 (play (chord "A3" "B3")) ; add
 (play (chord "A4" "D4")) ; A4=108 D4=3
 (play "A5"); A5 = 111
 (play (chord "A3" "B3")) ; add
 (play (chord "A5" "D4")) ; A5=111 D4=3
 (play "G4") ; G4=114
 (play (chord "A3" "B3")) ; add
 (play (chord "B6" "B5" "C4" "F4")) ; B6=72 B5=8 C4=2 F4=5
 (play "E5") ; E5=87
 (play (chord "A3" "E3")) ; PRINT
 ; load args B6=72 G6=101 A4=108 A5=111 A6=32 E4=87 G4=114 F6=100
 ; into output buffer
 (play (chord "B6" "G6" "A4" "A4" "A5" "A6" "E5" "A5" "G4" "A4" "F6"))
 ; print output buffer as ascii
 (play quarter-rest))


; registers