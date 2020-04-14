class Map
  BLOCKES = ["□ ", "■ "]

  SCORES = [0, 40, 100, 300, 1200]

  attr_reader :map
  attr_reader :next_map
  attr_reader :start
  attr_reader :time
  attr_reader :score
  attr_reader :bottom_check

  def initialize
    @map = zero_matrix
    @next_map = zero_matrix_2
    @start = Time.now.to_f
    @time = 0.0
    @score = 0
    @bottom_check = 0.0
  end

  # BlocksとTetriminoからMapデータを更新する
  def update_map(blocks, tetrimino)
    @time = Time.now.to_f - start
    @map = zero_matrix
    (blocks + tetrimino.blocks).each do |block|
      @map[block.y][block.x] = 1
    end
  end

  # NextTetriminoからNextMapデータを更新する
  def update_next_map(tetrimino)
    @next_map = zero_matrix_2
    (tetrimino.next_blocks).each do |block|
      @next_map[block.y][block.x] = 1
    end
  end

  # Mapの表示
  def display(map = @map)
    puts "\e[H\e[2J"
    puts "score: #{score} points"

    puts "- " * WIDTH

    next_map.map do |row|
      convert(row) # 標準出力に変換
    end

    puts "- " * WIDTH

    map.map do |row|
      convert(row) # 標準出力に変換
    end

    puts "- " * WIDTH
  end

  # 結果の表示
  def display_result
    scores = CSV.read("scores.csv")[0]&.map(&:to_i) || []
    scores << score
    scores = scores.sort.reverse
    CSV.open("scores.csv", "w") do |csv|
      csv << scores
    end
    puts "-------------------"
    puts "- G A M E O V E R -"
    puts "-------------------"

    # ランキングとスコアの表示
    rank = scores&.count { |si| si > score } + 1 || 1
    puts "score: #{score} points rank: #{ordinalize(rank)}"
    puts "  ---   R A N K   ---  "
    scores[0, 10].each do |si|
      rank = scores.count { |sj| sj > si } + 1
      puts "#{ordinalize(rank)}:\t#{si}\tpoints"
    end
    exit
  end

  # Tetriminoが最下部に到達したら、Blocksに変換する
  # 横に揃っている行があればBlockを消す
  def update_blocks(blocks, tetrimino)
    return blocks, tetrimino unless bottom?(tetrimino) # Blockが最下部に到達したらBlockを更新
    break_index = [] # 横に揃っている行の場所
    tmp_map = Marshal.load(Marshal.dump(map))
    tmp_map.each.with_index do |row, i|
      break_index << i if row.inject(&:+) == WIDTH
    end

    # 揃った行を点滅させる

    if !break_index.empty?
      tmp_broken_map = tmp_map.map.with_index do |row, i|
        if break_index.include?(i)
          zero_array
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

    @score += SCORES[break_index.size] * (time.to_i / 60 + 1)

    break_index.reverse.each do |index|
      tmp_map.delete_at(index) # reverseしておかないとdelete_atで消すべきindexが変わってしまう
    end
    break_index.size.times do
      tmp_map.unshift(zero_array) #　消した分上から0埋め
    end
    blocks = [] # Blocksは洗い替え
    HEIGHT.times do |j|
      WIDTH.times do |i|
        blocks << Block.new(i, j) if tmp_map[j][i] == 1
      end
    end
    update_map(blocks, tetrimino)

    wait(0.5)

    next_tetrimino = Tetrimino.new(self, tetrimino.next_type)
    update_next_map(next_tetrimino)

    return blocks, next_tetrimino # 新規Tetriminoを返す
  end

  # Tetriminoが最下部に到達したか判断
  # 遊びを1秒設ける
  def bottom?(tetrimino)
    @bottom_check = time if bottom_check == 0.0
    if time - bottom_check > 1.0
      @bottom_check = 0.0
      tetrimino.collapse?(map, 0, 1)
    else
      false
    end
  end

  private

  # 初期化用の零配列
  def zero_array
    Array.new(WIDTH, 0)
  end

  # 初期化用の零行列
  def zero_matrix
    Array.new(HEIGHT).map { zero_array }
  end

  def zero_matrix_2
    Array.new(4).map { zero_array }
  end

  # 標準出力に変換
  def convert(row)
    str = ""
    row.each do |block|
      str << BLOCKES[block]
    end
    puts str
  end

  def wait(time)
    begin
      Timeout.timeout(time) do
        STDIN.getch while true
      end
    rescue Timeout::Error
    end
  end

  def ordinalize(num)
    if num >= 11 && num <= 13
      "#{num}th"
    elsif num % 10 == 1
      "#{num}st"
    elsif num % 10 == 2
      "#{num}nd"
    elsif num % 10 == 3
      "#{num}rd"
    else
      "#{num}th"
    end
  end
end
