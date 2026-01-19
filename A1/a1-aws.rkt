#lang racket

; Problem 1
(struct edge [v1 v2])
(struct directed-graph [edge-list])

; Problem 2

; read-graph reads in a graph from a file and
; builds a graph according to our structs in Problem 1.
(define (read-graph x)
  (make-graph (file->value x)))

; Transforms the alist of edges into a directed-graph.
(define (make-graph ls)
  (directed-graph (build-graph ls)))

; Builds an alist of edges.
(define (build-graph ls)
  (match ls
    ('() '())
    ((cons a b) (append
                 (build-graph-helper (car a) (cadr a))
                 (build-graph b)))))

; Builds the edges
(define (build-graph-helper f l)
  (match l
    ('() '())
    ((cons a b) (cons
                 (edge f a)
                 (build-graph-helper f b)))))

; represent-graph is a helper development function that returns our directed-graph as an alist.
(define (represent-graph g)
  (cond
    ((directed-graph? g)
     (represent-graph-helper (directed-graph-edge-list g)))
    (else
     (represent-graph-helper g))))

; Builds the alist for represent-graph.
(define (represent-graph-helper g)
  (match g
    ('() '())
    (`(,a . ,b) (append
                 (list (append (list (edge-v1 a)) (list (edge-v2 a))))
                 (represent-graph-helper b)))))

; (define y '((A (B C)) (B (A C)) (C (A B)) (D ())))
; (represent-graph (directed-graph-edge-list (read-graph "a1-input1.txt")))
; (represent-graph (directed-graph-edge-list (make-graph y)))
; (represent-graph (read-graph "a1-input1.txt"))
; (represent-graph (make-graph y))
 
; Problem 3
; graph-to-hash is a helper function that converts
; our directed graph structure to a hash table.
(define graph-to-hash
  (lambda (graph)
    (define hash_set (make-hash))
    (for/list ([e (directed-graph-edge-list graph)])
      (cond
        [(hash-has-key? hash_set (edge-v1 e))
         (define current_val (hash-ref hash_set (edge-v1 e)))
         (hash-set! hash_set (edge-v1 e) (append current_val (list (edge-v2 e))))]
        [else
         (hash-set! hash_set (edge-v1 e) (list (edge-v2 e)))]))
    hash_set))

; print-graph prints a graph in the same s-expression representation (provided in the file).
; * NOTE: It uses the pretty-print function.
(define print-graph
  (lambda (graph)
    (define hash_set (graph-to-hash graph))
    (print hash_set)
    (define keys (hash-keys hash_set))
    (define res
      (for/list ([x (hash-keys hash_set)])
        (list x (hash-ref hash_set x))))
    (pretty-print res)))

; (print-graph (read-graph "a1-input1.txt"))

; Problem 4
(define (spanning-tree g)
  (match (directed-graph-edge-list g)
    ('() '())
    ((cons a b) (spanning-tree-helper '() (cons a b)))))

(define (spanning-tree-helper skip-list g)
  (match g
    ('() '())
    ((cons a b) (cond
                  [(memv (edge-v2 a) skip-list) (spanning-tree-helper skip-list b)]
                  [else (append (list a)
                                (spanning-tree-helper
                                 (append (list (edge-v1 a) (edge-v2 a)) skip-list)
                                 b))]))))

; (define rg (read-graph "a1-input1.txt"))
; rg
; (represent-graph (spanning-tree rg))
; (spanning-tree rg)
#; (represent-graph (spanning-tree (make-graph '((A (B D C))
                                                 (B (A C D))
                                                 (C (A B D))
                                                 (D (A B C))
                                                 ))))
#; (spanning-tree (make-graph '((A (B D C))
                                (B (A C D))
                                (C (A B D))
                                (D (A B C))
                                )))
; edsls?
; regex
; json
; latex sublanguages
; gdscript
; glsl

(require rackunit)
; P1 && P2
(check-equal? (directed-graph-edge-list (directed-graph '()))
              '())
(check-equal? (represent-graph (directed-graph-edge-list (read-graph "a1-input0.txt")))
              '())
(check-equal? (represent-graph (directed-graph-edge-list (read-graph "a1-input1.txt")))
              '((A B) (A C) (B A) (B C) (C A) (C B)))
(check-equal? (represent-graph (directed-graph-edge-list (read-graph "a1-input2.txt")))
              '((A B) (A D) (A C) (B A) (B C) (B D) (C A) (C B) (C D) (D A) (D B) (D C)))
; P3
(check-equal? (hash-count '#hash((A . (B D C)) (B . (A C D)) (C . (A B D)) (D . (A B C))))
              (hash-count (graph-to-hash (read-graph "a1-input2.txt"))))
(check-equal? (hash-count '#hash((A . (B C)) (B . (A C)) (C . (A B))))
              (hash-count (graph-to-hash (read-graph "a1-input1.txt"))))
(check-equal? (hash-count (graph-to-hash (read-graph "a1-input1.txt")))
              3)
(check-equal? (hash-count '#hash())
              (hash-count (graph-to-hash (read-graph "a1-input0.txt"))))
(check-equal? (hash-count (graph-to-hash (read-graph "a1-input0.txt")))
              0)
; P4
(check-equal? (represent-graph (spanning-tree (read-graph "a1-input0.txt"))) '())
(check-equal? (represent-graph (spanning-tree (read-graph "a1-input1.txt"))) '((A B) (A C)))
(check-equal? (represent-graph (spanning-tree (read-graph "a1-input2.txt"))) '((A B) (A D) (A C)))