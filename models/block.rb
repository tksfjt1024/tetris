class Block
  def initialize(x, y)
    @x = x
    @y = y
  end

  def x
    @x
  end

  def y
    @y
  end

  # dx・dyだけ移動
  def move(dx, dy)
    @x += dx
    @y += dy
  end
end
