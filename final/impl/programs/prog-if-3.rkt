#lang s-exp "../lang.rkt"


(staff
 ; (chord D2 E2 F2) ; ESTABLISH
 ; (chord D1)
 
 (chord D2 F2 A3) ; IF
 (chord F2 A3) ; EQUAL
 (chord D1 D3) ; D1 == D3 ?
 (chord E2 F2 A3) ; THEN

 (chord D2 E2 F2) ; ESTABLISH
 (chord D#1)

   (chord D2 F2 A3) ; IF
   (chord F2 A3) ; EQUAL
   (chord D1 D3) ; D1 = D3 ?
   (chord E2 F2 A3) ; THEN

   (chord E2 F2 G2) ; PRINT_INT
   (chord D#1)

   (chord F2 E2 A3)

   (chord G2 B3 C3)
 

 (chord F2 E2 A3) ; ELSE

 ; no establish
 
 (chord E2 F2 G2) ; PRINT_INT
 (chord D#1)

 (chord G2 B3 C3) ; END IF
 

 
 )