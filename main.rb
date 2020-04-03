#!/usr/bin/ruby

require "io/console"
require "timeout"

require "./models/block"
require "./models/tetrimino"
require "./models/map"

HEIGHT = 30
WIDTH = 10

x = 0
y = 0

blocks = []
map = Map.new
tetrimino = Tetrimino.new(map.map)

time = 0
score = 0
start = Time.now.to_i

while true
  begin
    key = Timeout.timeout(0.05) do
      STDIN.getch
    end
  rescue Timeout::Error
    key = nil
  end

  exit if key == "\C-c" # command+C で終了

  tetrimino.move(map.map, key, time, start) # 一番最後に追加されたブロックだけ動かせる

  map.update(blocks, tetrimino) # 動かしたらMapを更新

  puts "time: #{time = Time.now.to_i - start} sec"
  puts "score: #{score} lines"
  puts "- " * WIDTH

  map.display

  puts "- " * WIDTH

  blocks, tetrimino, score = map.update_blocks(blocks, tetrimino, score)
end
