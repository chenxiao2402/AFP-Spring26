#lang racket

(require (for-syntax syntax/parse))

(define-syntax (my-module-begin stx)
  (syntax-parse stx
    [(_ form ...)
     #'(#%plain-module-begin
        (begin
          (displayln (syntax->datum #'form))
          (let ([result form])
            (when (not (void? result))
              (displayln result)))) ...)]))

(provide (rename-out [my-module-begin #%module-begin])
         (except-out (all-from-out racket) #%module-begin))