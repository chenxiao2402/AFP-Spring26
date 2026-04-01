#lang racket
(require "interp.rkt"
         (for-syntax syntax/parse
                     "keys.rkt"
                     racket/dict))

(define-syntax (my-module-begin stx)
  (syntax-parse stx
    #:datum-literals (staff)
    [(_)
     #'(#%module-begin)]
    [(_ (staff chord ...))
     #'(#%module-begin
         (interp (process-staff chord ...)))]))

(define-syntax (process-staff chords)
  (syntax-parse chords
    #:datum-literals (chord)
    [(_)
     #''()]
    [(_ (chord a ...) ...)
     #'(list (process-chord a ...) ...)]))

(define-syntax (process-chord notes)
  (syntax-parse notes
    [(_ a ...)
     #'(list 'a ...)]))

(define-syntax (datum stx)
  (syntax-parse stx
    [(_ . n) #'(#%datum . n)]))



(provide (rename-out [datum #%datum] [my-module-begin #%module-begin])
         (except-out (all-from-out racket) #%datum #%module-begin))
