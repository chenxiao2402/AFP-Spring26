#lang racket

(require (for-syntax syntax/parse))

(define-syntax (mb stx)
  (syntax-parse stx
    [(_ forms ...) #'(#%module-begin "Welcome to Forte" forms ...)]))

(provide (rename-out [mb #%module-begin]))