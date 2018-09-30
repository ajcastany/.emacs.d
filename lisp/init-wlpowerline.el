;;;Lets see if i can make this work

;;(require 'powerline) bellow should work best!.

(use-package powerline
  :ensure t
  :init
  (setq powerline-default-separator 'arrow
        powerline-default-separator-dir (quote (left . right))
        powerline-height 28 ;no changes
        powerline-display-buffer-size nil
        powerline-display-hud nil
        powerline-display-mule-info nil
        powerline-gui-use-vcs-glyph t
        powerline-inactive1 '((t (:background "grey11" :foreground "#c5c8c6")))
        powerline-inactive2 '((t (:background "grey20" :foreground "#c5c8c6")))))


;;;Trying to trim down the modeline
(require 'delight)
(defadvice powerline-major-mode (around delight-powerline-major-mode activate)
  "Ensure that powerline's major mode names are delighted.

See `delight-major-mode'."
  (let ((inhibit-mode-name-delight nil))
    ad-do-it))

                                        ;(require 'init-delight-powerline)

(defun powerline-get-icon (name alt-sym help-message)
  "Returns a propertized icon if available, otherwise, returns ALT-SYM."
  (propertize alt-sym 'help-echo help-message))

(defun powerline-modified ()
  (condition-case ex
      (let ((state (vc-git-state (buffer-file-name))))
        (cond ((buffer-modified-p)  (powerline-get-icon "pencil" "✦" "Modified buffer"))
              ((eq state 'edited)   (powerline-get-icon "pencil" "✦" "Modified buffer, unregistered changes"))
              ((eq state 'unregistered) (powerline-get-icon "question" "❓" "Unregistered file in VCS"))
              ((eq state 'missing)  (powerline-get-icon "exclamation" "⁈" "File exists only in VCS, not on the hard disk"))
              ((eq state 'ignored)  (powerline-get-icon "ban" "♟" "Ignored file in VCS"))
              ((eq state 'added)    (powerline-get-icon "plus" "➕" "File will be registered in VCS in the next commit"))
              (t " ")))
    (error (powerline-get-icon "exclamation" "⁈" (car ex)))))

(defun powerline-project-vc ()
  (ignore-errors
    (when (projectile-project-p)
      (propertize (projectile-project-name)
                  'help-echo (format "Base: %s"
                                     (projectile-project-root))))))
;;config:

(defun trim-minor-modes (s)
  (replace-regexp-in-string "ARev" "↺" s))

;;This is the format (check for evil-words)

(setq-default mode-line-format
              '("%e"
                (:eval
                 (let* ((active (powerline-selected-window-active))
                        (mode-line-buffer-id (if active 'mode-line-buffer-id 'mode-line-buffer-id-inactive))
                        (mode-line (if active 'mode-line 'mode-line-inactive))
                        (face1 (if active 'powerline-active1 'powerline-inactive1))
                        (face2 (if active 'powerline-active2 'powerline-inactive2))
                                        ;(eface (powerline-evil-face active))
                        (separator-left (intern (format "powerline-%s-%s"
                                                        (powerline-current-separator)
                                                        (car powerline-default-separator-dir))))
                        (separator-right (intern (format "powerline-%s-%s"
                                                         (powerline-current-separator)
                                                         (cdr powerline-default-separator-dir))))
                        (lhs (list
                              ;; Section 1: File status and whatnot
                              (powerline-raw (powerline-modified) face1 'l)
                              ;; (powerline-buffer-size mode-line 'l)
                              (powerline-raw mode-line-client face1 'l)
                              (powerline-raw "  " face1 'l)

                              ;; Section 2: ( Buffer Name ) ... bright
                              (funcall separator-right face1 mode-line)
                              (powerline-buffer-id mode-line-buffer-id 'l)
                              (powerline-raw " " mode-line)
                              (funcall separator-left mode-line face1)

                              ;; Section 3: Git ... dark
                              (powerline-narrow face1 'l)
                              (powerline-raw " " face1)
                              (powerline-raw (powerline-project-vc) face1 'l)
                              (powerline-vc face1 'l)))

                        (rhs (list (powerline-raw global-mode-string face1 'r)
                                   ;; Section 1: Language-specific ... optional
                                   (powerline-raw (powerline-lang-version) face1 'r)
                                   ;; Section 2: Function Name or Row Number
                                   (funcall separator-right mode-line eface)
                                        ;(powerline-raw (powerline-evil-state) eface 'r)
                                   (powerline-raw "%4l:%3c" eface 'r)))

                        (center (list (powerline-raw " " face1)
                                      (funcall separator-left face1 face2)
                                      (when (and (boundp 'erc-track-minor-mode) erc-track-minor-mode)
                                        (powerline-raw erc-modified-channels-object face2 'l))
                                      (powerline-major-mode face2 'l)
                                      (powerline-process face2)
                                      (powerline-raw " :" face2)
                                      (powerline-minor-modes face2 'l)
                                      (powerline-raw " " face2)
                                      (funcall separator-right face2 face1))))
                   (concat (powerline-render lhs)
                           (powerline-fill-center face1 (/ (powerline-width center) 2.0))
                           (powerline-render center)
                           (powerline-fill face1 (powerline-width rhs))
                           (powerline-render rhs))))))


;;config:
(powerline-center-theme)
(delight 'emacs-lisp-mode "eLisp" :major)

(provide 'init-wlpowerline )

;; wlpowerline ends here
