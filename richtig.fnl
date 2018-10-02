;; Somewhat robust error handling for Love2d
;; To be used with a code reloading system.
(local module {})

(local love-callback-names
       [:update
        :load
        :mousepressed
        :mousereleased
        :keypressed
        :keyreleased
        :gamepadpressed
        :joystickpressed
        :focus
        :quit])
(local errors {})

(defn format-error [exception traceback]
  (.. exception
      "\n\n"
      traceback))

(defn error-handler [name]
  (fn [e]
    (print name (format-error e (debug.traceback)))
    (tset errors name (format-error e (debug.traceback)))))

(defn make-wrapper [name]
  (fn [...]
    (let [args [...]
          callback (. module name)]
      (when callback
        (xpcall (fn []
                  (tset errors name nil)
                  (callback (unpack args)))
                (error-handler name))))))

(defn setup-error-renderer [love-draw]
  (fn [...]
    (love-draw ...)
    (let [(e error-message) (next errors)]
      (when e
        (love.graphics.reset)
        (love.graphics.clear 0 0 0.5)
        (love.graphics.setFont (love.graphics.newFont 12))

        (love.graphics.printf error-message 10 10
                              (love.graphics.getWidth))))))

(defn setup-replacements []
  (each [_ name (ipairs love-callback-names)]
    (->> (make-wrapper name)
         (tset love name)))
  ;; Add error rendering hook
  (set love.draw (setup-error-renderer (make-wrapper :draw))))

(set module.init setup-replacements)

module
