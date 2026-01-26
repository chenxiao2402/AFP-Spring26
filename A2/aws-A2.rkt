#lang racket

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
    [`(lambda (,v) ,body)
     `(lambda (,v) ,(expand body))]
    [`(if ,tst ,thn ,els)
     `(if ,(expand tst) ,(expand thn) ,(expand els))]
    [`(,(? macro? m) ,operand ...)
     (expand ((get-macro m) s))]
    [`(,op ,operand ...)
     `(,(expand op) ,@(map expand operand))]
    [(? void?) s] ;;;;;;; added ;;;;;;;
    ))

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



;; interpret the program
(define (interp s)
  (let loop ([s (expand s)])
    (match s
      [`(if ,(app loop #f) ,e1 ,e2) (loop e2)] ;;;;;;; added ;;;;;;;
      [`(if ,(app loop 0) ,e1 ,e2) (loop e2)]
      [`(if ,(app loop x) ,e1 ,e2) (loop e1)]
      [`(lambda (,x) ,body)
       (lambda (v) (loop (subst x v body)))]
      #;[`(,(? macro? m) ,operand ...)
         (interp ((get-macro m) s))]
      [`(,f ,e ...) (apply (loop f) (map loop e))]
      [(? number?) s]
      [(? void?) s] ;;;;;;; added ;;;;;;;
      [(? symbol?) s] ;;;;;;; added ;;;;;;;
      [(? procedure?) s] ;;;;;;; added ;;;;;;;
      )))

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
    [`symbol=? symbol=?]  ;;;;;;; added ;;;;;;;
    [(list e ...) (map (lambda (e) (subst x v e)) e)]
    [_ s]))


(interp '(let ([x 1]) (or x (+ x 2))))

(interp '((lambda (x) (or x 2 y)) 0))

(interp `(let ([x 10]) (or 0 x)))

;; Main code for assignment 2
(extend-syntax! 'cond
                (λ (s)
                  (match s
                    #; ; no need for this case
                    [`(cond)
                     (void)]
                    [`(cond
                        [else ,S-expression1-2])
                     `,S-expression1-2]
                    
                    [`(cond
                        [,S-expression1-1 ,S-expression1-2])
                     `(if ,S-expression1-1
                          ,S-expression1-2
                          ,(void))]
                    
                    [`(cond
                        [,S-expression1-1 ,S-expression1-2]
                        ,exprs ...
                        )
                     `(if ,S-expression1-1
                          ,S-expression1-2
                          (cond ,@exprs))]
                    )))

(require rackunit)

; (check-equal? (interp `(cond)) (void))
(check-equal? (interp `(cond
                         [else 0])) 0)
(check-equal? (interp `(cond
                         [0 1])) (void))
(check-equal? (interp `(cond
                         [1 1])) 1)
(check-equal? (interp `(cond
                         [0 1]
                         [0 2])) (void))
(check-equal? (interp `(cond
                         [0 1]
                         [1 2])) 2)
(check-equal? (interp `(cond
                         [0 1]
                         [0 2]
                         [1 3])) 3)
(check-equal? (interp `(cond
                         [0 1]
                         [else 4])) 4)
(check-equal? (interp `(cond
                         [0 1]
                         [0 2]
                         [0 3]
                         [0 4]
                         [1 5])) 5)
(check-equal? (interp `(cond
                         [0 1]
                         [0 2]
                         [0 3]
                         [0 4]
                         [0 5]
                         [else 6])) 6)

(match `(case 1
          (1 2))
  [`(case ,S-expression0
      [,Variable1 ,S-expression1]) S-expression1])

(extend-syntax! 'case (λ (s)
                        (match s
                          #; ; no need for this case
                          [`(case ,S-expression0
                              [else ,S-expressionN])
                           S-expressionN]
                          
                          [`(case ,S-expression0
                              [,Variable1 ,S-expression1])
                           `(let ((temporary-variable ,S-expression0))
                              (cond
                                [(symbol=? temporary-variable ,Variable1) ,S-expression1]))]
                          
                          [`(case ,S-expression0
                              [,Variable1 ,S-expression1]
                              ,exprs ...
                              )
                           `(let ((temporary-variable ,S-expression0))
                              (cond
                                [(symbol=? temporary-variable ,Variable1) ,S-expression1]
                                ,@(map (λ (exp)
                                         (match exp
                                           [`[,variableN ,expressionN]
                                            `[(symbol=? temporary-variable ,variableN) ,expressionN]]
                                           [`[else ,expressionN]
                                            `[else ,expressionN]]))
                                       exprs)))]
                          )))

(check-equal? (interp `(case x
                         [y 1])) (void))

(check-equal? (interp `(case x
                         [x 1])) 1)

(check-equal? (interp `(case x
                         [x 2]
                         [y 3])) 2)

(check-equal? (interp `(case x
                         [z 1]
                         [y 2]
                         [x 3])) 3)

(check-equal? (interp `(case x
                         [z 1]
                         [y 2]
                         [xx 3]
                         [w 4])) (void))


(case (- 7 5)
  [(1 2 3) 'small]
  [(10 11 12) 'big]
  [else 'medium])

(case (+ 7 50)
  [(1 2 3) 'small]
  [(10 11 12) 'big]
  [else 'medium])

(case (+ 7 5)
  [(1 2 3) 'small]
  [(10 11 12) 'big]
  [else 'medium])

;; get to fixing symbols later