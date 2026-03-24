#lang racket

(struct File (header tracks) #:transparent)
(struct FileHeader (type length format track-count time-division) #:transparent)
(struct Track (header messages) #:transparent)
(struct TrackHeader (type track-length) #:transparent)
; types of messages
(struct MetaEvent (delta-time meta-type length args) #:transparent)
(struct PitchBend (delta-time args) #:transparent)
(struct NoteOn (delta-time note velocity) #:transparent)
(struct NoteOff (delta-time note velocity) #:transparent)

(define +-hex
  (lambda (a b c d)
    (+ (* 16777216 a) (* 65536 b) (* 256 c) d)))

(define get-header
  (lambda (file)
    (begin
      (define type (string (read-char file) (read-char file) (read-char file) (read-char file)))
      (unless (string=? type "MThd") (error "file header incorrect"))
      (define length (+ (read-byte file) (read-byte file) (read-byte file) (read-byte file)))
      (unless (eqv? length 6) (error "file header length incorrect"))
      (define format (+ (read-byte file) (read-byte file)))
      (define track-count (+-hex 0 0 (read-byte file) (read-byte file)))
      (define time-division (+-hex 0 0 (read-byte file) (read-byte file)))
      (FileHeader type length format track-count time-division))))

(define get-track-header
  (lambda (file)
    (begin
      (define type (string (read-char file) (read-char file) (read-char file) (read-char file)))
      (unless (string=? type "MTrk") (error "track header incorrect"))
      (define track-length (+-hex (read-byte file) (read-byte file) (read-byte file) (read-byte file)))
      (TrackHeader type track-length))))

(define get-message
  (lambda (delta-time file)
    (define byte (read-byte file))
    (match byte
      [255
       (define meta-type (read-byte file))
       (define length (read-byte file))
       (define args (fetch-n-bytes file length))
       (MetaEvent (solve-vlq delta-time) meta-type length args)]
      [224
       (define args (fetch-n-bytes file 2))
       (PitchBend (solve-vlq delta-time) args)]
      [144
       (define note (read-byte file))
       (define velocity (read-byte file))
       (NoteOn (solve-vlq delta-time) note velocity)]
      [128
       (define note (read-byte file))
       (define velocity (read-byte file))
       (NoteOff (solve-vlq delta-time) note velocity)]
      [else
       (get-message (append delta-time (list byte)) file)])))

(define fetch-n-bytes
  (lambda (file n)
    (if (zero? n)
        '()
        (cons (read-byte file) (fetch-n-bytes file (- n 1))))))

(define get-messages
  (lambda (file)
    (let ([msg (get-message '() file)])
      (if (and (MetaEvent? msg) (eqv? (MetaEvent-meta-type msg) 47))
          (cons msg '())
          (cons msg (get-messages file))))))


(define file (open-input-file "hellow2.mid"))

(define parse-file
  (lambda (file)
    (File
     (get-header file)
     (list (Track (get-track-header file) (get-messages file))
           (Track (get-track-header file) (get-messages file))
           (Track (get-track-header file) (get-messages file))
           (Track (get-track-header file) (get-messages file))))))

(define solve-vlq
  (lambda (ls)
    (define result 0)
    (for ([e ls])
      (set! result (+ (arithmetic-shift result 7) (bitwise-and e #x7F))))
    result))

(define parsed-file (parse-file file))

(define get-time-division
  (lambda (fstruct)
    (match fstruct
      [(File header messages)
       (match header
         [(FileHeader type length format tracks time-division)
          time-division])])))

(define time-division (get-time-division parsed-file))

(define d-t-d
  (lambda (fstruct timed)
    (match fstruct
      [(File header messages)
       (File header (for/list ([e messages])
                      (d-t-d e timed)))]
      [(Track header messages)
       (Track header (for/list ([e messages])
                       (d-t-d e timed)))]
      [(MetaEvent div a b c)
       (MetaEvent (/ div timed) a b c)]
      [(NoteOff div a b)
       (NoteOff (/ div timed) a b)]
      [(NoteOn div a b)
       (NoteOn (/ div timed) a b)]
      [else
       fstruct])))

(define out (d-t-d parsed-file time-division))