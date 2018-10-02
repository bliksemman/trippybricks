;; Manage flow between screens

(local fenster {})
(local meta {:__index {}})

(setmetatable fenster meta)

(fn setup-screen [screen-name ...]
  ;; Add metatable to proxy missing keys
  (let [screen (require screen-name)]
    (set fenster.screen screen)
    (set meta.__index screen) ;; Proxy all access to the screen
    (let [enter screen.enter]
      (when enter (enter ...)))))

(fn fenster.init [initial-screen ...]
  (setup-screen initial-screen ...))

(fn fenster.transition [new-screen ...]
  (let [exit fenster.screen.exit]
    (when exit (exit ...)))
  (setup-screen new-screen ...))

fenster
