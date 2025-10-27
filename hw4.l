(defun MY-LENGTH (L)
    (cond 
        ((null L) 0)
        (t (1+ (MY-LENGTH (cdr L))))))

(defun MY-MEMQ (A L)
    (cond
        ((null L) nil)
        ((eq A (car L)) L)
        (t (MY-MEMQ A (cdr L)))))

(defun MY-APPEND (L1 L2)
    (cond
        ((null L1) L2)
        (t (cons (car L1) (MY-APPEND (cdr L1) L2)))))

(defun MY-REVERSE-HELPER (L1 L2)
    (cond
        ((null L1) L2)
        (t (MY-REVERSE-HELPER (cdr L1) (cons (car L1) L2)))))

(defun MY-REVERSE (L)
    (MY-REVERSE-HELPER L nil))

(defun MY-MAPCAR (F L)
    (cond
        ((null L) nil)
        (t (cons (apply F (cons (car L) nil))
            (MY-MAPCAR F (cdr L))))))

(defun MY-COPY (L)
    (cond
        ((atom L) L)
        (t (cons (MY-COPY (car L))
            (MY-COPY (cdr L))))))

(defun MY-NTH (L N)
    (cond
        ((< N 1) (cons nil L))
        ((null L) nil)
        ((< (1- N) 1) L)
        (t (MY-NTH (cdr L) (1- N)))))

(defun MY-REMOVE (X L)
    (cond
        ((null L) nil)
        ((equal X (car L)) (MY-REMOVE X (cdr L)))
        (t (cons (car L) (MY-REMOVE X (cdr L))))))

(defun MY-SUBST (X Y Z)
    (cond
        ((atom Z) (cond ((equal Z X) Y) (t Z)))
        (t (cons (MY-SUBST X Y (car Z))
            (MY-SUBST X Y (cdr Z))))))

(defun MY-SUBSET (FN L)
    (cond
        ((null L) nil)
        ((apply FN (cons (car L) nil))
        (cons (car L) (MY-SUBSET FN (cdr L))))
        (t (MY-SUBSET FN (cdr L)))))

(defun MY-ADD-HELPER (N1 N2 CARRY)
    (cond
        ((and (null N1) (null N2))
        (cond ((> CARRY 0) (cons CARRY nil)) (t nil)))
        (t
        (cons
        (mod (+ (cond ((null N1) 0) (t (car N1)))
                (cond ((null N2) 0) (t (car N2)))
                CARRY)
            10)
        (MY-ADD-HELPER
        (cond ((null N1) nil) (t (cdr N1)))
        (cond ((null N2) nil) (t (cdr N2)))
        (floor (/ (+ (cond ((null N1) 0) (t (car N1)))
                        (cond ((null N2) 0) (t (car N2)))
                        CARRY)
                    10)))))))

(defun MY-ADD (N1 N2)
    (MY-ADD-HELPER N1 N2 0))

(defun MY-MERGE (L1 L2)
    (cond
        ((null L1) L2)
        ((null L2) L1)
        ((< (car L1) (car L2))
        (cons (car L1) (MY-MERGE (cdr L1) L2)))
        (t (cons (car L2) (MY-MERGE L1 (cdr L2))))))

(defun MY-SUBLIST-HELPER (L1 L2)
    (cond
        ((null L1) t)
        ((null L2) nil)
        ((eq (car L1) (car L2)) (MY-SUBLIST-HELPER (cdr L1) (cdr L2)))
        (t nil)))

(defun MY-SUBLIST (L1 L2)
    (cond
        ((null L1) t)
        ((null L2) nil)
        ((MY-SUBLIST-HELPER L1 L2) t)
        (t (MY-SUBLIST L1 (cdr L2)))))

(defun MY-ASSOC (A ALIST)
    (cond
        ((null ALIST) nil)
        ((and (not (atom (car ALIST)))
            (eq A (car (car ALIST))))
        (car ALIST))
        (t (MY-ASSOC A (cdr ALIST)))))

(defun MY-REPLACE-HELPER (ALIST A)
    (cond
        ((null ALIST) A)
        ((eq A (car (car ALIST))) (cdr (car ALIST)))
        (t (MY-REPLACE-HELPER (cdr ALIST) A))))

(defun MY-REPLACE (ALIST L)
    (cond
        ((atom L) (MY-REPLACE-HELPER ALIST L))
        (t (cons (MY-REPLACE ALIST (car L))
            (MY-REPLACE ALIST (cdr L))))))
