;;; config.el --- d12frosted-core layer config file for Spacemacs.
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

;; TODO: move me to d12frosted-org
(defvar d12-org/files-list
  '()
  "List of interesting org files.")

;; setup load path
(add-to-load-path (concat d12-path/emacs-layers "d12frosted-core/"))

;; require all modules
(require 'd12-files)
(require 'd12-helm)
(require 'd12-dir-settings)

;; load `private.el' file containing all sensitive data
(load (concat d12-path/emacs-private "private.el"))

;;; Auto modes

(add-to-list 'auto-mode-alist '("SConstruct" . python-mode))
(add-to-list 'auto-mode-alist '("SConscript" . python-mode))

;;; Hooks

(add-hook 'find-file-hook 'd12-dir-settings/load)
(add-hook 'company-mode-hook 'company-quickhelp-mode)
(add-hook 'prog-mode-hook 'vimish-fold-mode)
(add-hook 'haskell-interactive-mode-hook 'd12//init-haskell-interactive-mode)
(add-hook 'text-mode-hook 'visual-line-mode)
(add-hook 'after-save-hook 'delete-trailing-whitespace)

;;; Configs

(setq-default
 ;; Miscellaneous
 vc-follow-symlinks t
 require-final-newline t

 ;; Whitespace mode
 whitespace-style '(face tabs tab-mark)
 whitespace-display-mappings
 '((newline-mark 10 [172 10])
   (tab-mark 9 [9655 9]))

 ;; Shell
 sh-basic-offset 2
 sh-indentation 2)

(delete-selection-mode 1)

;; setup scrolling
(setq scroll-margin 0                   ; Drag the point along while scrolling
      scroll-conservatively 1000        ; Never recenter the screen while scrolling
      scroll-error-top-bottom t         ; Move to beg/end of buffer before
                                        ; signalling an error
      ;; These settings make trackpad scrolling on OS X much more predictable
      ;; and smooth
      mouse-wheel-progressive-speed nil
      mouse-wheel-scroll-amount '(1))

;; OS X
(if (spacemacs/system-is-mac)
    (setq mac-command-modifier 'meta
          mac-option-modifier  'none))

;; python
(defun pyenv-mode-versions ()
  "List installed python versions."
  (let ((versions (shell-command-to-string "vf ls")))
    (delete-dups (cons "system" (split-string versions)))))

;;; config.el ends here
