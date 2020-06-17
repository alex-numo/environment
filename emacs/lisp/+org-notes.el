;;; +org-notes.el --- note taking helpers -*- lexical-binding: t; -*-
;;
;; Copyright (c) 2020 Boris Buliga
;;
;; Author: Boris Buliga <boris@d12frosted.io>
;; Maintainer: Boris Buliga <boris@d12frosted.io>
;;
;; Created: 03 Apr 2020
;;
;; URL:
;;
;; License: GPLv3
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;;; Code:

(require '+org-buffer-prop)
(require 'lib-list)
(require 's)

(defvar +org-notes-directory nil)

;; compiler
(defvar time-stamp-start)
(defvar org-roam-last-window)
(defvar org-roam-buffer)
(declare-function seq-contains-p "seq")
(declare-function deft "deft")
(declare-function deft-refresh "deft")
(declare-function org-read-date "org")
(declare-function org-back-to-heading "org")
(declare-function org-get-tags "org")
(declare-function org-set-tags "org")
(declare-function org-roam-find-file "org-roam")
(declare-function org-roam-insert "org-roam")
(declare-function org-roam-mode "org-roam")
(declare-function org-roam--extract-tags "org-roam")
(declare-function org-roam--extract-tags-prop "org-roam")
(declare-function org-roam-db-query "org-roam-db")
(declare-function org-roam-db-build-cache "org-roam-db")
(declare-function org-roam-db--clear "org-roam-db")
(declare-function org-roam-db--update-tags "org-roam-db")
(declare-function org-roam "org-roam-buffer")
(declare-function org-roam-buffer--visibility "org-roam-buffer")
(declare-function org-roam--current-visibility "org-roam-buffer")
(declare-function org-roam-dailies-today "org-roam-dailies")
(declare-function org-roam-dailies-date "org-roam-dailies")
(declare-function org-roam-dailies--file-for-time "org-roam-dailies")
(declare-function org-journal-new-entry "org-journal")

(defun +org-notes-list ()
  "Open a list of notes."
  (interactive)
  (deft)
  (deft-refresh))

(defun +org-notes-find ()
  "Find a note."
  (interactive)
  (org-roam-find-file))

(defun +org-notes-insert ()
  "Insert a link to the note."
  (interactive)
  (when-let*
      ((res (org-roam-insert))
       (path (plist-get res :path))
       (title (plist-get res :title))
       (roam-tags (+seq-flatten
                   (+seq-flatten
                    (org-roam-db-query [:select tags
                                        :from tags
                                        :where (= file $s1)]
                                       path)))))
    (when (seq-contains-p roam-tags "People")
      (save-excursion
        (ignore-errors
          (org-back-to-heading)
          (let ((tags (org-get-tags)))
            (org-set-tags (seq-uniq (cons (+org-notes--title-to-tag title) tags)))))))))

(defun +org-notes-new-journal-entry ()
  "Create new journal entry.

By default it uses current date to find a daily. With
\\[universal-argument] user may select the date."
  (interactive)
  (cond
   ((equal current-prefix-arg '(4))     ; select date
    (let* ((time (org-read-date nil 'to-time)))
      (org-roam-dailies--file-for-time time)
      (org-journal-new-entry nil time)))
   (t
    (org-roam-dailies-today)
    (org-journal-new-entry nil))))

(defun +org-notes-dailies-today ()
  "Find a daily note for today."
  (interactive)
  (org-roam-dailies-today))

(defun +org-notes-dailies-date ()
  "Find a daily note for date specified using calendar."
  (interactive)
  (org-roam-dailies-date))

(defun +org-notes-setup-buffer (&optional _)
  "Setup current buffer for notes viewing and editing.

If the current buffer is not a note, does nothing."
  (unless (active-minibuffer-window)
    (if (+org-notes-buffer-p)
        (progn
          (unless (bound-and-true-p org-roam-mode)
            (org-roam-mode 1))
          (setq-local time-stamp-start "#\\+TIME-STAMP:[ 	]+\\\\?[\"<]+")
          (setq org-roam-last-window (get-buffer-window))
          (unless (eq 'visible (org-roam-buffer--visibility))
            (delete-other-windows)
            (call-interactively #'org-roam))
          (+org-notes-ensure-filetag))
      (when (and (fboundp #'org-roam-buffer--visibility)
                 (eq 'visible (org-roam-buffer--visibility)))
        (delete-window (get-buffer-window org-roam-buffer))))))

(defun +org-notes-ensure-filetag ()
  "Add respective file tag if it's missing in the current note."
  (let ((tags (+org-notes-tags-read)))
    (when (and (seq-contains-p tags "People")
               (null (+org-buffer-prop-get "FILETAGS")))
      (+org-buffer-prop-set
       "FILETAGS"
       (+org-notes--title-as-tag)))))

(defun +org-notes-rebuild ()
  "Rebuild notes database."
  (interactive)
  (org-roam-db--clear)
  (org-roam-db-build-cache))

(defun +org-notes-tags-read ()
  "Return list of tags as set in the buffer."
  (unless (+org-notes-buffer-p)
    (user-error "Current buffer is not a note"))
  (org-roam--extract-tags-prop (buffer-file-name (buffer-base-buffer))))

(defun +org-notes-tags-add ()
  "Add a tag to current note."
  (interactive)
  (unless (+org-notes-buffer-p)
    (user-error "Current buffer is not a note"))
  (let* ((tags (seq-uniq
                (+seq-flatten
                 (+seq-flatten
                  (org-roam-db-query [:select tags :from tags])))))
         (tag (completing-read "Tag: " tags)))
    (when (string-empty-p tag)
      (user-error "Tag can't be empty"))
    (+org-buffer-prop-set
     "ROAM_TAGS"
     (combine-and-quote-strings (seq-uniq (cons tag (+org-notes-tags-read)))))
    (org-roam-db--update-tags)
    (+org-notes-ensure-filetag)))

(defun +org-notes-tags-delete ()
  "Delete a tag from current note."
  (interactive)
  (unless (+org-notes-buffer-p)
    (user-error "Current buffer is not a note"))
  (let* ((tags (+org-notes-tags-read))
         (tag (completing-read "Tag: " tags nil 'require-match)))
    (+org-buffer-prop-set
     "ROAM_TAGS"
     (combine-and-quote-strings (delete tag tags)))
    (org-roam-db--update-tags)))

(defun +org-notes-buffer-p ()
  "Return non-nil if the currently visited buffer is a note."
  (and buffer-file-name
       (string-equal (file-name-as-directory +org-notes-directory)
                     (file-name-directory buffer-file-name))))

(defun +org-notes--title-as-tag ()
  "Return title of the current note as tag."
  (+org-notes--title-to-tag (+org-buffer-prop-get "TITLE")))

(defun +org-notes--title-to-tag (title)
  "Convert TITLE to tag."
  (concat "@" (s-replace " " "" title)))

(provide '+org-notes)
;;; +org-notes.el ends here
