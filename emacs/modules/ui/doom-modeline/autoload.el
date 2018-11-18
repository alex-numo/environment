;;; ui/nucleus-modeline/autoload.el -*- lexical-binding: t; -*-

(defvar +nucleus-modeline--old-bar-height nil)
;;;###autoload
(defun +nucleus-modeline|resize-for-big-font ()
  "Adjust the modeline's height when `nucleus-big-font-mode' is enabled. This was
made to be added to `nucleus-big-font-mode-hook'."
  (unless +nucleus-modeline--old-bar-height
    (setq +nucleus-modeline--old-bar-height +nucleus-modeline-height))
  (let ((default-height +nucleus-modeline--old-bar-height))
    (if nucleus-big-font-mode
        (let* ((font-size (font-get nucleus-font :size))
               (big-size (font-get nucleus-big-font :size))
               (ratio (/ (float big-size) font-size)))
          (setq +nucleus-modeline-height (ceiling (* default-height ratio 0.75))))
      (setq +nucleus-modeline-height default-height))
    ;; already has a variable watcher in Emacs 26+
    (unless EMACS26+ (+nucleus-modeline|refresh-bars))))
