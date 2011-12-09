
(setq-default indent-tabs-mode nil);

(setq-default iswitchb-mode t);
(setq-default python-remove-cwd-from-path nil)
(setq-default set-mark-command-repeat-pop t)
(setq-default x-select-enable-clipboard t)
(setq-default mark-ring-max 5)

(setq inhibit-startup-message t) ;will inhibit startup messages.
(setq require-final-newline t) ;will make the last line end in a carriage return. 

(global-auto-revert-mode t)
; change yes or no prompt to y or n
(fset 'yes-or-no-p 'y-or-n-p)

;(load "~/.emacs.d/project-local-variables.el")
;(load "~/.emacs.d/find-file-in-project.el")

;(load "~/.emacs.d/virtualenv.el")

(save-excursion
    (set-buffer (get-buffer-create "*scratch*"))
    (insert "### scratch\n\n\n\n"))

(defun load-py ()
  "Loads some django stuff."
  (interactive)
  (load "~/.emacs.d/virtualenv.el"))

(defun rename-file-and-buffer (new-name)
  "Renames both current buffer and file it's visiting to NEW-NAME."
  (interactive "sNew name: ")
  (let ((name (buffer-name))
 (filename (buffer-file-name)))
    (if (not filename)
 (message "Buffer '%s' is not visiting a file!" name)
      (if (get-buffer new-name)
   (message "A buffer named '%s' already exists!" new-name)
 (progn
   (rename-file name new-name 1)
   (rename-buffer new-name)
   (set-visited-file-name new-name)
   (set-buffer-modified-p nil))))))

(transient-mark-mode 1) ; makes the region visible
(line-number-mode 1)    ; makes the line number show up
(column-number-mode 1)  ; makes the column number show up

; Django stuff
(defun load-django ()
  "Loads some django stuff."
  (interactive)
  (load "~/.emacs.d/nxhtml/autostart.el")
  (setq mumamo-background-colors nil) 
  (add-to-list 'auto-mode-alist '("\\.html$" . django-html-mumamo-mode)))

; show paren as you type
(show-paren-mode 1)
(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(gnus-ignored-newsgroups "^to\\\\.\\\\|^[0-9. ]+\\\\( \\\\|$\\\\)\\\\|^[\\\342\200\235]\\\342\200\235[#\342\200\231()]")
 '(gud-gdb-command-name "gdb --annotate=1")
 '(icicle-TAB-completion-methods (quote (fuzzy basic vanilla fuzzy)))
 '(large-file-warning-threshold nil))
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 )


(defun python-reinstate-current-directory ()
  "When running Python, add the current directory ('') to the head of sys.path.
For reasons unexplained, run-python passes arguments to the
interpreter that explicitly remove '' from sys.path. This means
that, for example, using `python-send-buffer' in a buffer
visiting a module's code will fail to find other modules in the
same directory.

Adding this function to `inferior-python-mode-hook' reinstates
the current directory in Python's search path."
  (python-send-string "import sys;sys.path[0:0] = ['']"))

(add-hook 'inferior-python-mode-hook 'python-reinstate-current-directory)


; Make isearch automatically wrap
(defadvice isearch-search (after isearch-no-fail activate)
  (unless isearch-success
    (ad-disable-advice 'isearch-search 'after 'isearch-no-fail)
    (ad-activate 'isearch-search)
    (isearch-repeat (if isearch-forward 'forward))
    (ad-enable-advice 'isearch-search 'after 'isearch-no-fail)
    (ad-activate 'isearch-search)))


(defun increment-number-at-point ()
      (interactive)
      (skip-chars-backward "0123456789")
      (or (looking-at "[0123456789]+")
          (error "No number at point"))
      (replace-match (number-to-string (1+ (string-to-number (match-string 0))))))

(defadvice python-calculate-indentation (around outdent-closing-brackets)
  "Handle lines beginning with a closing bracket and indent them so that
they line up with the line containing the corresponding opening bracket."
  (save-excursion
    (beginning-of-line)
    (let ((syntax (syntax-ppss)))
      (if (and (not (eq 'string (syntax-ppss-context syntax)))
               (python-continuation-line-p)
               (cadr syntax)
               (skip-syntax-forward "-")
               (looking-at "\\s)"))
          (progn
            (forward-char 1)
            (ignore-errors (backward-sexp))
            (setq ad-return-value (current-indentation)))
        ad-do-it))))

(ad-activate 'python-calculate-indentation)


(defun revert-all-buffers()
  "Refreshs all open buffers from their respective files"
  (interactive)
  (let* ((list (buffer-list))
         (buffer (car list)))
    (while buffer
      (if (string-match "\\*" (buffer-name buffer)) 
          (progn
            (setq list (cdr list))
            (setq buffer (car list)))
        (progn
          (set-buffer buffer)
          (revert-buffer t t t)
          (setq list (cdr list))
          (setq buffer (car list))))))
  (message "Refreshing open files"))


; extra key bindings for shell-mode
(eval-after-load "shell"
  '(define-key shell-mode-map (kbd "ESC <up>") 'comint-previous-input))
(eval-after-load "shell"
  '(define-key shell-mode-map (kbd "ESC <down>") 'comint-next-input))


;; (fset 'c-define-function-from-declaration
;;    (lambda (&optional arg) "Keyboard macro." (interactive "p") (kmacro-exec-ring-item (quote ("  xc-be	st	 wo>oxsearch bac	-re	class.*{ffb fw   oxbackward-li	b::{}	" 0 "%d")) arg)))
(defun c-define-function-from-declaration (&optional arg) 
  "Keyboard macro." 
  (interactive "p") 
  (kmacro-exec-ring-item (quote ("  xc-be	st	 wo>oxsearch bac	-re	class.*{ffb fw   oxbackward-li	b::{}	" 0 "%d")) arg))
;; (fset 'c-declare-function-from-definition
;;    (lambda (&optional arg) "Keyboard macro." (interactive "p") (kmacro-exec-ring-item (quote ("xc-beginning-of-defun )w  o<public:
;; ;::" 0 "%d")) arg)))


(defun c-declare-function-from-definition (&optional arg) 
  "Keyboard macro." 
  (interactive "p") 
  (kmacro-exec-ring-item (quote ("  xc-beginning-of-defun )w  o<public:
;::" 0 "%d")) arg))



(defun c-declare-or-define-function (&optional arg)
  (interactive "p")
  (if (string= (substring buffer-file-name -2 nil) ".h")
      (c-define-function-from-declaration arg)
    (c-declare-function-from-definition arg)))

(define-skeleton obj-c-init-skeleton
  "testing"
  "post: "
  "- (id) init{"
  "\n"
  "\nself = [super init];" >
  "\nif ( self ){" >
  "\n" > _
  "\n}" >
  "\n"
  "\nreturn self;" >
  "\n}")

(defun obj-c-declare-or-define-function (&optional arg)
  (interactive "p")
  (if (string= (substring buffer-file-name -2 nil) ".h")
      (obj-c-define-function-from-declaration arg)
    (obj-c-declare-function-from-definition arg)))

(defun obj-c-declare-function-from-definition (&optional arg)
  "creates the declaration in the .h file"
  (interactive)
  (save-excursion
    (beginning-of-defun)
    (if (search-forward "{" (point-at-eol) t)
        (backward-char)
      (end-of-line))
    (let ((funcdef (buffer-substring (point-at-bol) (point))))
      (ff-find-other-file)
      (beginning-of-buffer)
      (search-forward "}")
      (search-forward-regexp "[@+\-]")
      (beginning-of-line)
      (message "hey")
      (open-line 1)
      (insert (concat funcdef ";"))
      (ff-find-other-file)))
  (ff-find-other-file))


(defun obj-c-define-function-from-declaration (&optional arg)
  "creates the implementation in the .m file"
  (interactive)
  (save-excursion
    (let ((funcdec (buffer-substring (point-at-bol) (- (point-at-eol) 1))))
      (ff-find-other-file)
      (beginning-of-buffer)
      (search-forward "@end")
      (beginning-of-line)
      (open-line 3)
      (insert funcdec)
      (insert "{\n\n}")
      (backward-char 3)
      (insert "\n\n\t")
      (ff-find-other-file)))
  (ff-find-other-file))

(add-to-list 'auto-mode-alist '("\\.h\\'" . c++-mode))
(setq cc-other-file-alist
      '(("\\.cpp$" (".hpp" ".h"))
        ("\\.mm?$" (".h"))
        ("\\.h$" (".c" ".cpp" ".m" ".mm"))
        ("\\.hpp$" (".cpp" ".c"))
        ))
(add-hook 'c-mode-common-hook
  (lambda() 
    (setq c-basic-offset 4)
    (define-abbrev objc-mode-abbrev-table "init0"
      "" 'obj-c-init-skeleton)
    (local-set-key  (kbd "C-c o") 'ff-find-other-file)
    (local-set-key  (kbd "C-c f") 'c-declare-or-define-function)))


(defun insert-end-square-bracket ()
  "matches close square bracket"
  (interactive)
  (let ((orig (point)))
    (if (search-backward ":" (point-at-bol) t)
        (forward-char)
      (beginning-of-line-text))
    (insert "[")
    (goto-char (+ orig 1))
    (insert "]")))

; objc c property synthesize
(defun obj-c-insert-property ()
  "inserts an objective c property"
  (interactive)
  (save-excursion
    (let ((retain (string-match "\*" (buffer-substring (point-at-bol) (point-at-eol)))))
      (end-of-line)
      (beginning-of-line-text)
      (let ((declaration (buffer-substring (point) (point-at-eol))))
        (search-forward "@")
        (backward-char)
        (open-line 1)
        (insert "@property (nonatomic, ")
        (if retain
            (insert "retain")
          (insert "assign"))
        (insert ") ")
        (insert declaration)
        (ff-find-other-file)
        (save-excursion
          (beginning-of-buffer)
          (search-forward "@implementation")
          (end-of-line)
          (newline)
          (insert "@synthesize ")
          ; get just the name of the var plus the end semicolon
          (string-match "\\([^[:space:]]*\\);$" declaration)
          (let ((varname (match-string 1 declaration)))
            (insert (concat varname ";"))
            (if retain
                (let ()
                  (if (not (search-forward "super dealloc" nil t))
                    (let ()
                      (re-search-forward "\\(@end\\|[+\\-]\\)")
                      (beginning-of-line)
                      (open-line 2)
                      (insert "- (void) dealloc{\n\n[super dealloc];\n}")
                      (search-backward "[super dealloc];")
                      (c-indent-line)))

                  (beginning-of-line)
                  (open-line 1)
                  (c-indent-line)
                  (insert (concat "[" varname " release];"))))
        (ff-find-other-file)))))))

(add-hook 'objc-mode-hook 
          (lambda()
            (local-set-key (kbd "C-c i") 'obj-c-insert-property)
            (local-set-key (kbd "C-c ]") 'insert-end-square-bracket)
            (local-set-key (kbd "C-c f") 'obj-c-declare-or-define-function)))



(menu-bar-mode nil)

;; comment-dwim is toggle comment
;; Original idea from
;; http://www.opensubscriber.com/message/emacs-devel@gnu.org/10971693.html
(defun comment-dwim-line (&optional arg)
  "Replacement for the comment-dwim command.
   Just toggle comment"
  (interactive "*P")
  (comment-normalize-vars)
      (comment-or-uncomment-region (line-beginning-position) (line-end-position)))

(global-set-key "\M-;" 'comment-dwim-line)


;; Objective C stuff
(setq auto-mode-alist
      (cons '("\\.m$" . objc-mode) auto-mode-alist))
(setq auto-mode-alist
      (cons '("\\.mm$" . objc-mode) auto-mode-alist))

(defun bh-choose-header-mode ()
  (interactive)
  (if (string-equal (substring (buffer-file-name) -2) ".h")
      (progn
        ;; OK, we got a .h file, if a .m file exists we'll assume it's
        ; an objective c file. Otherwise, we'll look for a .cpp file.
        (let ((dot-m-file (concat (substring (buffer-file-name) 0 -1) "m"))
              (dot-cpp-file (concat (substring (buffer-file-name) 0 -1) "cpp")))
          (if (file-exists-p dot-m-file)
              (progn
                (objc-mode)
                )
            (if (file-exists-p dot-cpp-file)
                (c++-mode)
              )
            )
          )
        )
    )
  )
 
(add-hook 'find-file-hook 'bh-choose-header-mode)


; adobe javascript files auto mode
;; Objective C stuff
(setq auto-mode-alist
      (cons '("\\.jsfl$" . js-mode) auto-mode-alist))
(setq auto-mode-alist
      (cons '("\\.jsx$" . js-mode) auto-mode-alist))
                   
; Chicken Scheme
(defun load-chicken ()
  "Loads some chicken scheme stuff."
  (interactive)
  (load "~/.emacs.d/hen.el")
  (add-to-list 'auto-mode-alist '(("\\.scm$" . hen-mode)
                                   ("\\.meta$" . hen-mode)
                                   ("\\.setup$" . hen-mode))))


; icicles
;; (add-to-list 'load-path "~/.emacs.d/icicles/")
;; (require 'icicles)
;; (icy-mode 1)

(load "~/.emacs.d/init-ido.el")
(require 'init-ido)


(global-set-key (kbd "M-TAB") 'hippie-expand)

; better scheme mode?
(load "~/.emacs.d/quack.el")
(require 'quack)


