(defn setup-bricks []
  (let [bricks []
        horizontal-brick-count (math.floor (/ PLAY-AREA-WIDTH BRICK-WIDTH))
        vertical-brick-count 5
        horizontal-width (* horizontal-brick-count BRICK-WIDTH)
        ;; Center the bricks
        x-offset (->> horizontal-width
                      (- GAME-WIDTH)
                      (* 0.5)
                      (math.floor))
        y-offset 20]
    (for [x-index 0 (- horizontal-brick-count 1)]
      (let [x (+ x-offset (* x-index BRICK-WIDTH))]
        (for [y-index 0 (- vertical-brick-count 1)]
          (let [y (+ y-offset (* y-index BRICK-HEIGHT))]
            (table.insert bricks {:x x
                                  :y y
                                  :left x
                                  :right (+ x BRICK-WIDTH)
                                  :top y
                                  :bottom (+ y BRICK-HEIGHT)
                                  :width BRICK-WIDTH
                                  :height BRICK-HEIGHT
                                  :color (if (= (% y-index 2) 0)
                                             COLORS.brick1
                                             COLORS.brick2)})))))
    bricks))

{:enter
 (fn [game-state]
   (set game-state.paddle-pos GAME-CENTER-X)
   (set game-state.bricks (setup-bricks))
   (set game-state.ball {:x GAME-CENTER-X :y PADDLE-TOP})
   (set game-state.shake {:duration 0
                          :magnitude 0
                          :pos 0
                          :x 0}))
 :draw (fn [game-state] (general.draw game-state))
 :update
 (fn [dt]
   (general.update dt)
   (set game-state.ball.x game-state.paddle-pos))
    
 :trigger-activated
 (fn []
   (set game-state.screen :play))}
 
