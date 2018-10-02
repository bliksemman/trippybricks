{:mset
 (fn [t ...]
   ;; Update several fields on a table in one expression:
   ;;    (mset t :key1 val1 :key 2 val2)
   (let [updates [...]
         expr []]
     (assert (= (% (# updates) 2) 0) "Even number of key -> value pairs required.")
     (for [i 1 (# updates) 2]
       (table.insert expr (list (sym "tset") t (. updates i) (. updates (+ i 1)))))
     expr))
 :if-let
 (fn [binding ...]
   ;; Bind expr to name and execute body when true.
   (assert (> (# binding) 0) "Requuire at least a binding: [x nil].")
   (assert (= (# binding) 2) "Only one binding allowed.")
   (list (sym "let") binding
         (list (sym "if") (. binding 1)
               ...)))}
