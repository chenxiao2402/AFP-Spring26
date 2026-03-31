#lang racket
(require (for-syntax syntax/parse
                     "keys.rkt"
                     racket/dict))

(define-syntax (mb stx)
  (syntax-parse stx
    #:datum-literals (staff)
    [(_)
     #'(#%module-begin)]
    [(_ (staff chord ...))
     #'(#%module-begin (process-staff chord ...))]))

(define-syntax (process-staff chords)
  (syntax-parse chords
    #:datum-literals (chord)
    [(_)
     #'(void)]
    [(_ (chord a ...) ...)
     #'(begin (process-chord a ...) ...)]))

(define-syntax (process-chord notes)
  (syntax-parse notes
    [(_ a ...)
     #'(list a ...)]))

(define-syntax (datum stx)
  (syntax-parse stx
    [(_ . n) #'(#%datum . n)]))



(provide (rename-out [datum #%datum] [mb #%module-begin] ))
