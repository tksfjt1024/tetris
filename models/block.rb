class Block
  attr_reader :x, :y

  def initialize(x, y)
    @x = x
    @y = y
  end

  # dx・dyだけ移動
  def move(dx, dy)
    @x += dx
    @y += dy
  end
end
