#lang racket

(require rackunit)

;; An Expression is one of:
;; - (if Expression Expression Expression)
;; - (λ (Var) Expression)
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
    [`() s]
    [`(,head : ,rest) `(,(expand head) : ,(expand rest))]
    [(? number?) s]
    [(? symbol?) s]
    [`(λ (,v) ,body)
     `(λ (,v) ,(expand body))]
    [`(if ,tst ,thn ,els)
     `(if ,(expand tst) ,(expand thn) ,(expand els))]
    [`(,(? macro? m) ,operand ...)
     (expand ((get-macro m) s))]
    [`(,op ,operand ...)
     `(,(expand op) ,@(map expand operand))]
    [(? void?) s]
    ))

;; interpret the program
(define (interp s)
  (let loop ([s (expand s)])
    (match s
      [`() s]
      [`(,head : ,rest) `(,(loop head) : ,(loop rest))]
      [`(if ,(app loop `()) ,e1 ,e2) (loop e2)]
      [`(if ,(app loop #f) ,e1 ,e2) (loop e2)]
      [`(if ,(app loop 0) ,e1 ,e2) (loop e2)]
      [`(if ,(app loop x) ,e1 ,e2) (loop e1)]
      [`(car (,head : ,rest)) head]
      [`(cdr (,head : ,rest)) rest]
      [`(λ (,x) ,body)
       (λ (v) (loop (subst x v body)))]
      [`(,f ,e ...) (apply (loop f) (map loop e))]
      [`+ +]
      [`- -]
      [`* *]
      [`symbol=? symbol=?]
      [(? procedure?) s]
      [(? number?) s]
      [(? symbol?) s]
      [(? void?) s])))


(define (subst x v s)
  (match s
    [(== x) v]
    [`(if ,e1 ,e2 ,e3) `(if ,(subst x v e1)
                            ,(subst x v e2)
                            ,(subst x v e3))]
    [`(λ (,x0) ,b)
     (if (eq? x0 x)
         s
         `(λ (,x0)
            ,(subst x v b)))]
    [`+ +]
    [`- -]
    [`* *]
    [`symbol=? symbol=?]
    [`(,e ...) (map (λ (e) (subst x v e)) e)]
    [_ s]))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Auxiliary macros
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(extend-syntax! 'zero?
                (λ (s)
                  (match s
                    [`(zero? ,a) `(let ([x ,a]) (if x 0 1))])))

(extend-syntax! 'or
                (λ (s)
                  (match s
                    [`(or ,a ,b) `(let ([x ,a]) (if x x ,b))]
                    [`(or ,a ,b ,c) `(or ,a (or ,b ,c))])))

(extend-syntax! 'and
                (λ (s)
                  (match s
                    [`(and ,a ,b) `(let ([x ,a]) (if x ,b x))]
                    [`(and ,a ,b ,c) `(and ,a (and ,b ,c))])))


(extend-syntax! 'let
                (λ (s)
                  (match s
                    [`(let ((,x ,v)) ,b)
                     `((λ (,x) ,b) ,v)])))


(extend-syntax! 'Z-comb
                (λ (s)
                  (match s
                    [`(Z-comb ,f)
                     `(let ([fun (λ (x) (,f (λ (args) ((x x) args))))])
                        (fun fun))])))

(extend-syntax! 'list
                (λ (s)
                  (match s
                    [`(list) `()]
                    [`(list ,head ,rest ...) `(,head : (list ,@rest))])))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Main code for assignment 2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(extend-syntax! 'cond
                (λ (s)
                  (match s
                    [`(cond [else ,thn]) thn]
                    [`(cond [,cnd ,thn]) `(if ,cnd ,thn ,(void))]
                    [`(cond [,cnd ,thn] ,rest ...)
                     `(if ,cnd ,thn (cond ,@rest))])))


(extend-syntax! 'case
                (λ (s)
                  (match s
                    [`(case ,expr0 [,var1 ,thn1] ,rest ...)
                     `(let ([tmp ,expr0])
                        (cond
                          [(symbol=? tmp ,var1) ,thn1]
                          ,@(map (λ (exp) (match exp
                                            [`[,var2 ,thn2]
                                             `[(symbol=? tmp ,var2) ,thn2]]))
                                 rest)))])))

(extend-syntax! 'letrec
                (λ (s)
                  (match s
                    [`(letrec () ,body) body]
                    [`(letrec ([,var ,rhs] ,rest ...) ,body)
                     `(let ([,var (Z-comb (λ (,var) ,rhs))])
                        (letrec ,rest ,body))])))

              

(extend-syntax! 'loop
                (λ (s)
                  (match s
                    [`(loop ,f (,n ,rhs) ,body)
                     `(letrec ([,f (λ (,n) ,rhs)]) ,body)])))




(extend-syntax! 'for/list
                (λ (s)
                  (match s
                    [`(for/list ([,var ,lst]) ,body)
                     `(letrec ([map (λ (l)
                                      (if l
                                          ((let ([,var (car l)]) ,body) : (map (cdr l)))
                                          ()))])
                        (map ,lst))])))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Test Cases for 'cond
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(check-equal? (interp `(cond [else 0]))
              0)

(check-equal? (interp `(cond [0 1]))
              (void))

(check-equal? (interp `(cond [1 1]))
              1)

(check-equal? (interp `(cond
                         [0 1]
                         [0 2]))
              (void))

(check-equal? (interp `(cond
                         [0 1]
                         [1 2]
                         [else 3]))
              2)

(check-equal? (interp `(cond
                         [0 1]
                         [0 2]
                         [1 3]))
              3)

(check-equal? (interp `(cond
                         [0 1]
                         [else 4]))
              4)

(check-equal? (interp `(cond
                         [0 1]
                         [0 2]
                         [0 3]
                         [0 4]
                         [1 5]))
              5)

(check-equal? (interp `(cond
                         [0 1]
                         [0 2]
                         [0 3]
                         [0 4]
                         [0 5]
                         [else 6]))
              6)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Test Cases for 'case
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(check-equal? (interp `(case x [y 1]))
              (void))

(check-equal? (interp `(case x
                         [x 2]
                         [y 3]))
              2)

(check-equal? (interp `(case x
                         [z 1]
                         [y 2]
                         [x 3]))
              3)

(check-equal? (interp `(case x
                         [z 1]
                         [y 2]
                         [xx 3]
                         [w 4]))
              (void))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Test Cases for 'letrec
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(check-equal? (interp `(letrec ([fib (λ (n) (if (or (zero? n) (zero? (- n 1))) 1 (+ (fib (- n 2)) (fib (- n 1)))))]) (fib 8)))
              34)

(check-equal? (interp `(letrec ([fac (λ (n) (if (zero? n) 1 (* n (fac (- n 1)))))]) (fac 6)))
              720)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Test Cases for 'loop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(check-equal? (interp `(loop sum (n (if (zero? n) 0 (+ n (sum (- n 1))))) (sum 10)))
              55)

(check-equal? (interp `(loop fib (n (if (or (zero? n) (zero? (- n 1))) 1 (+ (fib (- n 2)) (fib (- n 1))))) (fib 8)))
              34)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Test Cases for 'for/list
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(check-equal? (interp `(for/list ([i (list 1 2 3 4 5)]) (+ i 1)))
              (interp `(list 2 3 4 5 6)))

(check-equal? (interp `(for/list ([i (list 1 2 3 4 5)]) (* i 2)))
              (interp `(list 2 4 6 8 10)))