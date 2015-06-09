class Square
  def initialize(a)
    @a = a
  end
  def area
    @a ** 2
  end
  def p
    @a * 4
  end
end
class Rectangle
  def initialize(a, b)
    @a, @b = [a, b]
  end
  def area
    @a * @b
  end
  def p
    (2 * @a) + (2 * @b)
  end
end
