;;This file contains some of my easy templates for better org & babel

;;;CODE:

;; This adds :results, session, noweb and tangle.

;; (add-to-list 'org-structure-template-alist
;;              '("P" "#+BEGIN_SRC python :results output :noweb :tangle :session?\n\n#+END_SRC" "<src lang=\"?\">\n\n</src>"))

;; This adds just the results output.

;; (add-to-list 'org-structure-template-alist
;;              '("p" "#+BEGIN_SRC python :results output :noweb :tangle?\n\n#+END_SRC" "<src lang=\"?\">\n\n</src>"))

(provide 'init-templates)

;;init-templates ends here.
