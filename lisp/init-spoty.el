;;Some customs keybinds for spotify
;;; Code:

;;;I want to be notififed :)
;;(spotify-enable-song-notifications)
(add hook 'spotify-enable-song-notifications)
(global-set-key (kbd "C-c n") 'spotify-next)
(global-set-key (kbd "C-c p") 'spotify-previous)
(global-set-key (kbd "C-c s") 'spotify-current)

(provide 'init-spoty)
;;;init-spoty ends here
