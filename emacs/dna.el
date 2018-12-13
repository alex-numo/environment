;;; dna.el -*- lexical-binding: t; -*-
;;
;; Copyright (c) 2018 Boris Buliga
;;
;; Author: Boris Buliga <boris@d12frosted.io>
;; Maintainer: Boris Buliga <boris@d12frosted.io>
;;
;; Created: 20 Nov 2018
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

(nucleus!
 :feature
 eval
 file-templates
 projects
 snippets
 spellcheck
 syntax-checker
 workspaces

 :completion
 (company
  +auto)
 ivy

 :ui
 helpful
 modeline
 modern
 theming
 vc-gutter

 :editor
 default
 navigation
 octocursors
 whitespaces

 :emacs
 buffer
 dired
 ediff
 file
 string
 window

 :tools
 git

 :lang
 emacs-lisp
 (haskell +intero)
 org
 plantuml
 rest
 sh

 :app

 :collab

 :config
 keybindings
 os)
