(local repl (require "lib.stdio"))
(global color (require "color"))
(global general (require "general"))

(global fenster (require "fenster"))
(local richtig (require "richtig"))
(richtig.init)

(local WINDOW-WIDTH 1280)
(local WINDOW-HEIGHT 720)
(global GAME-WIDTH 1280)
(global GAME-HEIGHT 720)
(local GAME-ASPECT (/ GAME-WIDTH GAME-HEIGHT))
(global GAME-CENTER-X (/ GAME-WIDTH 2))
(global BOTTOM-MARGIN 20)
(global PADDLE-WIDTH 200)
(global PADDLE-HEIGHT 40)
(global PADDLE-WIDTH-HALF (/ PADDLE-WIDTH 2))
(global PADDLE-Y (- GAME-HEIGHT PADDLE-HEIGHT BOTTOM-MARGIN))
(global PADDLE-TOP (- PADDLE-Y (/ PADDLE-HEIGHT 2)))
(global PADDLE-BOTTOM (+ PADDLE-Y (/ PADDLE-HEIGHT 2)))
(global BALL-SIZE 10)
(global BRICK-WIDTH 80)
(global BRICK-HEIGHT 40)
(global PADDLE-VELOCITY 800)
(global PADDLE-X-MAX-SPEED 12)
(global PADDLE-X-SPEED-FACTOR (/ PADDLE-X-MAX-SPEED PADDLE-WIDTH-HALF))
(global MAX-BALL-SPEED 10)
(global PLAY-AREA-WIDTH 1024)
(global PLAY-AREA-LEFT (* 0.5 (- GAME-WIDTH PLAY-AREA-WIDTH)))
(global PLAY-AREA-RIGHT (- GAME-WIDTH PLAY-AREA-LEFT))
(global SHAKE-MAGNITUDE 2)
(global SHAKE-SPEED 220)
(global SHAKE-DURATION 0.4)
(global PARTICLE-SPEED 400)
(global PARTICLE-MAX-DURATION 2)
(global PARTICLE-MIN-DURATION 1)
(global LEVEL-SPEEDUP 1)
(global BASE-Y-SPEED 4)
(global COLORS
       {:brick1 (color.hex "#E33C0A")
        :brick2 (color.hex "#E8AC49")
        :paddle (color.hex "#915723")
        :ball (color.hex "#949D8A")
        :wall (color.hex "#915723")
        :background (color.hex "#22140A")})

(global sounds
       {:paddle-hit (love.audio.newSource "sounds/paddle-hit.wav" "static")
        :brick-shatter (love.audio.newSource "sounds/brick-shatter.wav" "static")
        :brick-hit (love.audio.newSource "sounds/brick-hit.wav" "static")
        :music (love.audio.newSource "sounds/music.mp3" "stream")})
                                     

(global particle-img
       (let [c (love.graphics.newCanvas (/ BRICK-WIDTH 20) (/ BRICK-HEIGHT 20))]
         (love.graphics.setCanvas c)
         (love.graphics.clear 1 1 1 1)
         (love.graphics.setCanvas)
         (-> c (: :newImageData) (love.graphics.newImage))))

(global game-state {:score 0
                    :level 1
                    :brick-explosion-particles []
                    :floor false})

(local game-canvas (love.graphics.newCanvas GAME-WIDTH GAME-HEIGHT))

(global small-font (love.graphics.newFont "font.ttf" 20))
(global medium-font (love.graphics.newFont "font.ttf" 40))
(global large-font (love.graphics.newFont "font.ttf" 60))
(love.graphics.setFont small-font)

(fenster.init :start game-state)

(fn richtig.load []
  (repl.start)
  (love.window.setMode
   WINDOW-WIDTH WINDOW-HEIGHT
   {:fullscreen false
    :resizable true})
  (love.window.setTitle "Trippy Bricks")
  (: sounds.music :setLooping true)
  (: sounds.music :play))

(fn richtig.draw []
  (let [screen-width (love.graphics.getWidth)
        screen-height (love.graphics.getHeight)
        screen-aspect (/ screen-width screen-height)
        scale-factor (if (<= screen-aspect GAME-ASPECT)
                         (/ screen-width GAME-WIDTH)
                         (/ screen-height GAME-HEIGHT))
        center-x (/ screen-width 2)
        center-y (/ screen-height 2)]

    (love.graphics.setCanvas game-canvas)
    (fenster.draw game-state)
    (love.graphics.setCanvas)
    (love.graphics.setColor 1 1 1)
    (love.graphics.draw game-canvas
                        (->> (* GAME-WIDTH scale-factor)
                             (- screen-width)
                             (* 0.5))
                        (->> (* GAME-HEIGHT scale-factor)
                             (- screen-height)
                             (* 0.5))
                        0
                        scale-factor scale-factor)))

(fn richtig.update [dt]
  (fenster.update dt)
  (when game-state.screen
    (fenster.transition game-state.screen game-state)
    (set game-state.screen nil)))


(fn richtig.keypressed [key]
  (when (= key "space")
    (lume.call fenster.trigger-activated))
  (when (= key "f")
    (set game-state.floor (not game-state.floor)))
  (when (= key "m")
    (let [action (if (: sounds.music :isPlaying) :stop :play)]
      (: sounds.music action))))

(fn richtig.joystickpressed [joystick button]
  (lume.call fenster.trigger-activated))
