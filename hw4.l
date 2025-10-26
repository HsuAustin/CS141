(defun my-length (l)
    (cond 
        ((null l) 0)
        (t (1+ (my-length (cdr l))))))
