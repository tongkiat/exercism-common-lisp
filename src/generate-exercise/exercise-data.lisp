(defpackage #:exercise-data
  (:use #:cl)
  (:export #:read-exercise-data
           #:exercise-name
           #:exercise-version
           #:exercise-comments
           #:exercise-cases
           #:exercise-all-function-info
           #:exercise-case-name
           #:exercise-case-function-info
           #:exercise-case-inputs
           #:exercise-case-expected))

(in-package :exercise-data)

(defun read-exercise-data (exercise-pathname)
  (with-open-file (stream exercise-pathname
                          :direction :input
                          :if-does-not-exist :error)
    (cl-json:decode-json-strict stream)))

(defun exercise-name (exercise-data)
  (cdr (assoc :exercise exercise-data)))

(defun exercise-comments (exercise-data)
  (cdr (assoc :comments exercise-data)))

(defun exercise-version (exercise-data)
  (cdr (assoc :version exercise-data)))

(defun exercise-cases (exercise-data)
  (cdr (assoc :cases exercise-data)))

(defun exercise-case-name (exercise-case)
  (cdr (assoc :description exercise-case)))

(defun exercise-case-function-info (exercise-case)
  (cons (intern (string-upcase (cdr (assoc :property exercise-case))) :keyword)
        (mapcar #'car (cdr (assoc :input exercise-case)))))

(defun exercise-case-inputs (exercise-case)
  (mapcar #'cdr (cdr (assoc :input exercise-case))))

(defun exercise-case-expected (exercise-case)
  (let ((expected (cdr (assoc :expected exercise-case))))
    (if (and (listp expected)
             (listp (car expected))
             (eq (caar expected) :error))
        (car expected)
        expected)))

(defun exercise-all-function-info (exercise-data)
  (reduce
   #'(lambda (acc case)
       (dolist (fn
                (if (exercise-cases case)
                    (exercise-all-function-info case)
                    (list (exercise-case-function-info case)))
                acc)
         (pushnew fn acc :test #'equal)))
   (exercise-cases exercise-data)
   :initial-value (list)))
