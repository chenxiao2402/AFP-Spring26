#lang racket

(require rackunit (for-syntax syntax/parse) racket/stxparam (for-syntax racket/syntax))

; Part 1: (all Expression ...)
; If all of the expressions evaluate to a non-#false value, all produces the list of the results not including any values which are #true; otherwise it produces #false.
; The all form should short-circuit; that is, this expression should not print anything: (all #false (print 'hi))



(define-syntax fcons
  (syntax-parser
    [(_ e es)
     #'(if (equal? es #f) #f (cons e es))]))

(define-syntax all
  (syntax-parser
    [(_ e1 es ...)
    #'(let [(eval e1)]
          (if eval
               (if (equal? eval #t)
                   (all es ...)
                   (fcons eval (all es ...)))
              #f))]
      [(_) #''()]))


(check-equal? (all #f 1 2 3) #f)
(check-equal? (all 1 2 3 #f) #f)
(check-equal? (all #t 1 2 3) '(1 2 3))
(check-equal? (all #f (print 'hi)) #f)
(check-equal? (all) '())



; Part 2: (struct/con Identifier ({Identifier : Identifier} ...))
; The difference to plain struct is that each field comes with a second identifier, to the right of :. This identifier names a predicate.
; The form creates a struct type definition whose constructor ensures that the respective field values satisfy the named predicate.

(begin-for-syntax
  (require racket)
  (define-syntax-class (fld sname)
    (pattern (i:id c p:id)
      #:fail-when (not (equal? (syntax->datum #'c) ':))
                  (format "expected ':' after field name ~a" (syntax->datum #'i))
      #:with acc-name (format-id #'i "~a-~a" sname #'i)))
  
  (define-syntax-class sname
    (pattern i:id
      #:with maker (format-id #'i "~a" #'i)))
  
  (define-syntax-class (flds sname)
    (pattern [f ...]
      #:declare f (fld sname)
      #:with (ids ...) #'(f.i ...)
      #:with (preds ...) #'(f.p ...)
      #:with (acc-names ...) #'(f.acc-name ...)
      #:with (idx ...) #`#,(build-list (length (syntax->list #'(f ...))) add1)))
  )

(define-syntax struct/con
  (syntax-parser
    [(_ name:sname fs)
     #:declare fs (flds #'name)
     #`(begin
         (define (name.maker fs.ids ...)
           (unless (fs.preds fs.ids)
             (error 'name.maker 
                    (format "~a failed predicate ~a" fs.ids fs.preds)))
           ...
           (vector 'name fs.ids ...))
         
         (define (fs.acc-names v)
           (vector-ref v fs.idx))
         ...)
     ]))


(struct/con posn [{x : number?} {y : number?}])
(define p (posn 1 2))
(check-equal? (posn-x p) 1)
(check-equal? (posn-y p) 2)
(check-exn exn:fail? (thunk (posn-y (posn 1 #f))))
