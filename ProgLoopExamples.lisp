;; Converting PROG LOOPS
;; ABK 06/02/22: This is a file containing examples of how to convert PROG LOOPS into more elegant forms in Lisp.
;; These are typical patterns that I have found in our code and their typical solutions. Small adjustments
;; may be needed depending on the particular instance.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;  EX #0: DOLIST
;;;

;;; BEFORE
;; This is the pattern for a typical for/of or for/in loop, i.e. a loop that iterates over items of a list.
;; We can convert this construction into a DOLIST.

(SETQ MYLIST '(A B C D E F)) 
 (PROG (&V &L1 X)
              (SETQ &L1 MYLIST)
         LOOP (COND ((NULL &L1) (RETURN &V)))
              (SETQ X (CAR &L1))
              (SETQ &L1 (CDR &L1))
              (SETQ &V (PRINT X))
              (GO LOOP))

;;; AFTER
;; DOLIST takes the form: (DOLIST (item list) (loop-body))
;; The information we need to extract from the original PROG LOOP is:
    ;; (1) the current item of the list. This is indicated by the first SETQ command proceeding the LOOP COND.
    ;; (2) the list being looped over. This is indicated by the second SETQ command proceeding the LOOP COND.
    ;; (3) the loop body. This is indicated by the S-expression(s) nested immediately inside the SETQ &V.

(SETQ MYLIST '(A B C D E F)) 
(DOLIST (X MYLIST) ; For every item X in item MYLIST,
	(PRINT X)) ; Print x

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;  EX #1: DOLIST
;;;

;;; BEFORE
;; This is the pattern for a typical for/of or for/in loop, i.e. a loop that iterates over items of a list.
;; We can convert this construction into a DOLIST.

(PROG (&V &L1 X) ; Define local variables for this PROG
    (SETQ &L1 BLIST) ; Set local variable &L1 to parameter value BLIST. This is the list we will loop over.
    LOOP (COND ((NULL &L1) (RETURN &V))) ; Begin loop. If the list is empty, i.e. we looped over every item, exit loop.
            (SETQ X (CAR &L1)) ; X is the item we're currently iterating over.
            (SETQ &L1 (CDR &L1)) ; &L1 is set to the rest of the list after the first item, thus the next iteration will be over the next item, and so on.
            (SETQ &V ; Loop body
                (SETQ TREE (COND ((ZEROP X) (CADR TREE)) (T (CADDR TREE)))))
 (GO LOOP)) ; Go back up to LOOP

;;; AFTER
;; DOLIST takes the form: (DOLIST (item list) (loop-body))
;; The information we need to extract from the original PROG LOOP is:
    ;; (1) the current item of the list. This is indicated by the first SETQ command proceeding the LOOP COND.
    ;; (2) the list being looped over. This is indicated by the second SETQ command proceeding the LOOP COND.
    ;; (3) the loop body. This is indicated by the S-expression(s) nested immediately inside the SETQ &V.

(DOLIST (X BLIST) ; For every item X in item BLIST,
	(SETQ TREE (COND ((ZEROP X) (CADR TREE)) (T (CADDR TREE))))) ; Loop body

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;  EX #2: LOOP WHILE
;;;

;;; BEFORE
;; This is the pattern for a typical while loop, i.e. a loop that runs as long as a specified condition is true.
;; We can convert this construction into a LOOP WHILE form.

(PROG (&V) ; Define local variables for this PROG
    LOOP (COND ((NOT (ATOM (ERRSET (SETQ !TMP! (READ *GLOBAL-FILE-DESCRIPTOR* NIL)) T))) ; If this condition is satisfied, execute loop body.
                (SETQ &V ; Loop body
                    (PROG NIL
                        (PUTPROP !TMP! (READ *GLOBAL-FILE-DESCRIPTOR*) (QUOTE POSDIR))
                        (PUTPROP !TMP! (READ *GLOBAL-FILE-DESCRIPTOR*) (QUOTE NEGDIR))
                        (PUTPROP !TMP! (READ *GLOBAL-FILE-DESCRIPTOR*) (QUOTE SCALE)))))
        (T (RETURN &V))) ; If the above condition is not satisfied, exit loop.
(GO LOOP)) ; Go back up to LOOP

;;; AFTER
;; LOOP WHILE takes the form: (LOOP WHILE (condition) DO (loop-body))
;; The information we need to extract from the original PROG LOOP is:
    ;; (1) the condition for looping. This is indicated by S-expression immediately nested inside the LOOP COND.
    ;; (2) the loop body. This is indicated by the S-expression(s) nested immediately inside the SETQ &V. 
        ;; Note that we can leave out the PROG NIL expression.

(LOOP WHILE (NOT (ATOM (ERRSET (SETQ !TMP! (READ *GLOBAL-FILE-DESCRIPTOR* NIL)) T)))
    DO
	    (PUTPROP !TMP! (READ *GLOBAL-FILE-DESCRIPTOR*) (QUOTE POSDIR))
	    (PUTPROP !TMP! (READ *GLOBAL-FILE-DESCRIPTOR*) (QUOTE NEGDIR))
	    (PUTPROP !TMP! (READ *GLOBAL-FILE-DESCRIPTOR*) (QUOTE SCALE)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;  EX #3: DO
;;;

;;; BEFORE
;; This is the typical pattern for a loop that increments a value per iteration. 
;; We can convert this into a DO construction.

(PROG (&V &L1 &UPPER1 I) ; Define local variables for this PROG
    (SETQ &L1 1) ; Set the value at which we will begin incrementing.
    (SETQ &UPPER1 N1) ; Set the value at which the loop will terminate.
LOOP (COND ((*GREAT &L1 &UPPER1) (RETURN &V))) ; Begin loop. When &L1 > &UPPER1, terminate loop.
    (SETQ I &L1) ; Initialize the value which we will increment.
    (SETQ &L1 (ADD1 &L1)) ; Add 1 to our incrementing variable.
    (SETQ &V (SETF (AREF ALLPS I) (CONS (READ *GLOBAL-FILE-DESCRIPTOR*) NIL))) ; Loop body
    (GO LOOP)) ; Go back up to LOOP.

;;; AFTER
;; DO takes the form (DO (var1 (var1change), ..., varN (varNchange)) (end-condition) loop-body)
;; The information we need to extract from the original PROG LOOP is:
    ;; (1) the incrementing variable and its initial value. This is by indicated by the expressions (SETQ I &L1) and (SETQ &L1 1), respectively.
    ;; (2) the value by which the variable will increment. This is indicated by the expression (SETQ &L1 (ADD1 &L1)).
    ;; (3) the terminating condition. This is indicated by the expression (COND ((*GREAT &L1 &UPPER1) (RETURN &V))).
    ;; (4) the loop body. This is indicated by the S-expression(s) nested immediately inside the SETQ &V. 

(DO ((I 1 (1+ I))) ; Initialize incrementing variable I to 1. For every iteration, I will increment by 1.
    ((EQUAL I N1)) ; Terminate when variable I equals variable N1.
    (SETF (AREF ALLPS I) (CONS (READ *GLOBAL-FILE-DESCRIPTOR*) NIL))) ; Loop body.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;  EX #4: MAPCAN
;;;

;;; BEFORE
;; This is the pattern for a typical loop whose return value is a list of accumulated results from each loop iteration.
;; We can convert this into a MAPCAN construction.

(PROG (&V &VV &L1 X) ; Define local variables for this PROG 
       (SETQ &L1 NODELIST) ; Set local variable &L1 to parameter value NODELIST. This is the list we will loop over.
       (SETQ &V (SETQ &VV (LIST NIL)))
  LOOP (COND ((NULL &L1) (RETURN (CDR &V)))) ; Begin loop. If the list is empty, i.e. we looped over every item, exit loop.
       (SETQ X (CAR &L1)) ; X is the item we're currently iterating over.
       (SETQ &L1 (CDR &L1)) ; &L1 is set to the rest of the list after the first item, thus the next iteration will be over the next item, and so on.
       (NCONC &VV (SETQ &VV (LIST (CONS X (SYMBOL-PLIST X))))) ; Loop body. Append the result of this iteration to a list.
    (GO LOOP)) ; Go back up to LOOP

;;; AFTER
;; In this instance, MAPCAN takes the form: (MAPCAN (LAMBDA (item) loop-body) list)
;; The information we need to extract from the original PROG LOOP is:
    ;; (1) the current item of the list. This is indicated by the first SETQ command proceeding the LOOP COND.
    ;; (2) the loop body. This is indicated by the S-expression(s) nested immediately inside the SETQ &VV.
    ;; (3) the list being looped over. This is indicated by the second SETQ command proceeding the LOOP COND.

(MAPCAN (LAMBDA (X) ; For every item X
    (LIST (CONS X (SYMBOL-PLIST X)))) ; loop these commands
    NODELIST)) ; in list NODELIST
