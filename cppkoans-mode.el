;;; cppkoans-mode.el --- a minor-mode for editing cppkoans C++ files
;;
;; Copyright 2014 Florian Kaufmann <sensorflo@gmail.com>
;;
;; Author: Florian Kaufmann <sensorflo@gmail.com>
;; URL: https://github.com/sensorflo/cppkoans-mode
;; Created: 2014
;; 
;; This file is not part of GNU Emacs.
;; 
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth
;; Floor, Boston, MA 02110-1301, USA.
;; 
;; 
;;; Commentary:
;; 
;; cppkoans, see https://github.com/sensorflo/cppkoans, are a set of little
;; exercises to improve and strengthen your knowledge of C++. The exercises are
;; in the form of regular code, which is to be edited in place. cppkoans-mode
;; provides small support to edit such files.
;;
;;
;; Installation
;; ------------
;; 
;; 1. Copy the file cppkoans-mode.el to a directory in your load-path, e.g.
;;    ~/.emacs.d.
;; 
;; 2. Add either of the two following lines to your initialization file. The
;;    first only loads cppkoans mode when necessary, the 2nd always during
;;    startup of Emacs.
;; 
;;    * (autoload 'cppkoans-mode "cppkoans-mode")
;;      (autoload 'cppkoans-koans-buffer-p "cppkoans-mode")
;; 
;;    * (require 'cppkoans-mode)
;; 
;; 3.1 To use cppkoans-mode, manually call cppkoans-mode after you opened an C++
;;     file containing cppkoans: `M-x cppkoans-mode`
;; 
;; 3.2 To automatically get cppkoans-mode enabled, put the following in your
;;     initialization file (probably ~/.emacs):
;; 
;;     (add-hook 'find-file-hook
;;       (lambda() (if (cppkoans-koans-buffer-p) (cppkoans-mode))))
;; 
;; 
;; Todo
;; ----
;; - TC++PL / TStd / koans internal links / ... etc -> links to external
;;   documents
;; - mode-alist or so for minor modes?
;; 
;;; Code:
(defgroup cppkoans nil "See (finder-commentary \"cppkoans-mode\")")

(defface cppkoans-edit-field-face
  '((t :box (:line-width 1 :style pressed-button)))
  "Place where disciple has to write his answer to the koan."
  :group 'cppkoans)

(defvar cppkoans-edit-field-face 'cppkoans-edit-field-face)

(defconst cppkoans-re-edit-field
  "\\b\\(?:EXPECT\\|ASSERT\\)_[A-Z_0-9]+\\s-*(.*?\\(__+\\)")

(defconst cppkoans-font-lock-keywords
  (list
   (list "^\\s-*TEST\\s-*([^,]*,[ \t\n]*\\([a-zA-Z0-9_]+\\)" '(1 font-lock-function-name-face t))
   (list cppkoans-re-edit-field '(1 cppkoans-edit-field-face t))))

(defun cppkoans-forward-edit-field (&optional arg)
  "Move point forward ARG edit fields.
An edit field is an all underscore identifier which has to be
replaced by the disciple with his answer to the koan. With
negative argument, move backward."
  (interactive "p")
  (let ((re-search (if (> arg 0) 're-search-forward 're-search-backward)))
    (while (/= arg 0)
      (if (funcall re-search cppkoans-re-edit-field nil t)
          (goto-char (match-beginning 1))
        (error "No more edit fields"))
      (setq arg (+ arg (if (> arg 0) -1 1))))))

(defun cppkoans-backward-edit-field (&optional arg)
  "Move point backward ARG edit fields.
Analogous to `cppkoans-forward-edit-field'."
  (interactive "p")
  (cppkoans-forward-edit-field (- arg)))

;;;###autoload
(defun cppkoans-koans-buffer-p ()
  "Return t if current buffer is part of koans of cppkoans, nil otherwise.
It does so using an heuristic."
  (interactive)
  (and
   (member (file-name-nondirectory (directory-file-name (file-name-directory buffer-file-name)))
           '("koans" "library"))
   (string= (file-name-extension buffer-file-name) "cpp")
   (save-excursion
     (save-restriction
       (widen)
       (goto-char (point-min))
       (re-search-forward "^\\s-*TEST\\s-*(\\s-*" nil t)))))

;;;###autoload
(define-minor-mode cppkoans-mode
  "See (finder-commentary \"cppkoans-mode\")"
  :lighter " cppkoans"
  (font-lock-add-keywords nil cppkoans-font-lock-keywords t))

(provide 'cppkoans-mode)

;;; cppkoans-mode.el ends here
