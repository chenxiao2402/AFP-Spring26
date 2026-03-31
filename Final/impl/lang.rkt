#lang racket
(require (for-syntax syntax/parse "key-file.rkt"))

; this exists only to check the contents of key-dict
(define-syntax (huh stx)
  (print key-dict)
  #'(void))

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
     #:when (memv (syntax->datum #'var) key-dict)
     #'(define var e)]))

; just a normal app yk what it is 
(define-syntax (app stx)
  (syntax-parse stx
    [(_ f:id arg:expr ...) #'(#%app f arg ...)]))


(provide + def defv quote (rename-out [datum #%datum] [app #%app] [mb #%module-begin] ))
