;;; coati.el --- Coati for Emacs                     -*- lexical-binding: t; -*-

;; Copyright (C) 2016

;; Author: Andreas Stallinger <astallinger@coati.io>
;; Keywords:
;; Version: 0.1

;; License:

;; This file is not part of GNU Emacs

;; The MIT License (MIT)
;; Copyright (c) 2016 Coati Software OG

;; Permission is hereby granted, free of charge, to any person obtaining
;; a copy of this software and associated documentation files (the "Software"),
;; to deal in the Software without restriction, including without limitation
;; the rights to use, copy, modify, merge, publish, distribute, sublicense,
;; and/or sell copies of the Software, and to permit persons to whom the
;; Software is furnished to do so, subject to the following conditions:

;; The above copyright notice and this permission notice shall be
;; included in all copies or substantial portions of the Software.

;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
;; EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
;; OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
;; IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
;; DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
;; TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
;; OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


;;; Commentary:

;emacs-coati
;===========

;emacs-coati is a plugin for Emacs to communicate with Coati_.

;.. _Coati: https://coati.io

;Install
;-------

;Usage
;-----

;From Coati to Emacs
;~~~~~~~~~~~~~~~~~~~

;* enable coati-mode in Emacs
;* Right click in coati -> **Set IDE Curor**
;* In the Emacs should now open the file and put the cursor in the position form coati.

;From Emacs to Coati
;~~~~~~~~~~~~~~~~~~~

;* Navigate your cursor to the location in the text.
;* Sent location to coati

  ;+ Press **M-x** and enter **coati-send-loation**
  ;+ bind **coati-send-location** to a key sequence and use it.

;Preferences
;-----------

;* **M-x** customize
;* search for coati
;* 3 Settins should be displayed now

;Emacs Coati Ip
;~~~~~~~~~~~~~~

;Ip address for the Tcp communcation, default is ``localhost``

;Emacs Coati Port Coati
;~~~~~~~~~~~~~~~~~~~~~~

;Port Coati listens to, default is ``6667``

;Emacs Coati Port Emacs
;~~~~~~~~~~~~~~~~~~~~~~

;Port Coati listens to, default is ``6666``


;;; Code:
(require 'subr-x)

(defgroup coati nil
  "Settings for the coati plugin"
  :group 'external)

(defcustom emacs-coati-port-coati 6667
  "Port Coati listens to"
  :group 'coati
  :type '(number))

(defcustom emacs-coati-port-emacs 6666
  "Port for listening to Coati"
  :group 'coati
  :type '(number))

(defcustom emacs-coati-ip "localhost"
  "Ip for communication with coati"
  :group 'coati
  :type '(string))

(defconst emacs-coati-server-name "coati-server")
(defvar emacs-coati-server nil)
(defvar emacs-coati-client nil)
(defvar emacs-coati-col nil)
(defvar emacs-coati-row nil)
(defvar emacs-coati-file nil)
(defvar coati-message nil)

(defun buildTokenLocationMessage ()
  "building a formated message for sending to coati"
  (setq emacs-coati-col (number-to-string (current-column)))
  (setq emacs-coati-row (number-to-string (line-number-at-pos)))
  (setq emacs-coati-file (buffer-file-name))
  (setq coati-message (mapconcat 'identity (list "setActiveToken" emacs-coati-file emacs-coati-row emacs-coati-col) ">>"))
  (setq coati-message (mapconcat 'identity (list coati-message "<EOM>") "")))

(defun emacs-coati-send-message(message)
  "sending message to coati"
  (setq emacs-coati-client
    (open-network-stream "coati-client"
			"*coati-client*" emacs-coati-ip emacs-coati-port-coati))
    (process-send-string emacs-coati-client message))

(defun coati-server-start ()
  (if (null emacs-coati-server)
	  (progn
		(add-hook 'kill-emacs-hook 'coati-server-stop)
		(setq emacs-coati-server
			  (make-network-process :name (or emacs-coati-server-name "*coati-server")
									:server t
									:service (or emacs-coati-port-emacs 6666)
									:family 'ipv4
									:sentinel 'emacs-coati-sentinel
									:filter 'emacs-coati-listen-filter)))))

(defun emacs-coati-sentinel (proc msg)
  (when (string= msg "connection broken by remote peer\n")
    (process-buffer proc)
	(coati-server-stop)))

(defun emacs-coati-listen-filter (proc string)
  (process-buffer proc)
  (if (string-suffix-p "<EOM>" string)
	  ;; split message
	  (progn
		(setq coati-message (split-string (string-remove-suffix "<EOM>" string) ">>"))
		(if (string= (car coati-message) "moveCursor")
			;;moveCuror message
			(progn
			  ;; filepath
			  (setq emacs-coati-file (nth 1 coati-message))
			  ;; row and col
			  (setq emacs-coati-row (string-to-number (nth 2 coati-message)))
			  (setq emacs-coati-col (string-to-number (nth 3 coati-message)))
			  ;; open file
			  (find-file emacs-coati-file)
			  ;; move cursor
			  (forward-line (- emacs-coati-row (line-number-at-pos)))
			  (move-to-column emacs-coati-col)
			)
		)
	)
	(message "%s" (concat "Could not process the message from coati" string))
	)
)

(defun coati-server-stop ()
  "Stops TCP Listener for Coati"
  (remove-hook 'kill-emacs-hook 'coati-server-stop)
  (if emacs-coati-server
	(progn
	  (delete-process emacs-coati-server-name)
	  (setq emacs-coati-server nil))))

;;;###autoload
(defun coati-send-location ()
  "Sends current location to Coati"
  (interactive)
  (emacs-coati-send-message (buildTokenLocationMessage))
)

;;;###autoload
(define-minor-mode coati-mode
  "Start/stop coati mode"
  :global t
  :lighter ""
  ; value of coati-mode is toggled before this implicitly
  (if coati-mode (coati-server-start) (coati-server-stop)))

(provide 'coati)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; coati.el ends here
