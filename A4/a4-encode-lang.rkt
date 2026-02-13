
#lang racket

(require (for-syntax syntax/parse))



(define-syntax (datum stx)
  (syntax-parse stx
    [(_ . n:number) #:when (and (<= 0 (syntax->datum #'n)) (< (syntax->datum #'n) 128)) 
      #`(integer->char #,(syntax->datum #'n))]
    [(_ . c:number ) #'(error "Invalid char code:" (syntax->datum #'c))]
    [(_ . x) #'(error "Expecting int:" (syntax->datum #'x))]))

(define-syntax (top stx)
  (syntax-parse stx
    [(_ . x) #'(error "Expecting int:" (syntax->datum #'x))]))

(define-syntax (app stx)
  (syntax-parse stx
    [(_ . x) #'(error "Expecting int:" (syntax->datum #'x))]))


(define-syntax (my-module-begin stx)
  (syntax-parse stx
    [(_ form ...)
     #'(#%plain-module-begin
        (displayln (list->string (list form ...))))]))

(provide (rename-out [datum #%datum] [top #%top] [app #%app]
     [my-module-begin #%module-begin]))
