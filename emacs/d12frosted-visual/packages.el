;;; packages.el --- d12frosted-visual layer packages file for Spacemacs.
;;
;; Copyright (c) 2012-2016 Sylvain Benner & Contributors
;;
;; Author: Boris Buliga <d12frosted@d12frosted.local>
;; URL: https://github.com/syl20bnr/spacemacs
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

;;; Commentary:

;;; Code:

(defconst d12frosted-visual-packages
  '(
    beacon
    spaceline
    (d12-pretty-greek :location local)
    all-the-icons))

(defun d12frosted-visual/init-beacon ()
  (use-package beacon
    :init
    (beacon-mode 1)))

(defun d12frosted-visual/post-init-spaceline ()
  (use-package spaceline-config
    :init
    (setq powerline-default-separator 'utf-8)
    :config
    (require 'cl)
    (defvar d12-state-cursors '((emacs "SkyBlue2" box)
                                (emacs-input "chartreuse3" box)
                                (god "DarkGoldenrod2" box)
                                (god-input "plum3" box))
          "Colors assigned to several states with cursor definitions.")

    (cl-loop for (state color cursor) in d12-state-cursors
             do
             (eval `(defface ,(intern (format "d12-spaceline-%S-face" state))
                      `((t (:background ,color
                                        :foreground ,(face-background 'mode-line)
                                        :box ,(face-attribute 'mode-line :box)
                                        :inherit 'mode-line)))
                      (format "%s state face." state)
                      :group 'd12frosted))
             (set (intern (format "d12-%s-state-cursor" state))
                  (list (when dotspacemacs-colorize-cursor-according-to-state color)
                        cursor)))

    (defun d12//get-state ()
      (cond
       ((and (bound-and-true-p current-input-method) (bound-and-true-p god-local-mode)) 'god-input)
       ((bound-and-true-p current-input-method) 'emacs-input)
       ((bound-and-true-p god-local-mode) 'god)
       (t 'emacs)))
    (defun d12//get-state-face ()
      (let ((state (d12//get-state)))
        (intern (format "d12-spaceline-%S-face" state))))
    (setq spaceline-highlight-face-func 'd12//get-state-face)
    (spaceline-toggle-org-clock-on)

    (spaceline-define-segment major-mode
      "The name of the major mode."
      (let ((icon (all-the-icons-icon-for-buffer)))
        (condition-case nil
            (setq icon (all-the-icons-fileicon (file-name-extension (buffer-file-name (current-buffer)))))
          (error nil))
        (unless (symbolp icon) ;; This implies it's the major mode
          (format
           "%s"
           (propertize
            icon
            'help-echo (format "Major-mode: `%s`" major-mode)
            'display '(raise -0.1)
            'face `(
                    :height 1.2
                    :family ,(all-the-icons-icon-family-for-buffer)
                    :background ,(if (powerline-selected-window-active)
                                     (face-background 'powerline-active1)
                                   (face-background 'powerline-inactive1))
                    ))))))))

(defun d12frosted-visual/init-d12-pretty-greek ()
  (use-package d12-pretty-greek
    :init
    (add-hook 'prog-mode-hook #'d12-pretty-greek)))

(defun d12frosted-visual/init-all-the-icons ()
  (use-package all-the-icons))

;;; packages.el ends here
