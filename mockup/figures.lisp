(defclass figure ()
  ())

(defgeneric ftypes (figure))
(defmethod ftypes ((figure (eql (find-class 'figure)))) nil)
(defgeneric fvalues (figure))
(defmethod fvalues ((figure figure)) nil)


(defgeneric html (figure))

(defclass parallel-figure (figure)
  ((parallel-figures 
    :reader parallel-figures 
    :reader figures
    :initarg :parallel-figures
    :type list)))

(defclass serial-figure (figure)
  ((serial-figs
    :reader parallell-figures
    :reader figures
    :initarg :serial-figures
    :type list)))

(defclass fvalue ()
  ((default
     :reader fvalue-default
     :initarg :default
     :type fvalue
     :initform nil)))

(defclass turn (fvalue)
  ;; clockwise is positive
  ((degrees :reader turn-degrees
            :initarg :degrees
            :initform (error "required initarg :degrees")
            :type fixnum)))

(defun turn-places (turn) (values (round (degrees turn) 90)))

(defclass simple-turning-figure (figure)
  ((degrees :reader figure-degrees :initarg :degrees :initform (error "required initarg :degrees" :type fixnum))))

;; this ain't gonna work right because eql method specialization doesn't inherit right
(defmethod ftypes ((figure simple-turning-figure))
  (cons (make-instance 'turn :degrees 270) (call-next-method)))

(defclass circle (simple-turning-figure)
  ()
  (:default-initargs :degrees 270))



(defmethod fvalues ((circle circle))
  (list (circle-places circle)))


(defmethod html ((circle circle))
  (destructuring-bind (turn) (pvalues circle)
    (format nil "circle ~A degrees"
            (html turn))))
