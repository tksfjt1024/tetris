class Map
  BLOCKES = ["□ ", "■ "]

  def initialize
    @map = zero_array
  end

  def map
    @map
  end

  # BlocksとTetriminoからMapデータを更新する
  def update(blocks, tetrimino)
    @map = zero_array
    (blocks + tetrimino.blocks).each do |block|
      @map[block.y][block.x] = 1
    end
  end

  # Mapの表示
  def display
    @map.map do |row|
      convert(row) # 標準出力に変換
    end
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
    break_index.reverse.each do |index|
      score += 1
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
    begin
      input = Timeout.timeout(0.5) do
        STDIN.getch while true
      end
    rescue Timeout::Error
      puts input
    end
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
end
