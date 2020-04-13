class Map
  BLOCKES = ["□ ", "■ "]

  attr_reader :map
  attr_reader :start
  attr_reader :time
  attr_reader :score

  def initialize
    @map = zero_array
    @start = Time.now.to_i
    @time = 0
    @score = 0
  end

  # BlocksとTetriminoからMapデータを更新する
  def update(blocks, tetrimino)
    @map = zero_array
    (blocks + tetrimino.blocks).each do |block|
      @map[block.y][block.x] = 1
    end
  end

  # Mapの表示
  def display(map = @map)
    puts "time: #{@time = Time.now.to_i - start} sec"
    puts "score: #{score} lines"
    puts "- " * WIDTH

    map.map do |row|
      convert(row) # 標準出力に変換
    end

    puts "- " * WIDTH
  end

  # Tetriminoが最下部に到達したら、Blocksに変換する
  # 横に揃っている行があればBlockを消す
  def update_blocks(blocks, tetrimino, score)
    return blocks, tetrimino, score unless bottom?(tetrimino) # Blockが最下部に到達したらBlockを更新
    break_index = [] # 横に揃っている行の場所
    tmp_map = Marshal.load(Marshal.dump(map))
    tmp_map.each.with_index do |row, i|
      break_index << i if row.count { |r| r == 1 } == WIDTH
    end

    # 揃った行を点滅させる

    if !break_index.empty?
      wait(0.5)

      tmp_broken_map = tmp_map.map.with_index do |row, i|
        if break_index.include?(i)
          Array.new(WIDTH, 0)
        else
          row
        end
      end

      display(tmp_broken_map)

      wait(0.5)

      display

      wait(0.5)

      display(tmp_broken_map)

      wait(1.0)
    end

    # 点滅終わり

    break_index.reverse.each do |index|
      @score += 1
      tmp_map.delete_at(index) # reverseしておかないとdelete_atで消すべきindexが変わってしまう
    end
    break_index.count.times do
      tmp_map.unshift(Array.new(WIDTH, 0)) #　消した分上から0埋め
    end
    blocks = [] # Blocksは洗い替え
    HEIGHT.times do |j|
      WIDTH.times do |i|
        blocks << Block.new(i, j) if tmp_map[j][i] == 1
      end
    end
    update(blocks, tetrimino)

    wait(0.5)

    return blocks, Tetrimino.new(map), score # 新規Tetriminoを返す
  end

  private

  # 初期化用の零配列
  def zero_array
    Array.new(HEIGHT).map { Array.new(WIDTH, 0) }
  end

  # 標準出力に変換
  def convert(row)
    str = ""
    row.each do |block|
      str << BLOCKES[block]
    end
    puts str
  end

  # Tetriminoが最下部に到達したか判断
  def bottom?(tetrimino)
    tetrimino.collapse?(map, 0, 1)
  end

  def wait(time)
    begin
      Timeout.timeout(time) do
        STDIN.getch while true
      end
    rescue Timeout::Error
    end
  end
end
