;;This is a test of the initialization file that I will use for the MSc in Computing at Cardiff University
;;This should have support for python, java, linux shell and org-mode.
;;This file was made by Armando Castany.
;;Inspired by purcell and Howard Abrams init files.

(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory)) ;;Add more configurations
(require 'init-benchmarking) ;; Measure startup time.  Without this sessions wont work
;;Maybe remove sanity/ from sessions.el, find another init for dekstop/winner mode

(defconst *is-a-mac* (eq system-type 'darwin))
(defconst *spell-check-support-enabled* t) ;;I like to have spell check

;;----------------------------------------------------------------------------
;; Adjust garbage collection thresholds during startup, and thereafter
;;----------------------------------------------------------------------------
;;(let ((normal-gc-cons-threshold (* 20 1024 1024))
;;    (init-gc-cons-threshold (* 128 1024 1024)))
;;(setq gc-cons-threshold init-gc-cons-threshold)
;;(add-hook 'after-init-hook
;;          (lambda () (setq gc-cons-threshold normal-gc-cons-threshold))))

(setq gc-cons-threshold 50000000)
(setq gnutls-min-prime-bits 4096) ;;something about errors using https

;;----------------------------------------------------------------------------
;; Bootstrap config
;;----------------------------------------------------------------------------
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(require 'init-utils)
(require 'init-site-lisp) ;; sitelisp is empty
;; Calls (package-initialize)
(require 'init-elpa)      ;; Machinery for installing required packages
(require 'init-exec-path) ;; Set up $PATH


;;----------------------------------------------------------------------------
;; Allow users to provide an optional "init-preload-local.el"
;;----------------------------------------------------------------------------
(require 'init-preload-local nil t)

;;----------------------------------------------------------------------------
;; Load configs for specific features and modes
;;----------------------------------------------------------------------------

(require-package 'wgrep)
(require-package 'diminish)
(require-package 'scratch)
(require-package 'command-log-mode)
(require-package 'use-package)         ;without this, ha-packages won't work at allXS

;;; Testing HA powerline
;;(require 'init-hapowerline)
;;; Stable:
(require 'init-frame-hooks)
(require 'init-xterm)                   ;mainly to use the mouse in shell
(require 'init-themes)                  ;sanity themes
(require 'init-osx-keys)                ;For mac users
(require 'init-gui-frames)              ;cool opacity stuff
(require 'init-dired)
(require 'init-isearch)
(require 'init-grep)                    ;No idea what's AG package
(require 'init-uniquify)
(require 'init-ibuffer)
(require 'init-flycheck)

(require 'init-recentf)
(require 'init-smex)
(require 'init-ivy)
;;(require 'init-helm) ;We use Ivy now
(require 'init-hippie-expand)
(require 'init-company)
(require 'init-windows)                 ;super awesome window dedication mode.
(require 'init-sessions)
(require 'init-fonts)
(require 'init-mmm)

(require 'init-editing-utils)
(require 'init-whitespace)

(require 'init-vc)
(require 'init-darcs)
(require 'init-git)
(require 'init-github)
(require 'init-pyenv)             ;This is a ha-package
(require 'init-csv)
(require 'init-projectile)

(require 'init-compile)
;;(require 'init-python)
(require 'init-hapython)


(require 'init-paredit)
(require 'init-lisp)
(require 'init-spelling)
(require 'init-misc)


(require 'init-ob-scala)
(require 'init-ledger)
(require 'init-org)
(require 'init-present)
(require 'init-haskell)
;;TESTING powelrine
;; (require 'init-wlpowerline)
;;; Web modes:
;;testing CSS mode
(require 'init-css)
;; (require 'init-html)                    ;Tag edit minor mode.
(require 'init-markdown)
(require 'init-nxml)
(require 'init-js2-mod)
;;(require 'init-modeline) Very broken
;; (require 'init-eclim)                   ;fix!
;;(require 'init-spoty.el)
                                        ;(require 'init-newpowerline )
;; ;; Extra packages which don't require any configuration

(require-package 'gnuplot)
(require-package 'lua-mode)
(require-package 'htmlize)
(require-package 'dsvn)
(require-package 'ob-async)
(when *is-a-mac*
  (require-package 'osx-location))
(unless (eq system-type 'windows-nt)
  (maybe-require-package 'daemons))
(maybe-require-package 'dotenv-mode)

(when (maybe-require-package 'uptimes)
  (setq-default uptimes-keep-count 200)
  (add-hook 'after-init-hook (lambda () (require 'uptimes))))

;;----------------------------------------------------------------------------
;; Allow access from emacsclient
;;----------------------------------------------------------------------------
(require 'server)
(unless (server-running-p)
  (server-start))

;;----------------------------------------------------------------------------
;; Variables configured via the interactive 'customize' interface
;;----------------------------------------------------------------------------
(when (file-exists-p custom-file)
  (load custom-file))


;;----------------------------------------------------------------------------
;; Locales (setting them earlier in this file doesn't work in X)
;;----------------------------------------------------------------------------
(require 'init-locales)


;;----------------------------------------------------------------------------
;; Allow users to provide an optional "init-local" containing personal settings
;;----------------------------------------------------------------------------
(require 'init-local nil t)

;;----------------------------------------------------------------------------
;; More easy templates org-structure-template-alist!
;;----------------------------------------------------------------------------

(require 'init-templates )

;; This should be on it's own file...

(winner-mode 1)
(global-visual-line-mode 1)
(blink-cursor-mode 0)
(setq backup-directory-alist '(("" . "~/.emacs.d/emacs-backup"))) ;;driving me insane

;;provide init.el
(provide 'init)

;; Local Variables:
;; coding: utf-8
;; no-byte-compile: t
;; End:
