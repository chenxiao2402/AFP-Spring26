#lang racket

(require (for-syntax syntax/parse))

(begin-for-syntax
  (define-syntax-class def
    (pattern (define key:id val:id)))
  
  (define-syntax-class defs
    (pattern [d:def ...]
      #:with (ids ...) #'(d.key ...))))

(define-syntax (my-module-begin stx)
  (syntax-parse stx
    [(_ form:def ...)
     (define (def-exists? forms id)
       (and (not (null? forms))
            (or (equal? id (cadr (syntax->datum (car forms))))
                (def-exists? (cdr forms) id))))
     (define (defs-exists? forms ids)
       (or (null? ids)
           (and (def-exists? forms (car ids))
                (defs-exists? forms (cdr ids)))))
    
     (unless (defs-exists? (syntax->list #'(form ...)) '(name author university))
       (raise-syntax-error #f "Missing required definitions: name, author, university"))
     
     (with-syntax ([s-name (datum->syntax stx 'name)]
                    [s-author (datum->syntax stx 'author)]
                    [s-university (datum->syntax stx 'university)])
       #'(#%plain-module-begin
          (define form.key (quote form.val)) ...
          (provide s-name s-author s-university)))]))

(provide (rename-out [my-module-begin #%module-begin])
         (except-out (all-from-out racket) #%module-begin))