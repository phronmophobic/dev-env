
(setq-default indent-tabs-mode nil);

(setq-default iswitchb-mode t);
(setq-default python-remove-cwd-from-path nil)
(setq-default set-mark-command-repeat-pop t)
(setq-default x-select-enable-clipboard t)
(setq-default mark-ring-max 5)

; Org Mode stuff
(defun file-string (file)
  "Read the contents of a file and return as a string."
  (with-temp-buffer
    (insert-file-contents file)
    (buffer-string)))
(add-hook 'org-mode-hook
          (lambda ()
            (setq org-export-html-table-tag "<table class=\"table table-striped table-condensed table-hover table-bordered\" style=\"width: auto;\" >")
            (setq org-export-html-style (file-string "~/.emacs.d/org-mode.css"))))
          

(setq org-confirm-babel-evaluate nil)
(setq org-descriptive-links nil)

(org-babel-do-load-languages
 'org-babel-load-languages
 '((python . t)
   (R . t)
   (sh . t)
   (gnuplot . t)
   (emacs-lisp . t)
   ))

(require 'org-exp-blocks)
(defun org-export-blocks-poop (body &rest headers)
  (message "exporting poop")
  (cond
   ((eq org-export-current-backend 'html) 
    (format "   #+BEGIN_HTML\n   <poop>%s</poop>\n#+END_HTML" body))
   ((eq org-export-current-backend 'latex) body)
   (t nil))
)
(setq org-export-blocks
  (cons '(poop org-export-blocks-poop) org-export-blocks))

(setq org-src-fontify-natively t)
; End org mode stuff

(setq inhibit-startup-message t) ;will inhibit startup messages.

(global-auto-revert-mode t)
; change yes or no prompt to y or n
(fset 'yes-or-no-p 'y-or-n-p)

;; get rid of those pesky autosave~ files
(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))


;(load "~/.emacs.d/project-local-variables.el")
;(load "~/.emacs.d/find-file-in-project.el")

;(load "~/.emacs.d/virtualenv.el")

(save-excursion
    (set-buffer (get-buffer-create "*scratch*"))
    (insert ";; scratch\n\n\n\n"))


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


; show paren as you type
(show-paren-mode 1)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(cljsbuild-hide-buffer-on-success nil)
 '(clojure-defun-indents (quote (go-chan pfor cached go-loop pwhen)))
 '(gnus-ignored-newsgroups "^to\\\\.\\\\|^[0-9. ]+\\\\( \\\\|$\\\\)\\\\|^[\\\342\200\235]\\\342\200\235[#\342\200\231()]")
 '(gud-gdb-command-name "gdb --annotate=1")
 '(icicle-TAB-completion-methods (quote (fuzzy basic vanilla fuzzy)))
 '(large-file-warning-threshold nil)
 '(markdown-command "multimarkdown")
 '(org-agenda-files nil)
 '(org-startup-truncated nil)
 '(uniquify-buffer-name-style (quote forward) nil (uniquify)))
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


(defun c-define-function-from-declaration (&optional arg)
  "Define a function from it's declaration"
  (interactive "p")
  (save-excursion
    (beginning-of-line-text)
    (let ((s (buffer-substring (point) (point-at-eol))))
      (ff-find-other-file)
      (end-of-buffer)
      (save-excursion
        (insert 
         s
         "\n\n"))
      (search-forward "(")
      (backward-word)
      (insert 
       (substring (buffer-name) 0 -4)
       "::")
      (search-forward ";")
      (delete-char -1)
      (insert "{\n\n}")
      (previous-line)
      (c-indent-line-or-region))))



(defun c-declare-function-from-definition (&optional arg) 
  "Keyboard macro." 
  (interactive "p") 
  (save-excursion
    (beginning-of-defun)
    (let ((s (buffer-substring (point) (point-at-eol))))
      (ff-find-other-file)
      (beginning-of-buffer)
      (search-forward "public:")
      (newline-and-indent)
      (insert s)
      (search-backward "::")
      (delete-char 2)
      (backward-kill-word 1)
      (search-forward "{")
      (backward-delete-char 1)
      (insert ";")
)))
;;     )
;;   (kmacro-exec-ring-item (quote ("  xc-beginning-of-defun
;;  )w  o<public:
;; ;::" 0 "%d")) arg))



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

(define-skeleton cpp-new-function-definition-skeleton
  "Creates a new function definition in a cpp file"
  "" 
  "void " (substring (buffer-name) 0 -4) "::" _ "(){\n\n}")

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
      (backward-char 2)
      (c-indent-line)
      (ff-find-other-file)))
  (ff-find-other-file))

(defun obj-c-add-import (name &optional arg)
  "inserts an import statement to the top"
  (interactive "simport name: ")
  (save-excursion
    (end-of-buffer)
    (if (not (search-backward (concat "#import \"" name ".h\"") (point-min) t))
        (let ()
          (search-backward "#import")
          (end-of-line)
          (insert (concat "\n#import \"" name ".h\""))))))

(defun cpp-add-include (name)
  "inserts an include statement at the top"
  (interactive "simport name: ")
  (save-excursion
    (end-of-buffer)
    (if (not (search-backward (concat "#include \"" name ".h\"") (point-min) t))
        (let ()
          (search-backward "#include")
          (end-of-line)
          (insert (concat "\n#include \"" name ".h\""))))))


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
    (setq c-default-style "linux"
          c-basic-offset 4)
    (c-set-offset 'arglist-intro '+)
    (c-set-offset 'arglist-close 0)

    (define-abbrev objc-mode-abbrev-table "init0"
      "" 'obj-c-init-skeleton)
    (local-set-key  (kbd "C-c o") 'ff-find-other-file)
    (local-set-key  (kbd "C-c f") 'c-declare-or-define-function)))


(add-hook 'c++-mode-hook
          (lambda ()
            (local-set-key (kbd "C-c n") 'cpp-new-function-definition-skeleton)))

(defun insert-end-square-bracket ()
  "matches close square bracket"
  (interactive)
  (let ((left (num-strs-on-line "["))
        (right (num-strs-on-line "]")))
    (insert "]")
    (backward-char)
    (if (not (> left right))
        (save-excursion
          (beginning-of-line)
          (search-forward "=" (point-at-eol) t)
          (search-forward "&&" (point-at-eol) t)
          (search-forward "||" (point-at-eol) t)
          (search-forward "(" (point-at-eol) t)
          (search-forward "return" (point-at-eol) t)
          (search-forward " in " (point-at-eol) t)
          (skip-chars-forward " ")
          (insert "["))
      (forward-char))))


(defun num-strs-on-line (s)
  (save-excursion
    (end-of-line)
    (let  ((accum 0))
      (while (search-backward s (point-at-bol) t)
        (setq accum (+ accum 1)))
      accum)))

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
            (local-set-key (kbd "]") 'insert-end-square-bracket)
            (local-set-key (kbd "C-c ]") (lambda (&optional arg) (interactive) (insert "]")))
            (local-set-key (kbd "C-c f") 'obj-c-declare-or-define-function)))



;; the sky is the limit
;; http://bzg.fr/emacs-strip-tease.html
(menu-bar-mode 0)

;; comment-dwim is toggle comment
;; Original idea from
;; http://www.opensubscriber.com/message/emacs-devel@gnu.org/10971693.html
(defun comment-dwim-line (&optional arg)
  "Replacement for the comment-dwim command.
   Just toggle comment"
  (interactive "*P")
  
  (comment-normalize-vars)
  (if (use-region-p)
      (comment-or-uncomment-region (region-beginning) (region-end))
    (comment-or-uncomment-region (line-beginning-position) (line-end-position))))

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

;; php mode
(autoload 'php-mode "~/.emacs.d/php-mode-1.5.0/php-mode" "Major mode for editing php code." t)
(add-to-list 'auto-mode-alist '("\\.php$" . php-mode))
(add-to-list 'auto-mode-alist '("\\.inc$" . php-mode))

; markdown mode
(autoload 'markdown-mode "~/.emacs.d/markdown-mode/markdown-mode.el"
   "Major mode for editing Markdown files" t)
(add-to-list 'auto-mode-alist '("\\.md$" . markdown-mode))

; markdown mode
(autoload 'yaml-mode "~/.emacs.d/elpa/yaml-mode-0.0.7/yaml-mode.el"
   "Major mode for editing yaml files" t)
(add-to-list 'auto-mode-alist '("\\.ya?ml$" . yaml-mode))




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


;; -----------------------------------------------------------------------------
;; Git support
;; -----------------------------------------------------------------------------
;; (load "/opt/local/share/emacs/24.2/lisp/vc-git.elc")
;; (load "~/.emacs.d/git.el")
;; (load "~/.emacs.d/git-blame.el")
;; (add-to-list 'vc-handled-backends 'GIT)


;; auto complete
(add-to-list 'load-path "~/.emacs.d/auto-complete/")
(require 'auto-complete-config)
(add-to-list 'ac-dictionary-directories "~/.emacs.d/auto-complete//ac-dict")
(ac-config-default)
(add-to-list 'ac-modes 'octave-mode)

(put 'ido-exit-minibuffer 'disabled nil)

; fix global cycling in org mode
(add-hook 'term-setup-hook
          (lambda () (define-key input-decode-map "\e[Z" [backtab])))

;; (load-file "~/.emacs.d/rudel/rudel-loaddefs.el")

;; Transpose line
(defun move-line (n)
  "Move the current line up or down by N lines."
  (interactive "p")
  (setq col (current-column))
  (beginning-of-line) (setq start (point))
  (end-of-line) (forward-char) (setq end (point))
  (let ((line-text (delete-and-extract-region start end)))
    (forward-line n)
    (insert line-text)
    ;; restore point to original column in moved line
    (forward-line -1)
    (forward-char col)))

(defun move-line-up (n)
  "Move the current line up by N lines."
  (interactive "p")
  (move-line (if (null n) -1 (- n))))

(defun move-line-down (n)
  "Move the current line down by N lines."
  (interactive "p")
  (move-line (if (null n) 1 n)))

(global-set-key (kbd "ESC p") 'move-line-up)
(global-set-key (kbd "ESC <up>") 'move-line-up)
(global-set-key (kbd "ESC n") 'move-line-down)
(global-set-key (kbd "ESC <down>") 'move-line-down)


(defun align-repeat (start end regexp)
  "Repeat alignment with respect to 
     the given regular expression."
  (interactive "r\nsAlign regexp: ")
  (align-regexp start end 
                (concat "\\(\\s-*\\)" regexp) 1 1 t))


(defun delete-this-buffer-and-file ()
  "Removes file connected to current buffer and kills buffer."
  (interactive)
  (let ((filename (buffer-file-name))
        (buffer (current-buffer))
        (name (buffer-name)))
    (if (not (and filename (file-exists-p filename)))
        (message "Buffer '%s' is not visiting a file!" name)
      (when (yes-or-no-p "Are you sure you want to remove this file? ")
        (delete-file filename)
        (kill-buffer buffer)
        (message "File '%s' successfully removed" filename)))))


;;--------------------------------------------------------------------
;; Lines enabling gnuplot-mode
;; load the file

;; specify the gnuplot executable (if other than /usr/bin/gnuplot)

;; (add-to-list 'Info-default-directory-list "~/.emacs.d/gnuplot-mode/")

;; ;; move the files gnuplot.el to someplace in your lisp load-path or
;; ;; use a line like
 (setq load-path (append (list "~/.emacs.d/gnuplot-mode/") load-path))

;; ;; these lines enable the use of gnuplot mode
  (autoload 'gnuplot-mode "gnuplot" "gnuplot major mode" t)
  (autoload 'gnuplot-make-buffer "gnuplot" "open a buffer in gnuplot mode" t)

;; ;; this line automatically causes all files with the .gp extension to
;; ;; be loaded into gnuplot mode
  (setq auto-mode-alist (append '(("\\.gp$" . gnuplot-mode)) auto-mode-alist))

;; ;; This line binds the function-9 key so that it opens a buffer into
;; ;; gnuplot mode 
  (global-set-key [(f9)] 'gnuplot-make-buffer)


;; end of line for gnuplot-mode
;;--------------------------------------------------------------------

; Clojure mode

(require 'package)
(add-to-list 'package-archives
             '("marmalade" . "http://marmalade-repo.org/packages/"))
(package-initialize)
(add-hook 'nrepl-interaction-mode-hook
  'nrepl-turn-on-eldoc-mode)
(add-hook 'nrepl-mode-hook 'paredit-mode)
(add-hook 'nrepl-mode-hook 'rainbow-delimiters-mode)

(setq nrepl-popup-stacktraces nil)
(add-to-list 'auto-mode-alist '("\\.cljx\\'" . clojure-mode))

(add-hook 'clojure-mode-hook
          (lambda ()
            (put 'defwidget 'clojure-backtracking-indent '(4 (2)))
            (put 'defcomponent 'clojure-backtracking-indent '(4 4 (2)))
            (require 'paredit)
            (paredit-mode +1)))


(add-hook 'nrepl-mode-hook
          (lambda ()
            (local-set-key (kbd "ESC p") 'nrepl-backward-input)
            (local-set-key (kbd "ESC n") 'nrepl-forward-input)            
            (local-set-key (kbd "ESC <up>") 'nrepl-backward-input)
            (local-set-key (kbd "ESC <down>") 'nrepl-forward-input)))




(eval-after-load 'paredit
  '(progn
     (define-key paredit-mode-map (kbd "C-c {") 'paredit-backward-barf-sexp)
     (define-key paredit-mode-map (kbd "C-c }") 'paredit-forward-barf-sexp)
     (define-key paredit-mode-map (kbd "C-c (") 'paredit-backward-slurp-sexp)
     (define-key paredit-mode-map (kbd "C-c )") 'paredit-forward-slurp-sexp)
     ;; (define-key paredit-mode-map (kbd "ESC p") 'paredit-splice-sexp-killing-backward)
     ;; (define-key paredit-mode-map (kbd "ESC n") 'paredit-splice-sexp-killing-forward)
     (define-key paredit-mode-map (kbd "M-[") 'paredit-wrap-square)
     (define-key paredit-mode-map (kbd "M-;") 'comment-dwim-line)))


(defun piggieback ()
  "Refreshs all open buffers from their respective files"
  (interactive)
  (nrepl-eval "(require 'cljs.repl.browser)")
  (nrepl-eval "(cemerick.piggieback/cljs-repl :repl-env (cljs.repl.browser/repl-env :port 9001))"))
    



;; react jsx
(eval-after-load 'js2-mode
  '(progn
     (require 'js2-imenu-extras)

     ;; The code to record the class is identical to that for
     ;; Backbone so we just make an alias
     (defalias 'js2-imenu-record-react-class
       'js2-imenu-record-backbone-extend)

     (unless (loop for entry in js2-imenu-extension-styles
                   thereis (eq (plist-get entry :framework) 'react))
       (push '(:framework react
               :call-re "\\_<React\\.createClass\\s-*("
               :recorder js2-imenu-record-react-class)
             js2-imenu-extension-styles))

     (add-to-list 'js2-imenu-available-frameworks 'react)
     (add-to-list 'js2-imenu-enabled-frameworks 'react)))
(defun modify-syntax-table-for-jsx ()
  (modify-syntax-entry ?< "(>")
  (modify-syntax-entry ?> ")<"))

(add-hook 'js2-mode-hook 'modify-syntax-table-for-jsx)


(autoload 'jsx-mode "~/.emacs.d/jsx-mode.el"
   "Mode for editing jsx files" t)
