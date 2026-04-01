#lang racket
(require "interp.rkt"
         (for-syntax syntax/parse))
(provide staff chord
         (rename-out [my-module-begin #%module-begin])
         (except-out (all-from-out racket) #%module-begin))


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
    [(_ chord ...)
     #'(list chord ...)]))

(define-syntax (chord notes)
  (syntax-parse notes
    [(_ note ...)
     #'(list 'note ...)]))