class Maze
  def empty(m, n)
    @the_maze = ""
    (0..@height*2).each do |k|
      (0..@width*2).each do |j|
        if k == 0 || k == @height*2
          @the_maze += "1"
        elsif j == 0 || j == @width*2
          @the_maze += "1"
        else
          @the_maze += "0"
        end
      end
    end
  end

  def initialize(m, n)
    @width = m
    @height = n
    self.empty(m, n)
  end

  def load(arg)
    @the_maze = arg.to_s.chomp
    @width = (@the_maze.index("0") - 2) / 2
    @height  = (@the_maze.length / (@width*2+1) - 1) / 2
    #the index of first "0" indicates the first cell hence the width
   end

  def display
    i = 0
    (0..@height*2).each do |j|
      (0..@width*2).each do |k|
        if j % 2 == 0
          if @the_maze[i] == "1"
            if k % 2 == 0
              print "+"
            else
              print "-"
            end
          else
            print " "
          end
        else
          if @the_maze[i] == "1"
            print "|"
          else
            print " "
          end
        end
        i += 1
      end
      print "\n"
    end
  end

    def up(x, y)
      return (x*2 + 1)+(y*2*(@width*2+1))
    end
    def down(x, y)
      return (x*2 + 1)+((y+1)*2*(@width*2+1))
    end
    def left(x, y)
      return (x*2)+((y*2+1)*(@width*2+1))
    end
    def right(x, y)
      return (x+1)*2+((y*2+1)*(@width*2+1))
    end

  def connected?(bx, by, ex, ey)
    if by == ey && (bx - ex).abs == 1
      return @the_maze[left([bx, ex].max, by)] == "0"
    elsif bx == ex && (by - ey).abs == 1
      return @the_maze[up(bx, [by, ey].max)] == "0"
    else
      return false
    end
  end

  def adjacents(x, y)
    return [[x+1, y], [x-1, y], [x, y+1], [x, y-1]]
  end

  def solve_core(bX, bY, eX, eY, bfs_q, trace)
    #implemented with breadth first search
    trace.push([bX, bY])

    if bX == eX && bY == eY
      @route = trace
      @result =  true

    else
      before = bfs_q.length
      adjacents(bX, bY).each do |cell|
        tx = cell.first
        ty = cell.last
        if tx < @width && tx >= 0 && ty < @height && ty >= 0 && !bfs_q.include?([tx, ty]) && self.connected?(bX, bY, tx, ty)
            bfs_q.push([tx, ty])
            self.solve_core(tx, ty,  eX, eY, bfs_q, Array.new(trace))
        end
      end

    end
  end

  def solve(bX, bY, eX, eY)
    @result = false
    @route = Array.new
    self.solve_core(bX, bY, eX, eY, [], [])
    return @result
  end

  def trace(bX, bY, eX, eY)
    @result = false
    @route = Array.new
    self.solve_core(bX, bY, eX, eY, [], [])
    return @route
  end

  def find_neighbor(cell)
    tmp = []
    #print cell
    adjacents(cell.first, cell.last).each do |c|
      #puts cell.first, mask[i].first.class
      tx = c.first
      ty = c.last
      if connected?(tx, ty, cell.first, cell.last) && !@path.include?([tx, ty])
        tmp.push([tx, ty])
      end
    end

    if tmp.empty?
      return nil
    else
      return tmp[rand(tmp.length)]
    end
  end

  def corners(x, y)
    return [x*2+(y*2*(@width*2+1)),
            x*2+(y+1)*2*(@width*2+1),
            (x+1)*2+(y*2*(@width*2+1)),
            (x+1)*2+(y+1)*2*(@width*2+1)]
  end
  def shared_wall(x, y)
    if @path.first != [x, y]
      neighbor = @path.fetch(@path.index([x, y])-1)
      if [x, y].last == neighbor.last
        return left([x, neighbor.first].max, y)
      else
        return up(x, [y, neighbor.last].max)
      end
    else
      return -1
    end
  end

  def create_walls(x, y)
    @the_maze[up(x, y)] = "1"
    @the_maze[down(x, y)] = "1"
    @the_maze[left(x, y)] = "1"
    @the_maze[right(x, y)] = "1"

    corners(x, y).each do |i|
      @the_maze[i] = "1"
    end

    if shared_wall(x, y) > 0
      @the_maze[shared_wall(x, y)] = "0"
    end

  end

  def redesign
    init_cell = [rand(@width), rand(@height)]
    @path =[init_cell]

    k = @width * @height
    max_path_len = rand(k/2..k)
    while @path.length < max_path_len
      next_cell = find_neighbor(@path.last)
      if next_cell != nil
        @path.push(next_cell)
      else
        break
      end
    end

    self.empty(@width, @height)

    @path.each do |cell|
      create_walls(cell.first, cell.last)
    end
    puts "redisigned maze is :"
    display
  end

end

maze = Maze.new(4, 5)
maze.load("111111111100010001111010101100010101101110101100000101111011101100000101111111111")
puts "display the loaded maze: "
maze.display
puts "solve(0, 2, 3, 0): "
puts maze.solve(0, 2, 3, 0)
puts "trace(0, 2, 3, 0): "
print maze.trace(0, 2, 3, 0), "\n"
puts "display the redisigned maze: "
maze.redesign
