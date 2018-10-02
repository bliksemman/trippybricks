(require-macros "macro-utils")

(var canvas nil)

(defn draw-centered-rectangle [mode x y width height ...]
  (let [x-offset (- x (/ width 2))
        y-offset (- y (/ height 2))]
    (love.graphics.rectangle mode x-offset y-offset width height ...)))

(defn get-paddle-direction []
  (if-let [joy (lume.first (love.joystick.getJoysticks))]
          (: joy :getAxis 1)
          ;; Keyboard
          (if (love.keyboard.isDown :left)
              -1
              (love.keyboard.isDown :right)
              1
              0)))

{:update
 (fn [dt]
   ;; Paddle
   (set game-state.paddle-pos
        (-> (get-paddle-direction) 
            (* dt PADDLE-VELOCITY)
            (+ game-state.paddle-pos)
            (lume.clamp (+ PLAY-AREA-LEFT PADDLE-WIDTH-HALF)
                        (- PLAY-AREA-RIGHT PADDLE-WIDTH-HALF))))

   ;; Particles
   (each [i particle (lume.ripairs game-state.brick-explosion-particles)]
     (mset particle
           :x (+ particle.x (* dt particle.x-velocity))
           :y (+ particle.y (* dt particle.y-velocity))
           :time-remaining (- particle.time-remaining dt))
     (when (< particle.time-remaining 0)
       (table.remove game-state.brick-explosion-particles i))))
 
 :explode-brick
 (fn [brick]
   ;; Setup particles
   (let [particles game-state.brick-explosion-particles
         particle-width (: particle-img :getWidth)
         particle-height (: particle-img :getHeight)]
     (for [x 0 (/ BRICK-WIDTH particle-width)]
       (for [y 0 (/ BRICK-HEIGHT particle-height)]
         (let [(x-velocity y-velocity) (-> 360
                                           (math.random)
                                           (math.rad)
                                           (lume.vector (math.random 10 PARTICLE-SPEED)))]
           (table.insert particles
                         {:color brick.color
                          :x (+ (* x particle-width) brick.x)
                          :y (+ (* y particle-height) brick.y)
                          :x-velocity x-velocity
                          :y-velocity y-velocity
                          :time-remaining (math.random PARTICLE-MIN-DURATION
                                                       PARTICLE-MAX-DURATION)}))))))   
 
 :shake-game
 (fn []
   (mset game-state.shake
         :magnitude SHAKE-MAGNITUDE
         :duration SHAKE-DURATION))
 :draw
 (fn []
   (when (not canvas)
     (set canvas (love.graphics.newCanvas GAME-WIDTH GAME-HEIGHT)))
   ;; Walls
   (love.graphics.clear (unpack COLORS.wall))
   ;; Game info
   (love.graphics.setFont small-font)
   (love.graphics.print (.. "Level: " game-state.level) 8 8)
   (love.graphics.print (.. "Score: " game-state.score) 8 40)
   (when game-state.floor
     (love.graphics.print "Floor On" 8 400))


   (let [original-canvas (love.graphics.getCanvas)]
     (love.graphics.setCanvas canvas)
     (love.graphics.clear 1 1 1 0)

     ;; Background
     (love.graphics.setColor (unpack COLORS.background))
     (love.graphics.rectangle :fill PLAY-AREA-LEFT 0 PLAY-AREA-WIDTH GAME-HEIGHT)

     ;; Bricks
     (each [_ brick (ipairs game-state.bricks)]
       (love.graphics.setColor (unpack brick.color))
       (love.graphics.rectangle :fill
                                (+ brick.x 1) (+ brick.y 1)
                                (- brick.width 2) (- brick.height 2)))     

     ;; Paddle
     (let [pos game-state.paddle-pos]
       (love.graphics.setColor (unpack COLORS.paddle))
       (draw-centered-rectangle :fill pos PADDLE-Y PADDLE-WIDTH PADDLE-HEIGHT))
     ;; Ball
     (let [ball game-state.ball]
       (love.graphics.setColor (unpack COLORS.ball))
       (draw-centered-rectangle :fill ball.x ball.y BALL-SIZE BALL-SIZE))

     ;; Particles
     (each [_ particle (pairs game-state.brick-explosion-particles)]
       (let [(r g b) (unpack particle.color)]
         (love.graphics.setColor r g b
                                 (lume.clamp
                                  (/ particle.time-remaining PARTICLE-MAX-DURATION)
                                  0 1))
         (love.graphics.draw particle-img particle.x particle.y)))

     ;; Draw screen
     (love.graphics.setColor 1 1 1)
     (love.graphics.setCanvas original-canvas)
     (love.graphics.draw canvas game-state.shake.x 0)))}
