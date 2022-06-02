;; Converting PROG LOOPS
;; ABK 06/02/22: This is a file containing examples of how to convert PROG LOOPS into more elegant forms in Lisp.
;; These are typical patterns that I have found in our code and their typical solutions. Small sdjustments
;; may be needed depending on the particular instance.

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