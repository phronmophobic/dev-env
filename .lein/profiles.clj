{:user {:plugins [[lein-oneoff "0.3.0"]
                  [lein-pprint "1.1.1"]]
        :repl-options {
                       :init (do
                               (use '[clojure.pprint :only [pprint]])
                               (use '[clojure.reflect :only [reflect]])
                               (binding [*ns* (the-ns 'clojure.core)]
                                 (eval '(def pprint clojure.pprint/pprint))
                                 (eval '(def reflect clojure.reflect/reflect))))}}}

