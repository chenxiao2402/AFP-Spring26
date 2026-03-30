#lang racket
(require (for-syntax syntax/parse racket/list racket/match racket/dict))

(define-for-syntax keys2
                  (map string->symbol
                       (flatten
                        (append

                         (for/list ([ltr '(A B C D E F G)])
                           (for/list ([num (map add1 (range 7))])
                             (string-append (symbol->string ltr)
                                            (number->string num))))

                         (for/list ([ltr '(A C D F G)])
                           (for/list ([num (map add1 (range 7))])
                             (string-append (symbol->string ltr)
                                            "#"
                                            (number->string num))))

                         '("A0" "A#0" "B0" "C8")
                         ))))

(define-for-syntax key-dict (make-hash))
(define-for-syntax (key-dict-builder dict k v)
  (match k
    ('() dict)
    ((cons a b) (begin (dict-set! dict a (car v))
                     (key-dict-builder dict b v)))))

(begin-for-syntax (key-dict-builder key-dict keys2 (build-list 88 (λ (x) 0))))

;only exists to print the dict
(define-syntax (huh stx)
  (print key-dict)
  #'(void))

huh