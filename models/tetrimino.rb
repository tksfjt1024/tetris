require "csv"

class Tetrimino
  TYPES = %w[
    i
    o
    s
    z
    j
    l
    t
  ]

  attr_reader :blocks

  def initialize(map)
    @type = TYPES.sample # ランダムで落ちてくる
    @status = 0
    send("create_#{@type}_tetrimino")
    map.display_result if collapse?(map.map, 0, 1) # Gameが続行されるか判断
  end

  # 各Tetriminoのデータ
  def create_i_tetrimino
    x, y = WIDTH / 2 - 1, 0
    @blocks = [
      Block.new(x, y),
      Block.new(x, y + 1),
      Block.new(x, y + 2),
      Block.new(x, y + 3),
    ]
  end

  def create_o_tetrimino
    x, y = WIDTH / 2 - 1, 0
    @blocks = [
      Block.new(x, y),
      Block.new(x + 1, y),
      Block.new(x, y + 1),
      Block.new(x + 1, y + 1),
    ]
  end

  def create_s_tetrimino
    x, y = WIDTH / 2 - 1, 0
    @blocks = [
      Block.new(x, y),
      Block.new(x + 1, y),
      Block.new(x, y + 1),
      Block.new(x - 1, y + 1),
    ]
  end

  def create_z_tetrimino
    x, y = WIDTH / 2 - 1, 0
    @blocks = [
      Block.new(x, y),
      Block.new(x - 1, y),
      Block.new(x, y + 1),
      Block.new(x + 1, y + 1),
    ]
  end

  def create_j_tetrimino
    x, y = WIDTH / 2 - 1, 0
    @blocks = [
      Block.new(x, y),
      Block.new(x, y + 1),
      Block.new(x, y + 2),
      Block.new(x - 1, y + 2),
    ]
  end

  def create_l_tetrimino
    x, y = WIDTH / 2 - 1, 0
    @blocks = [
      Block.new(x, y),
      Block.new(x, y + 1),
      Block.new(x, y + 2),
      Block.new(x + 1, y + 2),
    ]
  end

  def create_t_tetrimino
    x, y = WIDTH / 2 - 1, 0
    @blocks = [
      Block.new(x, y),
      Block.new(x, y + 1),
      Block.new(x + 1, y + 1),
      Block.new(x - 1, y + 1),
    ]
  end

  def move(map, key)
    dx, dy = 0, 0
    # 30秒経過するごとに落下速度があがる
    dy += 1 if (Time.now.to_f - map.time.to_i - map.start.to_i) % (1.0 / (map.time.to_f / 60 + 1)) < 0.1
    if key == "\e" && STDIN.getch == "["
      case STDIN.getch
      when "B" # 下
        dy += 1
      when "C" # 右
        dx += 1
      when "D" # 左
        dx -= 1
      end
    elsif key == " " # Space
      rotate_tetrimino(map.map) # Spaceで回転
    end

    # 壁やBlockにぶつからなければkeyに応じてBlocksの位置を更新
    unless collapse?(map.map, dx, dy)
      @blocks.each do |block|
        block.move(dx, dy)
      end
    end
  end

  # 回転の処理
  def rotate_tetrimino(map)
    x, y = @blocks[0].x, @blocks[0].y
    tmp_blocks = send("#{@type}_tetriminoes", x, y)[(@status + 1) % 4]
    if rotate?(map, tmp_blocks)
      @blocks = tmp_blocks
      @status = (@status + 1) % 4
    end
  end

  # 移動可能か判断
  # Blockの有無を0・1で表し、移動の前後を足し算すると重なる場所が2になる
  def collapse?(map, dx, dy)
    tmp_map = Marshal.load(Marshal.dump(map))
    @blocks.each do |block|
      x, y = block.x, block.y
      tmp_map[y][x] -= 1
      # 画面外に出る時はreturn
      return true if y + dy < 0 || y + dy >= HEIGHT || x + dx < 0 || x + dx >= WIDTH
      tmp_map[y + dy][x + dx] += 1
    end
    tmp_map.flatten.count { |block| block == 2 } > 0
  end

  # 回転可能か判断
  # Blockの有無を0・1で表し、回転の前後を足し算すると重なる場所が2になる
  def rotate?(map, blocks)
    tmp_map = Marshal.load(Marshal.dump(map))
    @blocks.each do |block|
      x, y = block.x, block.y
      tmp_map[y][x] -= 1
    end
    blocks.each do |block|
      x, y = block.x, block.y
      # 画面外に出る時はreturn
      return false if y < 0 || y >= HEIGHT || x < 0 || x >= WIDTH
      tmp_map[y][x] += 1
    end
    tmp_map.flatten.count { |block| block == 2 }.zero?
  end

  private

  # 各Tetriminoの回転データ
  # statusと配列のindexが対応する
  # 現在のBlocksの1つめのBlockのx・yと次のstatusによって、回転後のBlocksが取得できる
  def i_tetriminoes(x, y)
    [
      [
        Block.new(x + 2, y - 2),
        Block.new(x + 2, y - 1),
        Block.new(x + 2, y),
        Block.new(x + 2, y + 1),
      ],
      [
        Block.new(x + 2, y + 2),
        Block.new(x + 1, y + 2),
        Block.new(x, y + 2),
        Block.new(x - 1, y + 2),
      ],
      [
        Block.new(x - 2, y + 2),
        Block.new(x - 2, y + 1),
        Block.new(x - 2, y),
        Block.new(x - 2, y - 1),
      ],
      [
        Block.new(x - 2, y - 2),
        Block.new(x - 1, y - 2),
        Block.new(x, y - 2),
        Block.new(x + 1, y - 2),
      ],
    ]
  end

  def o_tetriminoes(x, y)
    [
      [
        Block.new(x, y - 1),
        Block.new(x + 1, y - 1),
        Block.new(x + 1, y),
        Block.new(x, y),
      ],
      [
        Block.new(x + 1, y),
        Block.new(x + 1, y + 1),
        Block.new(x, y + 1),
        Block.new(x, y),
      ],
      [
        Block.new(x, y + 1),
        Block.new(x - 1, y + 1),
        Block.new(x - 1, y),
        Block.new(x, y),
      ],
      [
        Block.new(x - 1, y),
        Block.new(x - 1, y - 1),
        Block.new(x, y - 1),
        Block.new(x, y),
      ],
    ]
  end

  def s_tetriminoes(x, y)
    [
      [
        Block.new(x + 1, y - 1),
        Block.new(x + 2, y - 1),
        Block.new(x + 1, y),
        Block.new(x, y),
      ],
      [
        Block.new(x + 1, y + 1),
        Block.new(x + 1, y + 2),
        Block.new(x, y + 1),
        Block.new(x, y),
      ],
      [
        Block.new(x - 1, y + 1),
        Block.new(x - 2, y + 1),
        Block.new(x - 1, y),
        Block.new(x, y),
      ],
      [
        Block.new(x - 1, y - 1),
        Block.new(x - 1, y - 2),
        Block.new(x, y - 1),
        Block.new(x, y),
      ],
    ]
  end

  def z_tetriminoes(x, y)
    [
      [
        Block.new(x + 1, y - 1),
        Block.new(x, y - 1),
        Block.new(x + 1, y),
        Block.new(x + 2, y),
      ],
      [
        Block.new(x + 1, y + 1),
        Block.new(x + 1, y),
        Block.new(x, y + 1),
        Block.new(x, y + 2),
      ],
      [
        Block.new(x - 1, y + 1),
        Block.new(x, y + 1),
        Block.new(x - 1, y),
        Block.new(x - 2, y),
      ],
      [
        Block.new(x - 1, y - 1),
        Block.new(x - 1, y),
        Block.new(x, y - 1),
        Block.new(x, y - 2),
      ],
    ]
  end

  def j_tetriminoes(x, y)
    [
      [
        Block.new(x + 1, y - 1),
        Block.new(x + 1, y),
        Block.new(x + 1, y + 1),
        Block.new(x, y + 1),
      ],
      [
        Block.new(x + 1, y + 1),
        Block.new(x, y + 1),
        Block.new(x - 1, y + 1),
        Block.new(x - 1, y),
      ],
      [
        Block.new(x - 1, y + 1),
        Block.new(x - 1, y),
        Block.new(x - 1, y - 1),
        Block.new(x, y - 1),
      ],
      [
        Block.new(x - 1, y - 1),
        Block.new(x, y - 1),
        Block.new(x + 1, y - 1),
        Block.new(x + 1, y),
      ],
    ]
  end

  def l_tetriminoes(x, y)
    [
      [
        Block.new(x + 1, y - 1),
        Block.new(x + 1, y),
        Block.new(x + 1, y + 1),
        Block.new(x + 2, y + 1),
      ],
      [
        Block.new(x + 1, y + 1),
        Block.new(x, y + 1),
        Block.new(x - 1, y + 1),
        Block.new(x - 1, y + 2),
      ],
      [
        Block.new(x - 1, y + 1),
        Block.new(x - 1, y),
        Block.new(x - 1, y - 1),
        Block.new(x - 2, y - 1),
      ],
      [
        Block.new(x - 1, y - 1),
        Block.new(x, y - 1),
        Block.new(x + 1, y - 1),
        Block.new(x + 1, y - 2),
      ],
    ]
  end

  def t_tetriminoes(x, y)
    [
      [
        Block.new(x + 1, y - 1),
        Block.new(x + 1, y),
        Block.new(x + 2, y),
        Block.new(x, y),
      ],
      [
        Block.new(x + 1, y + 1),
        Block.new(x, y + 1),
        Block.new(x, y + 2),
        Block.new(x, y),
      ],
      [
        Block.new(x - 1, y + 1),
        Block.new(x - 1, y),
        Block.new(x - 2, y),
        Block.new(x, y),
      ],
      [
        Block.new(x - 1, y - 1),
        Block.new(x, y - 1),
        Block.new(x, y - 2),
        Block.new(x, y),
      ],
    ]
  end
end
