(require-macros "macro-utils")

{:enter
 (fn []
   (each [i brick (lume.ripairs game-state.bricks)]
     (table.remove game-state.bricks i)
     (general.explode-brick brick)
     (: sounds.brick-hit :play)))

 :draw
 (fn []
   (general.draw)
   (love.graphics.setColor 1 1 1)
   (love.graphics.setFont large-font)
   (love.graphics.printf "Game Over" 0 300 GAME-WIDTH "center")
   (love.graphics.setFont medium-font)
   (love.graphics.printf (.. game-state.score " points") 0 380 GAME-WIDTH "center")
   (love.graphics.printf "Press Space" 0 500 GAME-WIDTH "center"))
 
 :update
 (fn [dt]
   (general.update dt))
 :trigger-activated
 (fn []
   (mset game-state
         :level 1
         :score 0
         :screen :serve))}
