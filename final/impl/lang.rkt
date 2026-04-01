#lang racket
(require "interp.rkt"
         (for-syntax syntax/parse))
(provide staff
         (rename-out [my-module-begin #%module-begin]))

(define-syntax (my-module-begin stx)
  (syntax-parse stx
    #:datum-literals (staff)
    [(_)
     #'(#%module-begin)]
    [(_ expr ...)
     #'(#%module-begin
         (interp expr) ...)]))

(define-syntax (staff chords)
  (syntax-parse chords
    #:datum-literals (chord)
    [(_ (chord notes ...) ...)
     #'(list (list 'notes ...) ...)]))