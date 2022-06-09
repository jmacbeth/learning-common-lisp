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
     LOOP 
       (COND ((NULL &L1) (RETURN &V)))
       (SETQ X (CAR &L1))
       (SETQ &L1 (CDR &L1))
       (SETQ &V (PRINT X))
       (GO LOOP))

;; NOTES ABOUT PROG
;; PROG is short for "program".  It is "the program" feature, and lets you
;; write code that looks more like "imperative" programming language programs (e.g. C, C++, Java, Python, Fortran)
;; PROG allows you to bind local variables that only exist inside the PROG, followed by a series of 
;; forms which are evaluated in order.
;; PROG allows GO statements which cause execution of the PROG to jump unconditionally to a label within the PROG
;; (Similar to GOTO in Fortran, or JUMP instructions in assembly language)
;; and it allows RETURN statements which exit out of the PROG.  The LISP code we work with in many projects has PROGs
;; that were generated based on compilation of code in a higher-level language called MLISP.  Because the code is generated
;; it tends to have a lot of generic and non-descriptive variable names (e.g. &V, &L1, etc.) and much of the important 
;; work to be done is refactoring this code to make it more elegant and easy to understand.  The PROG above represents a simple
;; loop that simply calls PRINT on each element of the list MYLIST.  The following is an explanation of how it works.

;; For the PROG above, the first expression after the PROG keyword, (&V &L1 X), establishes these three variables
;; as "local" variables for the PROG, and initializes them to NIL.  Note that for &V and &L1, the ampersand, "&"
;; is not an operator (like it is in C), it is actually part of the variable name.  Because LISP has very few
;; special operator symbols, and mostly uses functions instead (e.g. (+ x y) to add x and y), allows you to use special
;; symbols like +, -, & and ! as part of variable names and function names.

;; The second expression, (SETQ &L1 MYLIST) uses the SETQ function/form to 
;; assign &L to the value of MYLIST, which is '(A B C D).  Lisp doesn't use = as the assignment operator like Python, Java, or C.
;; Instead the special form SETQ is used.  It takes two arguments, the first is the symbol whose value is to be assigned, and the second
;; is the value to assign to that symbol.  So (SETQ &L1 MYLIST) is something like "&L1 = MYLIST;" in Java (but, again, Java probably  
;; won't allow you to have &L1 as a variable name.)

;; The third line in the prog has the symbol/"atom" LOOP on its own.  This is called a "tag" and it serves a similar function to 
;; labels in assembly language.  Tags are ignored and not processed, but serve a function in relation to GO statements (see below).
;; Tags can be simple symbols (like LOOP or END) or they can be integers like 1, 2, 0, 50.

;; The next expression, (COND ((NULL &L1) (RETURN &V))), is a COND.  You probably know that a cond is somewhat of a cross
;; between an "if" statement and a "switch" statement in Java.  A cond consists of a series of (what some call) "stanzas" that
;; are enclosed in parentheses.  This COND only has one stanza.  Inside each stanza is a series of Lisp expressions.
;; The COND will evaluate the first expression in the stanza.  If the expression evaluates to nil, nothing else happens with that stanza, 
;; and the COND moves on to the next stanza.  If this is the last or only stanza, then the COND ends and returns/evaluates to NIL.  
;;  If the expression evaluates to something non-nil (e.g. T, or any other 
;; Lisp object or value), then the COND evaluates all of the other forms in the stanza in order, doesn't evaluate any other stanzas,
;; and the COND returns/evaluates to the value of the last form in the stanza.
;; So, for this COND, the first expression (NULL &L1) uses the NULL function which evaluates its argument, and 
;; returns T if &L1 is NIL, or the empty list (also known as "()" ), and NIL otherwise.
;; If &L1 is the empty list then the next form (RETURN &V) is evaluated.  Inside of a PROG, RETURN is a special form that, as one
;; might expect, immediately exits the PROG and has the PROG return the value that is its argument.  So the COND basically
;; checks to see if &L1 is the empty list, and if it is, makes the PROG return the value of &V. This serves the function of exiting the
;; loop at the appropriate time (see below to see how &L1 ends up being the empty list).  The first time through the loop, however, 
;; &L1 is (A B C D), so this won't happen.  In this case the COND will evaluate (NULL &L1) which will return NIL (since &L1 is not NIL), 
;; and the COND executes no further.  The PROG will move on to the next expression.

;; The next expression (SETQ X (CAR &L1)) ...

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

(PROG (&V &L1 &UPPER1 I)
    (SETQ &L1 1)
    (SETQ &UPPER1 N1)
LOOP (COND ((*GREAT &L1 &UPPER1) (RETURN &V)))
    (SETQ I &L1)
    (SETQ &L1 (ADD1 &L1))
    (SETQ &V (SETF (AREF ALLPS I) (CONS (READ *GLOBAL-FILE-DESCRIPTOR*) NIL)))
    (GO LOOP))

;;; AFTER

(DO ((I 1 (1+ I)))
    ((EQUAL I N1))
    (SETF (AREF ALLPS I) (CONS (READ *GLOBAL-FILE-DESCRIPTOR*) NIL)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;  EX #4: MAPCAN
;;;

;;; BEFORE

(PROG (&V &VV &L1 X)
       (SETQ &L1 NODELIST)
       (SETQ &V (SETQ &VV (LIST NIL)))
  LOOP (COND ((NULL &L1) (RETURN (CDR &V))))
       (SETQ X (CAR &L1))
       (SETQ &L1 (CDR &L1))
       (NCONC &VV (SETQ &VV (LIST (CONS X (SYMBOL-PLIST X)))))
    (GO LOOP))
  (LET ((PROPLIST '()))
   (DOLIST (X NODELIST PROPLIST)
     (SETQ PROPLIST (APPEND PROPLIST (LIST (CONS X (SYMBOL-PLIST X)))))))

;;; AFTER

(MAPCAN (LAMBDA (X)
    (LIST (CONS X (SYMBOL-PLIST X))))
    NODELIST))
