;; a.rkt
#lang racket
(require (for-syntax syntax/parse racket/match))
(provide (rename-out [mb #%module-begin]) #%app + #%datum let-values let)

(begin-for-syntax
  (define-syntax-class exp #:datum-literals (+ let-values Whatever let)
    (pattern (+ a 0)
      #:when (not (symbol? (syntax->datum #'a)))
      #:with code #'a)
    (pattern (+ 0 a)
      #:when (not (symbol? (syntax->datum #'a)))
      #:with code #'a)
    (pattern (let-values ([a] e) b)
      #:when (begin
               (when #f (println (syntax->datum #'a)) (println (syntax->datum #'b)))
               (eqv? (syntax->datum #'a) (syntax->datum #'b)))
      #:with code #'e)
    ;q1
    (pattern (let ([var:id] rhs:number) b)
      #:with code (subst #'b #'var #'rhs))

    (pattern (op a:number ...)
      #:when (memv (syntax->datum #'op) '(+ - * /))
      #:with code (begin
                    (define args (syntax->datum #'(a ...)))
                    (define rator (match (syntax->datum #'op)
                                    ['+ +]
                                    ['- -]
                                    ['* *]
                                    ['/ /]))
                    (datum->syntax #'here (apply rator args))))
    
    (pattern Whatever #:with code #'(void))
    (pattern a #:with code #'a)))


(begin-for-syntax
  (define (subst bdy var rhs)
    (let loop ([stx bdy])
      (syntax-parse stx
        [x2:id #:when (free-identifier=? #'x2 var) rhs]
        #;[(f arg arg2)
           #`(#,(loop #'f) #,(loop #'arg) #,(loop #'arg2))]
        ; fix the below case, it breaks when there is a second let like
        ; (let ([a] 5) (+ a a a a (let ([b] 1) b)))
        ; (let ([b] 1) (let ([a] 5) a))
        [(f arg ...)
         (append (list #'#%app)
                 (for/list ([i (syntax->list stx)])
                   (loop i)))]
        [_ stx]))))

(define-syntax (mb stx)
  (syntax-parse stx
    [(_ aa:exp ...)
     #'(#%module-begin aa.code ...)]))