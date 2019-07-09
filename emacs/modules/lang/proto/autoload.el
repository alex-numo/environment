;;; lang/proto/autoload.el -*- lexical-binding: t; -*-
;;
;; Copyright (c) 2019 Boris Buliga
;;
;; Author: Boris Buliga <boris@d12frosted.io>
;; Maintainer: Boris Buliga <boris@d12frosted.io>
;;
;; Created: 02 Jul 2019
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

;;;###autoload
(defun +proto-working-directory (&optional arg)
  "Return working directory of the current proto file."
  (+file-locate-dominting-dir (buffer-file-name) "proto"))

;;;###autoload
(defun +proto--checker-predicate (&optional arg)
  "Return working directory of the current proto file."
  buffer-file-name)

;;;###autoload
(defun +proto--install-package (package &optional force)
  "Install PACKAGE.

Does nothing if the package already exists and FORCE is nil."
  (let* ((gopath (getenv "GOPATH"))
         (package-path (format "%s/src/%s" gopath package)))
    (unless (and (null force) (file-exists-p package-path))
      (shell-command (format "go get -u %s" package)))))

;;;###autoload
(defun +proto|install-dependencies ()
  "Install dependencies for writing proto files."
  (interactive)
  (message "Install missing dependencies...")
  (seq-do #'+proto--install-package
          '("github.com/grpc-ecosystem/grpc-gateway/protoc-gen-grpc-gateway"
            "github.com/grpc-ecosystem/grpc-gateway/protoc-gen-swagger"
            "github.com/golang/protobuf/protoc-gen-go"))
  (message "All dependencies are installed, have some proto fun!"))