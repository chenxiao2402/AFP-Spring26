#lang racket
(require (for-syntax syntax/parse racket/list))

; (define-for-syntax keys '(A1 A2 A3 A4 A5 A6 A7 B1 B2 B3 B4 B5 B6 B7 C1 C2 C3 C4 C5 C6 C7 D1 D2 D3 D4 D5 D6 D7 E1 E2 E3 E4 E5 E6 E7 F1 F2 F3 F4 F5 F6 F7 G1 G2 G3 G4 G5 G6 G7 A#1 A#2 A#3 A#4 A#5 A#6 A#7 C#1 C#2 C#3 C#4 C#5 C#6 C#7 D#1 D#2 D#3 D#4 D#5 D#6 D#7 F#1 F#2 F#3 F#4 F#5 F#6 F#7 G#1 G#2 G#3 G#4 G#5 G#6 G#7 A0 A#0 B0 C8))
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

(define-syntax (process-staff stx)   
  (syntax-parse stx
    [(_) #'(void)]
    [(_ forms ...) ; need to check if Staff appears in the forms and return an error message accordingly
     #'(begin forms ...)]
    ))

(define-syntax (mb stx)
  (syntax-parse stx
    #:datum-literals (Staff)
    [(_)
     #'(#%module-begin)]
    [(_ (Staff forms ...))
     #'(#%module-begin (process-staff forms ...))]
    [(_ (Staff forms-0 ...)
        (Staff forms-1 ...)
        (Staff forms-2 ...) ...)
     #'(#%module-begin (error "Can't have more than 1 staff"))]
    [_
     #'(#%module-begin (error "Can't start a program without a staff"))]
    ))


(define-syntax (datum stx)
  (syntax-parse stx
    [(_ . n) #'(#%datum . n)]))

; just a normal function definition for now
(define-syntax (def stx)
  (syntax-parse stx
    [(_ (f:id arg:id) e)
     #'(define (f arg) e)]))

; just a normal variable def for now
(define-syntax (defv stx)
  (syntax-parse stx
    [(_ var:id e)
     #:when (memv (syntax->datum #'var) keys2)
     #'(define var e)]))

; just a normal app yk what it is 
(define-syntax (app stx)
  (syntax-parse stx
    [(_ f:id arg:expr ...) #'(#%app f arg ...)]))


(provide + def defv quote (rename-out [datum #%datum] [app #%app] [mb #%module-begin] ))