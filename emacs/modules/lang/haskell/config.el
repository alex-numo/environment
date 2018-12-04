;;; lang/haskell/config.el -*- lexical-binding: t; -*-
;;
;; Copyright (c) 2018 Boris Buliga
;;
;; Author: Boris Buliga <boris@d12frosted.io>
;; Maintainer: Boris Buliga <boris@d12frosted.io>
;;
;; Created: 04 Dec 2018
;;
;; URL: https://github.com/d12frosted/environment/emacs
;;
;; License: GPLv3
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;;; Code:

(when (featurep! +intero)
  (load! "+intero"))

(after! haskell-mode
  (setq haskell-process-suggest-remove-import-lines t  ; warnings for redundant imports etc
        haskell-process-auto-import-loaded-modules t)
  (when (featurep! :feature syntax-checker)
    (setq haskell-process-show-overlays nil))  ; flycheck makes this unnecessary
  (add-hook! 'haskell-mode-hook
    #'(subword-mode           ; improves text navigation with camelCase
       haskell-collapse-mode  ; support folding haskell code blocks
       interactive-haskell-mode))
  ;; TODO Lookup/jumpers
  ;; (set-lookup-handlers! 'haskell-mode :definition #'haskell-mode-jump-to-def-or-tag)
  (set-file-template! 'haskell-mode :trigger #'haskell-auto-insert-module-template :project t)

  ;; TODO REPL
  ;; (set-repl-handler! '(haskell-mode haskell-cabal-mode literate-haskell-mode) #'+haskell-repl-buffer)

  (add-to-list 'completion-ignored-extensions ".hi")
  (setq-hook! 'haskell-mode-hook +modeline-indent-width haskell-indentation-left-offset)

  (map! :map haskell-mode-map
        :localleader
        ;; this is set to use cabal for dante users and stack for intero users:
        "b" #'haskell-process-cabal-build
        "c" #'haskell-cabal-visit-file
        "h" #'haskell-hide-toggle
        "H" #'haskell-hide-toggle-all))