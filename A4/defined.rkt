#lang racket

(require (for-syntax syntax/parse))

(define-syntax (my-module-begin stx)
  (syntax-parse stx
    [(_ form ...)
     (define define-expr?
       (lambda (x)
         (eqv? (car (syntax->datum x)) 'define)))
     (define not-define-expr?
       (lambda (x)
         (not (define-expr? x))))
     
     (define exprs (syntax->list #'(form ...)))
     (define defs (filter define-expr? exprs))
     (define non-defs (filter not-define-expr? exprs))
     
     (datum->syntax stx (cons '#%plain-module-begin (append defs non-defs)))]))

(provide (rename-out [my-module-begin #%module-begin])
         (except-out (all-from-out racket) #%module-begin))