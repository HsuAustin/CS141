(defun my-assoc (v alist)
    (cond
        ((null alist) nil)
        ((eq (car (car alist)) v) (car alist))
        (t (my-assoc v (cdr alist)))))

(defun my-eval (e alist)
    (cond
        ((atom e) (my-eval-atom e alist))
        (t (my-apply (car e) (cdr e) alist))))

(defun my-eval-atom (e alist)
    (cond
        ((eq e 't) t)
        ((null e) nil)
        ((my-assoc e alist) (cdr (my-assoc e alist)))
        ((my-assoc e global-alist) (cdr (my-assoc e global-alist)))
        (t e)))


