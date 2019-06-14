;;; Web-mode.el taken verbatim from Howard Abrams emacs files.

(use-package web-mode
  :ensure t)

(use-package mustache-mode
  :ensure t)

;;; No package named css!
;; (use-package css
;;   :init
;;   (setq css-indent-offset 2))

;;smart parens

(use-package smartparens
  :init (add-hook 'css-mode-hook 'smartparens-mode))

(defun surround-html (start end tag)
  "Wraps the specified region (or the current 'symbol / word'
 with a properly formatted HTML tag."
  (interactive "r\nsTag: " start end tag)
  (save-excursion
    (narrow-to-region start end)
    (goto-char (point-min))
    (insert (format "<%s>" tag))
    (goto-char (point-max))
    (insert (format "</%s>" tag))
    (widen)))

;; (define-key html-mode-map (kbd "C-c C-w") 'surround-html)

(use-package emmet-mode
  :ensure t
  :commands emmet-mode
  :init
  (setq emmet-indentation 2)
  (setq emmet-move-cursor-between-quotes t)
  :config
  (add-hook 'sgml-mode-hook 'emmet-mode) ;; Auto-start on any markup modes
  (add-hook 'css-mode-hook  'emmet-mode)) ;; enable Emmet's css abbreviation.

(use-package skewer-mode
  :ensure t
  :commands skewer-mode run-skewer
  :config (skewer-setup))

(provide 'init-web)
;;; init-web.el ends here.
