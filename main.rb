#!/usr/bin/ruby

require "io/console"
require "timeout"

require "./models/block"
require "./models/tetrimino"
require "./models/map"

HEIGHT = 20
WIDTH = 10

x = 0
y = 0

blocks = []
map = Map.new
tetrimino = Tetrimino.new(map)
map.update_next_map(tetrimino)

while true
  begin
    key = Timeout.timeout(0.1) do
      STDIN.getch
    end
  rescue Timeout::Error
    key = nil
  end

  map.display_result if key == "\C-c" # ctl+C で終了

  tetrimino.move(map, key) # 一番最後に追加されたブロックだけ動かせる

  map.update_map(blocks, tetrimino) # 動かしたらMapを更新

  map.display

  blocks, tetrimino = map.update_blocks(blocks, tetrimino)
end
