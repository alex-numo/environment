;;; init.el -*- lexical-binding: t; -*-

(defconst +path-home-dir (file-name-as-directory (getenv "HOME"))
  "Path to user home directory.

In a nutshell, it's just a value of $HOME.")

(defconst +sys-name (system-name)
  "Name of the system (e.g. hostname).")

(doom! :completion
       company
       ivy

       :core
       windows
       navigation

       :ui
       chisinau
       deft
       doom
       hl-todo
       modeline
       (popup +defaults)
       vc-gutter
       ;; workspaces

       :editor
       file-templates
       fold
       (format +onsave)
       lispy
       multiple-cursors
       ;; rotate-text
       snippets

       :emacs
       dired
       electric
       (undo +tree)
       vc

       :checkers
       syntax
       spell
       grammar

       :tools
       debugger
       docker
       (eval +overlay)
       lookup
       lsp
       (magit +forge)
       make
       ;;pass
       pdf
       rgb

       :lang
       emacs-lisp
       (haskell +lsp +ghcide)
       json
       latex
       ledger
       markdown
       (org +brain
            +journal
            +dragndrop
            +gnuplot
            +roam)
       vulpea
       plantuml
       rest
       scala
       sh
       yaml

       :config
       (default +emacs +smartparens))