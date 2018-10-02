{:hex
 (fn [hex]
   (-> [(: hex :match "#?(%x%x)(%x%x)(%x%x)")]
       (lume.map (fn [color]
                   (-> color
                       (tonumber 16)
                       (/ 255))))))}     

