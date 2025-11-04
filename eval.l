(defun my-assoc (v alist)
    (cond
        ((null alist) nil)
        ((eq (car (car alist)) v) (car alist))
        (t (my-assoc v (cdr alist)))))

(defun my-eval (e alist)
    (cond
        ((atom e) (my-eval-atom e alist))
        (t (my-apply (car e) (cdr e) alist))))


