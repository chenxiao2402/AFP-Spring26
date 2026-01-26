#lang racket

(require rackunit)

;; An Expression is one of:
;; - (if Expression Expression Expression)
;; - (lambda (Var) Expression)
;; - Variable -- just symbols
;; - Number
;; - (Expression Expression ...)
;; - (MACRO S-Expression ...)

;; - An S-Expression is one of:
;; - Number
;; - Symbol
;; - (S-Expression ...)

(define the-macros (make-hash))
(define (macro? m) (hash-ref the-macros m #f))
(define (get-macro m) (hash-ref the-macros m))

(define (extend-syntax! m proc)
  (hash-set! the-macros m proc))

;; expand : S-Expression -> Expression
;; expand all the macros
(define (expand s)
  (match s
    [(? number?) s]
    [(? symbol?) s]
    [(? void?) s]
    [`(lambda (,v) ,body)
     `(lambda (,v) ,(expand body))]
    [`(if ,tst ,thn ,els)
     `(if ,(expand tst) ,(expand thn) ,(expand els))]
    [`(,(? macro? m) ,operand ...)
     (expand ((get-macro m) s))]
    [`(,op ,operand ...)
     `(,(expand op) ,@(map expand operand))]))

(extend-syntax! 'or
                (lambda (s)
                  (match s
                    [`(or ,a ,b)
                     `(let ([x ,a])
                        (if x
                            x
                            ,b))]
                    [`(or ,a ,b ,c)
                     `(or ,a (or ,b ,c))])))

(extend-syntax! 'let
                (λ (s)
                  (match s
                     [`(let ((,x ,v)) ,b)
                      `((lambda (,x) ,b) ,v)])))

(define (interp s)
  (let loop ([s (expand s)])
    (match s
      [`(if ,(app loop #f) ,e1 ,e2) (loop e2)]
      [`(if ,(app loop 0) ,e1 ,e2) (loop e2)]
      [`(if ,(app loop x) ,e1 ,e2) (loop e1)]
      [`(lambda (,x) ,body)
       (lambda (v) (loop (subst x v body)))]
      #;[`(,(? macro? m) ,operand ...)
       (interp ((get-macro m) s))]
      [`(,f ,e ...) (apply (loop f) (map loop e))]
      [(? number?) s]
      [(? void?) s]
      [(? symbol?) s]
      [(? procedure?) s])))

(define (subst x v s)
  (match s
    [(== x) v]
    [`(if ,e1 ,e2 ,e3) `(if ,(subst x v e1)
                            ,(subst x v e2)
                            ,(subst x v e3))]
    [`(lambda (,x0) ,b)
     (if (eq? x0 x)
         s
         `(lambda (,x0)
            ,(subst x v b)))]
    [`+ +]
    [(list e ...) (map (lambda (e) (subst x v e)) e)]
    ['symbol=? symbol=?]
    ['zero? zero?]
    ['- -]
    ['* *]
    ['+ +]
    [_ s]))




;; our code

(extend-syntax! 'cond
                (lambda (s)
                  (match s
                    [`(cond [else ,s-exprELSE])
                     `,s-exprELSE]
                    [`(cond [,s-expr1 ,s-expr2])
                     `(if ,s-expr1
                          ,s-expr2
                          ,(void))]
                    [`(cond [,s-expr1 ,s-expr2] ,exprs ...)
                     `(if ,s-expr1
                          ,s-expr2
                          (cond ,@exprs))])))

(check-equal? (interp `(cond [1 3])) 3)
(check-equal? (interp `(cond [0 3] [else 5])) 5)


(extend-syntax! `case
                (lambda (s)
                  (match s
                    [`(case ,s-expr0 ,exprs ...)
                     `(let ((temp-var ,s-expr0))
                        (cond
                          ,@(map (lambda (exp)
                                   (match exp
                                     [`(,varN ,s-exprN)
                                      `[(symbol=? temp-var ,varN) ,s-exprN]]))
                                 exprs)))])))

(check-equal? (interp `(case x [y 1])) (void))
(check-equal? (interp `(case x [x 1])) 1)
(check-equal? (interp `(case x [x 2] [y 3])) 2)
(check-equal? (interp `(case x [z 1] [y 2] [x 3])) 3)
(check-equal? (interp `(case x [z 1] [y 2] [xx 3] [w 4])) (void))


(extend-syntax! 'Y-by-value-many
                (lambda (s)
                  (match s
                    [`(Y-by-value-many ,ff)
                     `(let ([fun (lambda (x) (,ff (lambda (args) ((x x) args))))])
                        (fun fun))])))

(extend-syntax! 'letrec
                (lambda (s)
                  (match s
                    [`(letrec ([,var1 ,s-expr1]) ,s-expr2)
                     `(let ([,var1 (Y-by-value-many (lambda (,var1) ,s-expr1))])
                        ,s-expr2)])))

(check-equal? (interp `(letrec ([fac (lambda (n) (if (zero? n) 1 (* n (fac (- n 1)))))]) (fac 5))) 120)
