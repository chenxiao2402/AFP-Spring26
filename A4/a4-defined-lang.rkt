#lang racket

(require (for-syntax syntax/parse))

(define define-expr?
  (lambda (x)
    (eqv? (car x) 'define)))

(define not-define-expr?
  (lambda (x)
    (not (define-expr? x))))

(define-syntax (my-module-begin stx)
  (syntax-parse stx
    [(_ form ...)
     #'(#%plain-module-begin
        (begin
          (define exprs (list (syntax->datum #'form) ...))
          (define defs (filter define-expr? exprs))
          (define non-defs (filter not-define-expr? exprs))
          (define prog (append defs non-defs))
          (println prog)))]))

(provide (rename-out [my-module-begin #%module-begin])
         (except-out (all-from-out racket) #%module-begin))