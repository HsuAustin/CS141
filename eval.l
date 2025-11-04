(defvar global-alist nil) ; Stores global variables and function definitions

(defun my-assoc (v alist)
    "Finds an association for key V in ALIST."
    (cond
        ((null alist) nil)
        ((eq (car (car alist)) v) (car alist))
        (t (my-assoc v (cdr alist)))))

(defun my-eval (e alist)
    "The core evaluator function."
    (cond
        ((atom e) (my-eval-atom e alist))
        (t (my-apply (car e) (cdr e) alist))))

(defun my-eval-atom (e alist)
    "Evaluates an atom (self-evaluating, variable, t, or nil)."
    (cond
        ((eq e 't) t)
        ((null e) nil)
        ((my-assoc e alist) (cdr (my-assoc e alist)))
        ((my-assoc e global-alist) (cdr (my-assoc e global-alist)))
        (t e)))

(defun my-apply (fn args alist)
    "The core application function."
    (cond
        ((atom fn) (my-apply-atom fn args alist))
        (t (my-apply-lambda fn args alist))))

(defun my-evlis (l alist)
    "Evaluates a list of forms and returns a list of their results. (FIXED)"
    (cond
        ((null l) nil)
        (t (cons (my-eval (car l) alist) (my-evlis (cdr l) alist)))))

(defun my-eval-list (l alist)
    "Evaluates a sequence of forms (like a function body) and returns the result of the last one. (FIXED)"
    (cond
        ((null l) nil)
        ((null (cdr l)) (my-eval (car l) alist))
        (t (my-eval (car l) alist)
           (my-eval-list (cdr l) alist))))

(defun my-apply-lambda (fn args alist)
    "Applies a lambda function. (FIXED: Uses my-evlis to evaluate arguments)"
    (cond
        ((eq (car fn) 'lambda)
        (my-eval-list (cdr (cdr fn))
                      (my-bind-formals (car (cdr fn))
                                       (my-evlis args alist)
                                       alist)))
        (t (my-eval-list (cdr fn) (my-bind-formals (car fn) (my-evlis args alist) alist)))))

(defun my-bind-formals (formals actuals alist)
    "Binds actual values (actuals, which are already evaluated) to formal parameters."
    (cond
        ((null formals) alist)
        (t (my-bind-formals (cdr formals) (cdr actuals) 
            (cons (cons (car formals) (car actuals)) alist)))))

(defun my-eval-setq (var val)
    "Evaluates SETQ and updates the global-alist."
    (setq global-alist (cons (cons var (my-eval val global-alist)) global-alist))
    (cdr (car global-alist)))

(defun my-eval-cond (clauses alist)
    "Evaluates COND clauses."
    (cond
        ((null clauses) nil)
        ((my-eval (car (car clauses)) alist)
        (cond
            ((null (cdr (car clauses))) (my-eval (car (car clauses)) alist))
            (t (my-eval-list (cdr (car clauses)) alist))))
            (t (my-eval-cond (cdr clauses) alist))))

(defun my-eval-defun (body alist)
    "Evaluates DEFUN and stores the function as a lambda expression. (FIXED)"
    (let* ((name (car body))
           (formals (car (cdr body)))
           (lambda-body (cdr (cdr body)))
           (fun-val (cons 'lambda (cons formals lambda-body))))
        (setq global-alist (cons (cons name fun-val) global-alist))
        name))

(defun my-apply-atom (fn args alist)
    "Applies a built-in function or a globally defined one."
    (cond
        ((eq fn 'eq)
        (eq (my-eval (car args) alist) (my-eval (car (cdr args)) alist)))
        ((eq fn 'car) (car (my-eval (car args) alist)))
        ((eq fn 'cdr) (cdr (my-eval (car args) alist)))
        ((eq fn 'cons) (cons (my-eval (car args) alist) (my-eval (car (cdr args)) alist)))
        ((eq fn 'quote) (car args))
        ((eq fn 'setq) (my-eval-setq (car args) (car (cdr args))))
        ((eq fn 'cond) (my-eval-cond args alist))
        ((eq fn 'defun) (my-eval-defun args alist))
        ((eq fn 'eval) (my-eval (my-eval (car args) alist) alist))
        ((eq fn 'print) (print (my-eval (car args) alist)))
        ((eq fn 'atom) (atom (my-eval (car args) alist)))
        ((eq fn 'null) (null (my-eval (car args) alist)))
        ((eq fn 'listp) (listp (my-eval (car args) alist)))
        ((eq fn 'equal) (equal (my-eval (car args) alist) (my-eval (car (cdr args)) alist)))
        ((eq fn '+)
        (cond
            ((null args) 0)
            (t (+ (my-eval (car args) alist) (my-apply-atom '+ (cdr args) alist)))))
        ((eq fn '-)
        (cond
            ((null args) 0)
            ((null (cdr args)) (- (my-eval (car args) alist)))
            (t (- (my-eval (car args) alist)
                  (apply #'+ (my-evlis (cdr args) alist))))))
        ((eq fn 'mod)
        (mod (my-eval (car args) alist) (my-eval (car (cdr args)) alist)))
        ((eq fn 'floor)
        (cond
            ((null (cdr args)) (floor (my-eval (car args) alist)))
            (t (floor (/ (my-eval (car args) alist) (my-eval (car (cdr args)) alist))))))
        ((eq fn 'apply)
        (my-apply (my-eval (car args) alist) (my-eval (car (cdr args)) alist) alist))
        (t
        (cond
            ((my-assoc fn alist) (my-apply (cdr (my-assoc fn alist)) (my-evlis args alist) alist))
            ((my-assoc fn global-alist) (my-apply (cdr (my-assoc fn global-alist)) (my-evlis args alist) alist))
            (t nil)))))

(defun my-top ()
    "The Read-Eval-Print Loop."
    (prog ()
    top
        (print (my-eval (read) global-alist))
        (terpri)
        (go top)))