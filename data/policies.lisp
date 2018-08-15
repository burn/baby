(defun policies(depth)
   (let (out)
     (labels ((f (&optional (d 0) path)
		 (if (>= d depth)
		   (push path out)
		   (progn 
		     (f (+ d 1) (cons 1 path))
		     (f (+ d 1) (cons 0 path))))))
       (f)	
	out)))

(mapcar #'print  (policies 3))

