;;;This init-org was copied from Howard Abrams dot-files.
;;;The literary programming was removed as didn't work with current files
;;;Code bellow

(use-package org
  :ensure t        ; But it comes with Emacs now!?
  :init
  (setq org-use-speed-commands t
        org-return-follows-link t
        org-hide-emphasis-markers t
        org-completion-use-ido t
        org-outline-path-complete-in-steps nil
        org-src-fontify-natively t   ;; Pretty code blocks
        org-src-tab-acts-natively t
        org-confirm-babel-evaluate nil
        org-todo-keywords '((sequence "TODO(t)" "DOING(g)" "|" "DONE(d)")
                            (sequence "|" "CANCELED(c)")))
  (add-to-list 'auto-mode-alist '("\\.txt\\'" . org-mode))
  (add-to-list 'auto-mode-alist '(".*/[0-9]*$" . org-mode))   ;; Journal entries
  (add-hook 'org-mode-hook 'yas-minor-mode-on)
  :bind (("C-c l" . org-store-link)
         ("C-c c" . org-capture)
         ("C-M-|" . indent-rigidly))
  :config (setq org-todo-keyword-faces
                '(("TODO" . org-warning) ("DOING" . "yellow") ("CANCELED" . (:background "red" :weight bold))))
  ;; (font-lock-add-keywords            ; A bit silly but my headers are now
  ;;  'org-mode `(("^\\*+ \\(TODO\\) "  ; shorter, and that is nice canceled
  ;;               (1 (progn (compose-region (match-beginning 1) (match-end 1) "⚑")
  ;;                         nil)))
  ;;              ("^\\*+ \\(DOING\\) "
  ;;               (1 (progn (compose-region (match-beginning 1) (match-end 1) "⚐")
  ;;                         nil)))
  ;;              ("^\\*+ \\(CANCELED\\) "
  ;;               (1 (progn (compose-region (match-beginning 1) (match-end 1) "✘")
  ;;                         nil)))
  ;;              ("^\\*+ \\(DONE\\) "
  ;;               (1 (progn (compose-region (match-beginning 1) (match-end 1) "✔")
  ;;                         nil)))))

  (define-key org-mode-map (kbd "M-C-n") 'org-end-of-item-list)
  (define-key org-mode-map (kbd "M-C-p") 'org-beginning-of-item-list)
  (define-key org-mode-map (kbd "M-C-u") 'outline-up-heading)
  (define-key org-mode-map (kbd "M-C-w") 'org-table-copy-region)
  (define-key org-mode-map (kbd "M-C-y") 'org-table-paste-rectangle)

  (define-key org-mode-map [remap org-return] (lambda () (interactive)
                                                (if (org-in-src-block-p)
                                                    (org-return)
                                                  (org-return-indent)))))

;;Packages from org-extras: org-drill and org-mime for html exports:

(use-package org-drill
  :ensure org-plus-contrib)

(use-package org-mime
  :ensure t)

;;;Inserts two lines, commented during testing

;; (defun ha/insert-two-spaces (N)
;;   "Inserts two spaces at the end of sentences."
;;   (interactive "p")
;;   (when (looking-back "[!?.] " 2)
;;     (insert " ")))

;; (advice-add 'org-self-insert-command :after #'ha/insert-two-spaces)

;;;Makes text easier to edit:

(defun org-text-bold () "Wraps the region with asterisks."
       (interactive)
       (surround-text "*"))
(defun org-text-italics () "Wraps the region with slashes."
       (interactive)
       (surround-text "/"))
(defun org-text-code () "Wraps the region with equal signs."
       (interactive)
       (surround-text "="))

;;;Associate keystrokes to org-mode

(use-package org
  :config
  (bind-keys :map org-mode-map
             ("A-b" . (surround-text-with "+"))
             ("s-b" . (surround-text-with "*"))
             ("A-i" . (surround-text-with "/"))
             ("s-i" . (surround-text-with "/"))
             ("A-=" . (surround-text-with "="))
             ("s-=" . (surround-text-with "="))
             ("A-`" . (surround-text-with "~"))
             ("s-`" . (surround-text-with "~"))

             ("C-s-f" . forward-sentence)
             ("C-s-b" . backward-sentence)))
;;; M-RET acts like RET in normal word

(defun ha/org-return (&optional ignore)
  "Add new list item, heading or table row with RET.
     A double return on an empty element deletes it.
     Use a prefix arg to get regular RET. "
  (interactive "P")
  (if ignore
      (org-return)
    (cond
     ;; Open links like usual
     ((eq 'link (car (org-element-context)))
      (org-return))
     ;; lists end with two blank lines, so we need to make sure we are also not
     ;; at the beginning of a line to avoid a loop where a new entry gets
     ;; created with only one blank line.
     ((and (org-in-item-p) (not (bolp)))
      (if (org-element-property :contents-begin (org-element-context))
          (org-insert-heading)
        (beginning-of-line)
        (setf (buffer-substring
               (line-beginning-position) (line-end-position)) "")
        (org-return)))
     ((org-at-heading-p)
      (if (not (string= "" (org-element-property :title (org-element-context))))
          (progn (org-end-of-meta-data)
                 (org-insert-heading))
        (beginning-of-line)
        (setf (buffer-substring
               (line-beginning-position) (line-end-position)) "")))
     ((org-at-table-p)
      (if (-any?
           (lambda (x) (not (string= "" x)))
           (nth
            (- (org-table-current-dline) 1)
            (org-table-to-lisp)))
          (org-return)
        ;; empty row
        (beginning-of-line)
        (setf (buffer-substring
               (line-beginning-position) (line-end-position)) "")
        (org-return)))
     (t
      (org-return)))))

(define-key org-mode-map (kbd "RET")  #'ha/org-return)

;;;Making bullets pretty

(use-package org-bullets
  :ensure t
  :init (add-hook 'org-mode-hook 'org-bullets-mode))

;;; Making * look pretty.  This might actually be for code block highlights.

(use-package org
  :init
  (font-lock-add-keywords 'org-mode
                          '(("^ +\\([-*]\\) "
                             (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•")))))))

;;; install pandoc to convert html to org format

(defun ha/paste-html-to-org ()
  "Assumes the contents of the system clip/paste-board to be
    HTML, this calls out to `pandoc' to convert it for the org-mode
    format."
  (interactive)
  (let* ((clip (if (eq system-type 'darwin)
                   "pbpaste -Prefer rts"
                 "xclip -out -selection 'clipboard' -t text/html"))
         (format (if (eq mode-name "Org") "org" "markdown"))
         (pandoc (concat "pandoc -f rts -t " format))
         (cmd    (concat clip " | " pandoc))
         (text   (shell-command-to-string cmd)))
    (kill-new text)
    (yank)))

;;;Journal mods

(use-package org-journal
  :ensure t
  :init
  (setq org-journal-dir "~/journal/")
  (setq org-journal-date-format "#+TITLE: Journal Entry- %e %b %Y (%A)")
  (setq org-journal-time-format ""))

;;; Time format heading for sections (modify later)

(defun get-journal-file-today ()
  "Return filename for today's journal entry."
  (let ((daily-name (format-time-string "%Y%m%d")))
    (expand-file-name (concat org-journal-dir daily-name))))

(defun journal-file-today ()
  "Create and load a journal file based on today's date."
  (interactive)
  (find-file (get-journal-file-today)))

(global-set-key (kbd "C-c f j") 'journal-file-today)

;;; Create forgotten journal entry (not very used)

(defun get-journal-file-yesterday ()
  "Return filename for yesterday's journal entry."
  (let* ((yesterday (time-subtract (current-time) (days-to-time 1)))
         (daily-name (format-time-string "%Y%m%d" yesterday)))
    (expand-file-name (concat org-journal-dir daily-name))))

(defun journal-file-yesterday ()
  "Creates and load a file based on yesterday's date."
  (interactive)
  (find-file (get-journal-file-yesterday)))

(global-set-key (kbd "C-c f y") 'journal-file-yesterday)

;;; Insert header on a empty journal
(defun journal-file-insert ()
  "Insert's the journal heading based on the file's name."
  (interactive)
  (let* ((year  (string-to-number (substring (buffer-name) 0 4)))
         (month (string-to-number (substring (buffer-name) 4 6)))
         (day   (string-to-number (substring (buffer-name) 6 8)))
         (datim (encode-time 0 0 0 day month year)))

    (insert (format-time-string org-journal-date-format datim))
    (insert "\n\n  $0\n") ; Start with a blank separating line

    ;; Note: The `insert-file-contents' leaves the cursor at the
    ;; beginning, so the easiest approach is to insert these files
    ;; in reverse order:

    ;; If the journal entry I'm creating matches today's date:
    (when (equal (file-name-base (buffer-file-name))
                 (format-time-string "%Y%m%d"))
      (insert-file-contents "journal-dailies-end.org")

      ;; Insert dailies that only happen once a week:
      (let ((weekday-template (downcase
                               (format-time-string "journal-%a.org"))))
        (when (file-exists-p weekday-template)
          (insert-file-contents weekday-template)))
      (insert-file-contents "journal-dailies.org")
      (insert "$0")

      (let ((contents (buffer-string)))
        (delete-region (point-min) (point-max))
        (yas-expand-snippet contents (point-min) (point-max))))))

(define-auto-insert "/[0-9]\\{8\\}$" [journal-file-insert])

;;; Usage:
;; To use this, make the following files:
;; - =journal-dailies.org= to contain the /real/ dailies
;; - =journal-dailies-end.org= to contain any follow-up notes
;; - =journal-mon.org= for additional text to be inserted on Monday journals
;; - And a =journal-XYZ.org= for each additional weekday

;;; This day one year ago

(defun journal-last-year-file ()
  "Returns the string corresponding to the journal entry that
    happened 'last year' at this same time (meaning on the same day
    of the week)."
  (let* ((last-year-seconds (- (float-time) (* 365 24 60 60)))
         (last-year (seconds-to-time last-year-seconds))
         (last-year-dow (nth 6 (decode-time last-year)))
         (this-year-dow (nth 6 (decode-time)))
         (difference (if (> this-year-dow last-year-dow)
                         (- this-year-dow last-year-dow)
                       (- last-year-dow this-year-dow)))
         (target-date-seconds (+ last-year-seconds (* difference 24 60 60)))
         (target-date (seconds-to-time target-date-seconds)))
    (format-time-string "%Y%m%d" target-date)))

(defun journal-last-year ()
  "Loads last year's journal entry, which is not necessary the
    same day of the month, but will be the same day of the week."
  (interactive)
  (let ((journal-file (concat org-journal-dir (journal-last-year-file))))
    (find-file journal-file)))

(global-set-key (kbd "C-c f L") 'journal-last-year)

;;;Calls meeting notes to remove distractions.  create heading first
;;;with the location for the notes.

(defun meeting-notes ()
  "Call this after creating an org-mode heading for where the notes for the meeting
     should be. After calling this function, call 'meeting-done' to reset the environment."
  (interactive)
  (outline-mark-subtree)                              ;; Select org-mode section
  (narrow-to-region (region-beginning) (region-end))  ;; Only show that region
  (deactivate-mark)
  (delete-other-windows)                              ;; Get rid of other windows
  (text-scale-set 2)                                  ;; Text is now readable by others
  (fringe-mode 0)
  (message "When finished taking your notes, run meeting-done."))

;;; undo feature when the meeting is over:

(defun meeting-done ()
  "Attempt to 'undo' the effects of taking meeting notes."
  (interactive)
  (widen)                                       ;; Opposite of narrow-to-region
  (text-scale-set 0)                            ;; Reset the font size increase
  (fringe-mode 1)
  (winner-undo))                                ;; Put the windows back in place

;;;==========================================================================
;;; org directories
;;;==========================================================================

;; (setq org-agenda-files '("~/Dropbox/org/personal"
;;                          "~/Dropbox/org/technical"
;;                          "~/Dropbox/org/project"))

;;; Defaults notes and tasks files (commented)

;; (defvar org-default-notes-file "~/personal/@SUMMARY.org")
;; (defvar org-default-tasks-file "~/personal/tasks.org")

;;; Note capturing templates:

(defun ha/first-header ()
  (goto-char (point-min))
  (search-forward-regexp "^\* ")
  (beginning-of-line 1)
  (point))

(setq org-capture-templates
      '(("n" "Thought or Note"  entry
         (file org-default-notes-file)
         "* %?\n\n  %i\n\n  See: %a" :empty-lines 1)
        ("j" "Journal Note"     entry
         (file (get-journal-file-today))
         "* %?\n\n  %i\n\n  From: %a" :empty-lines 1)
        ("t" "Task Entry"        entry
         (file+function org-default-tasks-file ha/load-org-tasks)
         "* %?\n\n  %i\n\n  From: %a" :empty-lines 1)
        ("w" "Website Announcement" entry
         (file+function "~/website/index.org" ha/first-header)
         "* %?
      :PROPERTIES:
      :PUBDATE: %t
      :END:
      ,#+HTML: <div class=\"date\">%<%e %b %Y></div>

      %i

      [[%F][Read more...]" :empty-lines 1)))

;;;for syncing with google tasks (commented)

;; pip install google-api-python-client python-gflags python-dateutil httplib2
;; pip install urllib3 apiclient discovery
;; pip install --upgrade oauth2client
;; hg clone https://bitbucket.org/edgimar/michel-orgmode

;;; sync doesn't work, so push and pull on save and open

;; (defun ha/load-org-tasks ()
;;   (interactive)
;;   (shell-command (format "/usr/local/bin/michel-orgmode --pull --orgfile %s" org-default-tasks-file))
;;   (find-file org-default-tasks-file)
;;   (ha/first-header)
;;   (add-hook 'after-save-hook 'ha/save-org-tasks t t))

;; (defun ha/save-org-tasks ()
;;   (save-buffer)
;;   (shell-command (format "/usr/local/bin/michel-orgmode --push --orgfile %s" org-default-tasks-file)))

;;;Org exports with cute defaults (by ha)

(use-package ox-html
  :init
  (setq org-html-postamble nil)
  (setq org-export-with-section-numbers nil)
  (setq org-export-with-toc nil)
  (setq org-html-head-extra "
          <link href='http://fonts.googleapis.com/css?family=Source+Sans+Pro:400,700,400italic,700italic&subset=latin,latin-ext' rel='stylesheet' type='text/css'>
          <link href='http://fonts.googleapis.com/css?family=Source+Code+Pro:400,700' rel='stylesheet' type='text/css'>
          <style type='text/css'>
             body {
                font-family: 'Source Sans Pro', sans-serif;
             }
             pre, code {
                font-family: 'Source Code Pro', monospace;
             }
          </style>"))

;;;Presentations

(use-package ox-reveal
  :init
  (setq org-reveal-root (concat "file://" (getenv "HOME") "/Public/js/reveal.js"))
  (setq org-reveal-postamble "ajcastany"))

;;;Tree Slide

(use-package org-tree-slide
  :ensure t
  :init
  (setq org-tree-slide-skip-outline-level 4)
  (org-tree-slide-simple-profile))

;;;Literate programing (babel project)
;;;Missing C and java
(use-package org
  :config
  (add-to-list 'org-src-lang-modes '("dot" . "graphviz-dot"))

  (org-babel-do-load-languages 'org-babel-load-languages
                               '((shell      . t)
                                 (js         . t)
                                 (emacs-lisp . t)
                                 (perl       . t)
                                 (scala      . t)
                                 (clojure    . t)
                                 (python     . t)
                                 (ruby       . t)
                                 (dot        . t)
                                 (css        . t)
                                 (plantuml   . t))))

;; get out of editing org mode source code blocks

(eval-after-load 'org-src
  '(define-key org-src-mode-map
     (kbd "C-x C-s") #'org-edit-src-exit))

;;; auto-evaluate code

(setq org-confirm-babel-evaluate nil)

;;;Font coloring in code blocks:
(setq org-src-fontify-natively t)
(setq org-src-tab-acts-natively t)

(provide 'init-org) ;;init-org ends here.
