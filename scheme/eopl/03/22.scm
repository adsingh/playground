; EOPL exercise 3.22
;
; The concrete syntax of this section uses different syntax for a built-in
; operation, such as difference, from a procedure call. Modify the concrete
; syntax so that the user of this language need not know which operations are
; built-in and which are defined procedures. The exercise may range from very
; easy to hard, depending on the parsing technology being used.

; This is quite annoying using SLLGEN. I'm doing it with a particularly nasty
; function var-or-call that takes an ugly parse result and classifies it as a
; var-exp or a call-exp.
;
; If I was less lazy, I could get foo(1)(2) to work. I'm not.

(load-relative "cases/proc/env.scm")

; The parser

(define-datatype expression expression?
  (const-exp
    (num number?))
  (diff-exp
    (minuend expression?)
    (subtrahend expression?))
  (zero?-exp
    (expr expression?))
  (if-exp
    (predicate expression?)
    (consequent expression?)
    (alternative expression?))
  (var-exp
    (var symbol?))
  (let-exp
    (var symbol?)
    (value expression?)
    (body expression?))
  (proc-exp
    (var (list-of symbol?))
    (body expression?))
  (call-exp
    (rator expression?)
    (rand (list-of expression?))))

(define (var-or-call id args)
  (cond ((null? args) (var-exp id))
        ((= (length args) 1) (call-exp (var-exp id) (car args)))
        (else (eopl:error 'parse "Can't parse this"))))

(define scanner-spec
  '((white-sp (whitespace) skip)
    (comment ("%" (arbno (not #\newline))) skip)
    (identifier (letter (arbno (or letter digit))) symbol)
    (number (digit (arbno digit)) number)))

(define grammar
  '((expression (number) const-exp)
    (expression ("-" "(" expression "," expression ")") diff-exp)
    (expression (identifier (arbno "(" (separated-list expression ",") ")")) var-or-call)
    (expression ("zero?" "(" expression ")") zero?-exp)
    (expression ("if" expression "then" expression "else" expression) if-exp)
    (expression ("proc" "(" (separated-list identifier ",") ")" expression) proc-exp)
    (expression ("let" identifier "=" expression "in" expression) let-exp)))

(define scan&parse
  (sllgen:make-string-parser scanner-spec grammar))

; The evaluator

(define-datatype proc proc?
  (procedure
    (var (list-of symbol?))
    (body expression?)
    (saved-env environment?)))

(define (apply-procedure proc1 vals)
  (cases proc proc1
    (procedure (vars body saved-env)
      (value-of body (extend-env* vars vals saved-env)))))

(define-datatype expval expval?
  (num-val
    (num number?))
  (bool-val
    (bool boolean?))
  (proc-val
    (proc proc?)))

(define (expval->num val)
  (cases expval val
    (num-val (num) num)
    (else (eopl:error 'expval->num "Invalid number: ~s" val))))

(define (expval->bool val)
  (cases expval val
    (bool-val (bool) bool)
    (else (eopl:error 'expval->bool "Invalid boolean: ~s" val))))

(define (expval->proc val)
  (cases expval val
    (proc-val (proc) proc)
    (else (eopl:error 'expval->proc "Invalid procedure: ~s" val))))

(define (value-of expr env)
  (cases expression expr
    (const-exp (num) (num-val num))
    (var-exp (var) (apply-env env var))
    (diff-exp (minuend subtrahend)
      (let ((minuend-val (value-of minuend env))
            (subtrahend-val (value-of subtrahend env)))
        (let ((minuend-num (expval->num minuend-val))
              (subtrahend-num (expval->num subtrahend-val)))
          (num-val
            (- minuend-num subtrahend-num)))))
    (zero?-exp (arg)
      (let ((value (value-of arg env)))
        (let ((number (expval->num value)))
          (if (zero? number)
              (bool-val #t)
              (bool-val #f)))))
    (if-exp (predicate consequent alternative)
      (let ((value (value-of predicate env)))
        (if (expval->bool value)
            (value-of consequent env)
            (value-of alternative env))))
    (let-exp (var value-exp body)
      (let ((value (value-of value-exp env)))
        (value-of body
          (extend-env var value env))))
    (proc-exp (vars body)
      (proc-val (procedure vars body env)))
    (call-exp (rator rands)
      (let ((proc (expval->proc (value-of rator env)))
            (args (map (lambda (rand) (value-of rand env))
                       rands)))
        (apply-procedure proc args)))))

