#lang racket

(require rackunit)
(require "spec-prog1.rkt")

(check-equal? name 'AwsLukeXiao)
(check-equal? author 'UncleSamsHolyTrinity)
(check-equal? university 'IU)
(check-exn exn:fail? (thunk (dynamic-require "spec-prog1.rkt" 'privatename)))