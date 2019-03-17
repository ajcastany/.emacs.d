;;This package will start emacs-eclipse client/server

(require 'eclim)
(setq eclimd-autostart t)

(defun my-java-mode-hook ()
  (eclim-mode t))

(add-hook 'java-mode-hook 'my-java-mode-hook)

;;My eclipse installation is on $home, so...

(custom-set-variables
 '(eclim-eclipse-dirs '("/home/wolfeius/eclipse/java-photon/eclipse"))
 '(eclim-executable "/home/wolfeius/.p2/pool/plugins/org.eclim_2.8.0/bin/eclim")) ;;in the guide says eclim, but i cannot find the eclim? just the daemon/

;;Displaying compilation errors in echo area same as (display-local-help).  commented for testing.

(setq help-at-pt-display-when-idle t)
(setq help-at-pt-timer-delay 0.1)
(help-at-pt-set-timer)

;;Configuring auto-complete

;; regular auto-complete initialization
(require 'auto-complete-config)
(ac-config-default)

;;add the emacs-eclim source

(require 'ac-emacs-eclim)
(ac-emacs-eclim-config)

;;Configuring Company-mode

(require 'company)
(require 'company-emacs-eclim)
(company-emacs-eclim-setup)
(global-company-mode t)

;;this is for gradle

(require 'gradle-mode)
(add-hook 'java-mode-hook '(lambda() (gradle-mode 1)) )

(provide 'init-eclim)

;;;init-eclim ends here
