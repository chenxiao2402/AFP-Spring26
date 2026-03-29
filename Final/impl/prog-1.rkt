#lang s-exp "lang.rkt"
#;
(Staff 42
       24
       "a"
       (plus 42 24)
       (def (addd x) (plus x 1))
       (defv x 5)
       241
       #;x)
(Staff (defv A0 5)
       'a
       A0)

#;(defv A0 5)

#; (defv x 5) ; this will return an error