;;----------------------------------------------------------------------------
;; Multiple major modes
;;----------------------------------------------------------------------------
(require-package 'mmm-mode)
(require 'mmm-auto)
(setq mmm-global-mode 'buffers-with-submode-classes)
(setq mmm-submode-decoration-level 2)

(mmm-add-mode-ext-class 'html-mode "\\.php\\'" 'html-php)

(mmm-add-classes
 '((sql-postgres-python-function
    :submode python
    :delimiter-mode nil
    :front "\\$\\$"
    :back "\\$\\$ LANGUAGE plpython;")))

(mmm-add-mode-ext-class 'sql-mode "\\.sql\\'" 'sql-postgres-python-function)

(add-hook 'sql-mode-hook (lambda ()
                           (mmm-mode-on)
                           (sql-set-product 'postgres)))


(provide 'init-mmm)
