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

(defun my-apply (fn args alist)
    (cond
        ((atom fn) (my-apply-atom fn args alist))
        (t (my-apply-lambda fn args alist))))

(defun my-eval-list (l alist)
    (cond
        ((null l) nil)
        ((null (cdr l)) (my-eval (car l) alist))
        (t (my-eval (car l) alist) (my-eval-list (cdr l) alist))))

(defun my-apply-lambda (fn args alist)
    (cond
        ((eq (car fn) 'lambda)
        (my-eval-list (cdr (cdr fn)) (my-bind-formals (car (cdr fn)) args alist)))
        (t (my-eval-list (cdr fn) (my-bind-formals (car fn) args alist)))))

(defun my-bind-formals (formals actuals alist)
    (cond
        ((null formals) alist)
        (t (my-bind-formals (cdr formals) (cdr actuals) 
            (cons (cons (car formals) (my-eval (car actuals) alist)) alist)))))
