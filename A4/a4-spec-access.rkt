#lang racket

(require rackunit)
(require "a4-spec-prog.rkt")


(check-equal? name 'AwsLukeXiao)
(check-equal? author 'UncleSamsHolyTrinity)
(check-equal? university 'IU)
(check-exn exn:fail? (thunk (dynamic-require "a4-spec-prog.rkt" 'privatename)))