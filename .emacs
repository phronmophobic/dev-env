
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

(define-skeleton griffin-viewcontroller-declaration-skeleton
  "Creates the .h declaration for a view controller"
  "name: "
  "#include \"ViewController.h\"\n"
  "\n"
  "namespace Bpc \n"
  "{\n"
  "    class " (substring (buffer-name) 0 -2) " : public ViewController{\n" 
  "    private:\n" 
  "        \n"
  "    public:\n" 
  "        \n"
  "        " (substring (buffer-name) 0 -2) " ();\n"
  "        ~" (substring (buffer-name) 0 -2) "();\n"
  "    };\n"
  "}\n")

(define-skeleton griffin-viewcontroller-definition-skeleton
  "Creates the .m implementation for a view controller"
  "name: "
  "#include \"ViewControllerManager.h\"\n"
  "#include \"" (substring (buffer-name) 0 -4) ".h\"\n"
  "#include \"Label.h\"\n"
  "\n"
  "using namespace Bpc;\n"
  "\n"
  "" (substring (buffer-name) 0 -4) "::" (substring (buffer-name) 0 -4) "()\n"
  "{\n"
  "    loadView(\"ui_modal_" (downcase (substring (buffer-name) 0 -4)) ".json\",true);\n"
  "    \n"
  "    setCloseButton(\"closeButton\");\n"
  "}\n"
  "\n"
  "\n"
  "\n"
  "" (substring (buffer-name) 0 -4) "::~" (substring (buffer-name) 0 -4) "()\n"
  "{\n"
  "\n"
  "}\n"
  "\n"
  "\n")

(define-skeleton griffin-action-skeleton
  "Creates a new button action"
  "action method name: "
  "setAction(\"" (setq v1 (skeleton-read "button name: ")) "\", Action<" (substring (buffer-name) 0 -4) ">(this, &" (substring (buffer-name) 0 -4) "::" v1 "Pressed));"  )

(define-skeleton cpp-new-function-definition-skeleton
  "Creates a new function definition in a cpp file"
  "" 
  "void " (substring (buffer-name) 0 -4) "::" _ "(){\n\n}")

(defun insert-griffin-property (property-access)
  (interactive "cget/set/both [both]: ")
  (save-excursion
    (let ((post-fix)
          (type-end)
          (type-start)
          (method-name)
          (method-name-prefix)
          (var-name)
          (var-name-start)
          (var-name-end))
      (beginning-of-line)
      (search-forward ";")
      (setq var-name-end (- (point) 1))
      (search-backward " ")
      (forward-char)
      (setq var-name-start (point))
      (backward-char)
      (setq type-end (point))
      (beginning-of-line-text)
      (setq type-start (point))
      (setq var-name (buffer-substring var-name-start var-name-end))
      (setq method-name (if (string= (substring var-name 0 1) "_")
                            (substring var-name 1)
                          var-name))
      (cond
       ((char-equal property-access (string-to-char "g")) (setq post-fix "SYNTHESIZE_GET") (setq method-name-prefix "get"))
       ((char-equal property-access (string-to-char"s")) (setq post-fix "SYNTHESIZE_SET") (setq method-name-prefix "set"))
       (t  (setq post-fix "PROPERTY") (setq method-name-prefix "")))
      (search-forward "};")
      (previous-line)
      (end-of-line)
      (newline-and-indent)
      (insert (concat 
               "BPC_" post-fix "(" 
               (buffer-substring type-start type-end)
               ", "
               (buffer-substring var-name-start var-name-end)
               ", "
               method-name-prefix (capitalize (substring method-name 0 1))
               (substring method-name 1)
               ");")))))

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
    (define-abbrev objc-mode-abbrev-table "init0"
      "" 'obj-c-init-skeleton)
    (local-set-key  (kbd "C-c o") 'ff-find-other-file)
    (local-set-key  (kbd "C-c f") 'c-declare-or-define-function)))


(add-hook 'c++-mode-hook
          (lambda ()
            (local-set-key (kbd "C-c i") 'insert-griffin-property)
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



(menu-bar-mode nil)

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


;; -----------------------------------------------------------------------------
;; Git support
;; -----------------------------------------------------------------------------
(load "/opt/local/share/emacs/23.3/lisp/vc-git.elc")
(load "~/.emacs.d/git.el")
(load "~/.emacs.d/git-blame.el")
(add-to-list 'vc-handled-backends 'GIT)

;; (autoload 'eimp-mode "~/.emacs.d/eimp.el" "Emacs Image Manipulation Package." t)
;; (add-hook 'image-mode-hook 'eimp-mode)

;; auto complete
(add-to-list 'load-path "~/.emacs.d/auto-complete/")
(require 'auto-complete-config)
(add-to-list 'ac-dictionary-directories "~/.emacs.d/auto-complete//ac-dict")
(ac-config-default)
(put 'ido-exit-minibuffer 'disabled nil)

; fix global cycling in org mode
(add-hook 'term-setup-hook
          (lambda () (define-key input-decode-map "\e[Z" [backtab])))

