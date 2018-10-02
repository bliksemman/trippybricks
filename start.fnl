(require-macros "macro-utils")

{:enter
 (fn [game-state]
   (mset game-state
         :paddle-pos GAME-CENTER-X
         :bricks []
         :ball {:x GAME-CENTER-X :y PADDLE-TOP}
         :shake {:duration 0
                 :magnitude 0
                 :pos 0
                 :x 0}))
 :draw
 (fn []
   (general.draw)
   (love.graphics.setColor 1 1 1)
   (love.graphics.setFont large-font)
   (love.graphics.printf "Bouncy Ball" 0 300 GAME-WIDTH "center")
   (love.graphics.setFont medium-font)
   (love.graphics.printf "Press Space" 0 500 GAME-WIDTH "center"))
 
 :update
 (fn [dt]
   nil)
 :trigger-activated
 (fn []
   (mset game-state
         :level 1
         :score 0
         :screen :serve))}
