(require-macros "macro-utils")

{:enter
 (fn []
   (mset game-state.ball
         :x-velocity 2
         :y-velocity (+ BASE-Y-SPEED (* game-state.level LEVEL-SPEEDUP))))

 :draw (fn [] (general.draw))
 :update
 (fn [dt]
   (general.update dt)

   ;; Screen shake
   (let [shake game-state.shake]
     (mset shake
           :pos (+ shake.pos (* SHAKE-SPEED dt shake.duration))
           :x (* SHAKE-MAGNITUDE (math.sin shake.pos))
           :duration (lume.clamp (- shake.duration dt) 0 SHAKE-DURATION)))
   
   ;; Ball
   (let [ball game-state.ball
         old-ball (lume.merge ball)]
     (mset ball
           :x (+ ball.x ball.x-velocity)
           :y (+ ball.y ball.y-velocity))
     ;; Bounce against screen edges
     (when (<= ball.x PLAY-AREA-LEFT)
       (: sounds.paddle-hit :play)
       (general.shake-game)
       (set ball.x-velocity (math.abs ball.x-velocity)))
     (when (>= ball.x PLAY-AREA-RIGHT)
       (: sounds.paddle-hit :play)
       (general.shake-game)
       (set ball.x-velocity (- (math.abs ball.x-velocity))))
     (when (< ball.y 0)
       (: sounds.paddle-hit :play)
       (general.shake-game)
       (set ball.y-velocity (math.abs ball.y-velocity)))
     (when (> ball.y GAME-HEIGHT)
       (if game-state.floor
           (do
             ;; Floor is enabled so just bounce the ball back
             (sounds.play :paddle-hit)
             (: sounds.paddle-hit :play)
             (general.shake-game)
             (set ball.y-velocity (- (math.abs ball.y-velocity))))
           (set game-state.screen :game-over)))

     ;; Ball => brick collision
     (each [i brick (lume.ripairs game-state.bricks)]
       (when (and (<= brick.left ball.x brick.right)
                  (<= brick.top ball.y brick.bottom))
         (general.shake-game)
         (: sounds.brick-shatter :play)
         (: sounds.brick-hit :play)
         (set game-state.score (+ game-state.score 1))
         ;; Remove the brick
         (table.remove game-state.bricks i)
         ;; Detect collision edge and adjust velocities
         (if (< brick.left old-ball.x brick.right)
             (set ball.y-velocity (- old-ball.y-velocity))
             (< brick.top old-ball.y brick.bottom)
             (set ball.x-velocity (- old-ball.x-velocity))
             (<= old-ball.x-velocity old-ball.y-velocity)
             (set ball.y-velocity (- old-ball.y-velocity))
             (set ball.x-velocity (- old-ball.x-velocity)))

         (general.explode-brick brick)))                     
   
     ;; Ball => paddle collision
     (let [paddle-pos game-state.paddle-pos
           paddle-left (- paddle-pos PADDLE-WIDTH-HALF)
           paddle-right (+ paddle-pos PADDLE-WIDTH-HALF)]
       (when (and (<= paddle-left ball.x paddle-right)
                  (<= PADDLE-TOP ball.y PADDLE-BOTTOM))
         (general.shake-game game-state)
         (: sounds.paddle-hit :play)
         (let [offset (- ball.x paddle-pos)]
           (mset ball
                 :x-velocity (* PADDLE-X-SPEED-FACTOR offset)
                 :y-velocity (- (math.abs ball.y-velocity)))))))

   ;; Level cleared
   (when (< (# game-state.bricks) 1)
     (mset game-state
           :level (+ game-state.level 1)
           :screen :serve)))}
                         
