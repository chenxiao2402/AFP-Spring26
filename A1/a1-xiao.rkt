#lang racket

(require rackunit)



; Problem 1: Graph Data Structure

(struct Graph [V E])



; Problem 2: read-graph

(define (make-edge v1 v2)
  (if (symbol<? v1 v2) (cons v1 v2) (cons v2 v1)))


(define (process raw-graph)
  (define V (list->set (map car raw-graph)))
  (define E (list->set
             (for/fold ([edges '()])
                       ([vertex-neighbors raw-graph])
               (match-define `(,v ,neighs) vertex-neighbors)
               (append edges (map (lambda (dest) (make-edge v dest)) neighs)))))
  (Graph V E))


(define (read-graph path) (process (file->value path)))



; Problem 3: print-graph

(define (get-neighbors G v)
  (match-define (Graph V E) G)
  (flatten
   (for/list ([edge E])
     (match edge
       [`(,v1 . ,v2) #:when (equal? v v1)
                     (list v2)]
       [`(,v1 . ,v2) #:when (equal? v v2)
                     (list v1)]
       [`(,v1 . ,v2) '()]))))


(define (print-graph G)
  (match-define (Graph V E) G)
  (pretty-print (for/list ([v (sort (set->list V) symbol<?)])
                  (list v (sort (get-neighbors G v) symbol<?)))))



; Problem 4: spanning-tree

(define (spanning-tree G)
  (match-define (Graph V E) G)
  (match (set->list V)
    ['() (Graph (set) (set))]
    [`(,init-vertex ,vertices ...)
     ; Prim algorithm, grow a single connected spanning tree
     ; not using Kruskal since it can be tricky to detect cycles.
     (let loop ([G^ (Graph (set init-vertex) (set))]
                [worklist vertices])
       (match-define (Graph V^ E^) G^)
       (match worklist
         ['() G^]
         [`(,v ,rest ...)
          ; If the head of the worklist is not connected to the current spanning tree
          ; it will be put at the tail of the worklist so that we handle it in the future
          (define neighs-in-tree (set-intersect V (list->set (get-neighbors G v))))
          (cond
            [(empty? neighs-in-tree) (loop G^ (append rest (list v)))]
            [else (define n (car (set->list neighs-in-tree)))
                  (define g (Graph (set-add V^ v) (set-add E^ (make-edge v n))))
                  (loop g rest)])]))]))



; Problem 4: tests

(define (graph-size G)
  (match-define (Graph V E) G)
  (set-count V))


(define (reachable G root)
  (match-define (Graph V E) G)
  (let loop ([visited (set)]
             [worklist (list root)])
    (match worklist
      ['() visited]
      [`(,v ,rest ...) #:when (set-member? visited v)
                       (loop visited rest)]
      [`(,v ,rest ...) (loop (set-add visited v) (append rest (get-neighbors G v)))])))


(define (graph-connected? G)
  (match-define (Graph V E) G)
  (if (empty? V) #t (equal? V (reachable G (car (set->list V))))))


(define (spanning-tree? G)
  (match-define (Graph V E) G)
  (and (equal? (set-count V) (add1 (set-count E)))
       (graph-connected? G)))


(define graph1 (process '((A (B C)) (B (A C)) (C (A B)))))
(define graph2 (process
                '((A (B C D E))
                  (B (A C D E F G))
                  (C (A B D E))
                  (D (A B C F G))
                  (E (A B C F G))
                  (F (D E B))
                  (G (D E B)))))
(define graph3 (process
                '((A (B D))
                  (B (A C))
                  (C (B D))
                  (D (A C))
                  (E (D F))
                  (F (E G))
                  (G (D F)))))


(for ([G (list graph1 graph2 graph3)])
  (let ([T (spanning-tree G)])
    (check-equal? (graph-size T) (graph-size G))
    (check-pred spanning-tree? T)))