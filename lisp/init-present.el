;;;This is basic config file for org-present

(require-package 'org-present)

(add-hook 'org-present-mode-hook
          (lambda ()
            (org-present-big)
            (org-display-inline-images)
            (org-present-hide-cursor)
            (org-present-read-only)))
(add-hook 'org-present-mode-quit-hook
          (lambda ()
            (org-present-small)
            (org-remove-inline-images)
            (org-present-show-cursor)
            (org-present-read-write)))

;;;===========================================================================================
;;;                                     Configuration:
;;;==========================================================================================

(defvar org-present-mode-keymap (make-keymap) "org-present-mode keymap.")

;; left and right page keys
(define-key org-present-mode-keymap [right]         'org-present-next)
(define-key org-present-mode-keymap [left]          'org-present-prev)
(define-key org-present-mode-keymap (kbd "C-c C-=") 'org-present-big)
(define-key org-present-mode-keymap (kbd "C-c C--") 'org-present-small)
(define-key org-present-mode-keymap (kbd "C-c C-q") 'org-present-quit)
(define-key org-present-mode-keymap (kbd "C-c C-r") 'org-present-read-only)
(define-key org-present-mode-keymap (kbd "C-c C-w") 'org-present-read-write)
(define-key org-present-mode-keymap (kbd "C-c <")   'org-present-beginning)
(define-key org-present-mode-keymap (kbd "C-c >")   'org-present-end)

;; how much to scale up font size
(defvar org-present-text-scale 5)
(defvar org-present-cursor-cache (or cursor-type nil)
  "Holds the user set value of cursor for `org-present-read-only'")
(defvar org-present-overlays-list nil)

(define-minor-mode org-present-mode
  "Minimalist presentation minor mode for org-mode."
  :init-value nil
  :lighter " OP"
  :keymap org-present-mode-keymap)

(make-variable-buffer-local 'org-present-mode)

(defun org-present-top ()
  "Jump to current top-level heading, should be safe outside a heading."
  (unless (org-at-heading-p) (outline-previous-heading))
  (let ((level (org-current-level)))
    (when (and level (> level 1))
      (outline-up-heading (- level 1) t))))

(defun org-present-next ()
  "Jump to next top-level heading."
  (interactive)
  (widen)
  (if (org-current-level) ;inside any heading
      (progn
        (org-present-top)
        (or
         (org-get-next-sibling) ;next top-level heading
         (org-present-top)))    ;if that was last, go back to top before narrow
    ;; else handle title page before first heading
    (outline-next-heading))
  (org-present-narrow)
  (org-present-run-after-navigate-functions))

(defun org-present-prev ()
  "Jump to previous top-level heading."
  (interactive)
  (if (org-current-level)
      (progn
        (widen)
        (org-present-top)
        (org-get-last-sibling)))
  (org-present-narrow)
  (org-present-run-after-navigate-functions))

(defun org-present-narrow ()
  "Show just current page; in a heading we narrow, else show title page (before first heading)."
  (if (org-current-level)
      (progn
        (org-narrow-to-subtree)
        (show-all))
    ;; else narrow to area before first heading
    (outline-next-heading)
    (narrow-to-region (point-min) (point))
    (goto-char (point-min))))

(defun org-present-beginning ()
  "Jump to first slide of presentation."
  (interactive)
  (widen)
  (beginning-of-buffer)
  (org-present-narrow)
  (org-present-run-after-navigate-functions))

(defun org-present-end ()
  "Jump to last slide of presentation."
  (interactive)
  (widen)
  (end-of-buffer)
  (org-present-top)
  (org-present-narrow)
  (org-present-run-after-navigate-functions))

(defun org-present-big ()
  "Make font size larger."
  (interactive)
  (text-scale-increase 0)
  (text-scale-increase org-present-text-scale)) ;MAKE THIS BUFFER-LOCAL

(defun org-present-small ()
  "Change font size back to original."
  (interactive)
  (text-scale-increase 0))

(defun org-present-add-overlay (beginning end)
  "Create a single overlay over given region and remember it."
  (let ((overlay (make-overlay beginning end)))
    (push overlay org-present-overlays-list)
    (overlay-put overlay 'invisible 'org-present)))

(defun org-present-show-option (string)
  "Returns non-nil if string is an org-mode exporter option whose value we want to show."
  (save-match-data
    (string-match
     (regexp-opt '("title:" "author:" "date:" "email:"))
     string)))

(defun org-present-add-overlays ()
  "Add overlays for this mode."
  (add-to-invisibility-spec '(org-present))
  (save-excursion
    ;; hide org-mode options starting with #+
    (goto-char (point-min))
    (while (re-search-forward "^[[:space:]]*\\(#\\+\\)\\([^[:space:]]+\\).*" nil t)
      (let ((end (if (org-present-show-option (match-string 2)) 2 0)))
        (org-present-add-overlay (match-beginning 1) (match-end end))))
    ;; hide stars in headings
    (goto-char (point-min))
    (while (re-search-forward "^\\(*+\\)" nil t)
      (org-present-add-overlay (match-beginning 1) (match-end 1)))
    ;; hide emphasis markers
    (goto-char (point-min))
    (while (re-search-forward org-emph-re nil t)
      (org-present-add-overlay (match-beginning 2) (1+ (match-beginning 2)))
      (org-present-add-overlay (1- (match-end 2)) (match-end 2)))))

(defun org-present-rm-overlays ()
  "Remove overlays for this mode."
  (mapc 'delete-overlay org-present-overlays-list)
  (remove-from-invisibility-spec '(org-present)))

(defun org-present-read-only ()
  "Make buffer read-only."
  (interactive)
  (setq buffer-read-only t)
  (setq org-present-cursor-cache cursor-type
        cursor-type nil)
  (define-key org-present-mode-keymap (kbd "SPC") 'org-present-next))

(defun org-present-read-write ()
  "Make buffer read-only."
  (interactive)
  (setq buffer-read-only nil)
  (setq cursor-type org-present-cursor-cache)
  (define-key org-present-mode-keymap (kbd "SPC") 'self-insert-command))

(defun org-present-hide-cursor ()
  "Hide the cursor for current window."
  (interactive)
  (internal-show-cursor (selected-window) nil))

(defun org-present-show-cursor ()
  "Show the cursor for current window."
  (interactive)
  (internal-show-cursor (selected-window) t))

;;;###autoload
(defun org-present ()
  "init."
  (interactive)
  (setq org-present-mode t)
  (org-present-add-overlays)
  (org-present-narrow)
  (run-hooks 'org-present-mode-hook)
  (org-present-run-after-navigate-functions))

(defun org-present-quit ()
  "Quit the minor-mode."
  (interactive)
  (org-present-small)
  (org-present-rm-overlays)
  (widen)
  ;; Exit from read-only mode before exiting the minor mode
  (when buffer-read-only
    (org-present-read-write))
  (run-hooks 'org-present-mode-quit-hook)
  (setq org-present-mode nil))

(defvar org-present-after-navigate-functions nil
  "Abnormal hook run after org-present navigates to a new heading.")

;; courtesy Xah Lee ( http://ergoemacs.org/emacs/modernization_elisp_lib_problem.html )
(defun org-present-trim-string (string)
  "Remove whitespace (space, tab, emacs newline (LF, ASCII 10)) in beginning and ending of STRING."
  (replace-regexp-in-string
   "\\`[ \t\n]*" ""
   (replace-regexp-in-string "[ \t\n]*\\'" "" string)))

(defun org-present-run-after-navigate-functions ()
  "Run org-present-after-navigate hook, passing the name of the presentation buffer and the current heading."
  (let* ((title-text (thing-at-point 'line))
         (safe-title-text (replace-regexp-in-string "^[ \*]" "" title-text))
         (current-heading (org-present-trim-string safe-title-text)))
    (run-hook-with-args 'org-present-after-navigate-functions (buffer-name) current-heading)))

(provide 'init-present)

;;;File ends here
