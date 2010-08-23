#!/usr/bin/ruby1.9 -Ku

###########################################
# GDD 2010 fall DevQuiz Question3 PAC-MAN #
# TAC <tac@tac42.net>                     #
###########################################

class Unit
  attr_accessor :ch,:x,:y
  def initialize(x,y,ch)
    @ch,@x,@y = ch,x,y
  end

  def set_map(map)
    @map = map
  end

  def loc
    [@x,@y]
  end
end


class Player < Unit

  attr_reader :log

  def initialize(x,y,ch)
    super(x,y,ch)
    @log = ""
  end

  def mov(command)
    table = { 'h' => [-1,0], 'j' => [0,1], 'k'=>[0,-1], 'l'=>[1,0],'.'=>[0,0]}
    dx,dy = table[command]
    
    @x += dx
    @y += dy

    @log << command

    if @map[@y][@x] == '.'      
      @map[@y][@x] = ' '
      return 1
    end
    return 0
  end
end


class Enemy < Unit

  #次に移動する方向 :next
  attr_accessor :next

  #playerをセット
  def set_player(p)
    @player = p
  end

  def set_map(map)
    super(map)
    #最初に移動する方向を計算してやる
    #下左上右の順
    @next = 
      if  @map[@y+1][@x] != '#'
        [0,1]
      elsif @map[@y][@x-1] != '#'
        [-1,0]
      elsif @map[@y-1][@x] != '#'
        [0,-1]
      else
        [1,0]
      end
  end
    

  def mov()
    
    @x += @next[0]
    @y += @next[1]
        
    #次のマスの種類によって挙動を変える
    s = []

    #下左上右の順
    [[0,1],[-1,0],[0,-1],[1,0]].each { |dx,dy| s << [dx,dy] if @map[@y+dy][@x+dx] != '#'}
    @next = 
      case s.size
      when 1 #行き止まりマス
        s.pop
      when 2 #通路マス
        s.reject{|r| r == @next.map{|d|d*=-1}}.pop
      else
        mov_cross(@next,s)
      end
    
  end

  def mov_cross(prev,s) #交差点マスでの挙動
    puts p
    return [0,0]
  end

end

class EnemyV < Enemy
  def mov_cross(prev,dir)
    px,py = @player.loc
    dx,dy = px-@x,py-@y

    ddx = dx>0?1:-1
    ddy = dy>0?1:-1

    if dy != 0 && @map[@y+ddy][@x] != '#'
      [0,ddy]
    elsif dx != 0 && @map[@y][@x+ddx] != '#'
      [ddx,0]
    else
      dir.shift
    end
  end
end

class EnemyH < Enemy
  def mov_cross(prev,dir)

    px,py = @player.loc
    dx,dy = px-@x,py-@y

    ddx = dx>0?1:-1
    ddy = dy>0?1:-1

    if dx != 0 && @map[@y][@x+ddx] != '#'
      [ddx,0]
    elsif dy != 0 && @map[@y+ddy][@x] != '#'
      [0,ddy]    
    else
      dir.shift
    end
  end
end

class EnemyL < Enemy
  def mov_cross(prev,dir)
    dx,dy = prev
    table = [[dy,-dx],[dx,dy],[-dy,dx]]
    table.each{ |ddx,ddy| return [ddx,ddy] if @map[@y+ddy][@x+ddx] != '#' }
    puts "ERROR"
    return nil
  end
end

class EnemyR < Enemy
  def mov_cross(prev,dir)
    dx,dy = prev
    table = [[-dy,dx],[dx,dy],[dy,-dx]]
    table.each{ |ddx,ddy| return [ddx,ddy] if @map[@y+ddy][@x+ddx] != '#' }
    puts "ERROR"
    return nil
  end
end

class EnemyJ < Enemy

  def initialize(x,y,ch)
    super(x,y,ch)
    @left = true #はじめはLの行動
  end

  def mov_cross(prev,dir)
    dx,dy = prev

    table = if @left
              @ch = '>'
              [[dy,-dx],[dx,dy],[-dy,dx]]
            else
              @ch = '<'
              [[-dy,dx],[dx,dy],[dy,-dx]]
            end
    @left = !@left
    table.each{ |ddx,ddy| return [ddx,ddy] if @map[@y+ddy][@x+ddx] != '#' }

    puts "ERROR"
    return nil
  end
end

# Game has Units,Map,Score and Time
class Game

  def initialize(player,enemy,map,score=0,time=0,init=nil)
    @player,@enemy,@map,@score,@time = player,enemy,map,score,time
    @log = []
    mov(init.chomp) if init
  end

  def show_status(flag = false)
    puts "time  = #{@time}/#{TIME_LIMIT}"
    puts "score = #{@score}"
    puts "> #{@player.log}"
    m = Marshal.load(Marshal.dump(@map))
    x,y = @player.loc
    m[y][x] = @player.ch
    @enemy.each do |e|
      x,y = e.loc
      table = { [-1,0] => 'h', [0,1] => 'j', [0,-1] => 'k', [1,0]=>'l'}
      m[y][x] = table[e.next]
      m[y][x] = e.ch if flag
    end
    puts m
  end

  def mov(command)

    command.split(//).each do |c|

      if c == 's'
        show_status(true)
      end

      #for emacser
      c = c.tr("bnpf","hjkl")

      if %W|h j k l .|.include?(c)
        @score += @player.mov(c)
        @enemy.each{ |e| e.mov}
        @time += 1
      end

    end

  end

end

##### START #####
INPUT_FILE = "input01.txt"
#INPUT_FILE = "input02.txt"
#INPUT_FILE = "input03.txt"

input_data = File.read(INPUT_FILE).split("\n")

TIME_LIMIT = input_data.shift.to_i
width,height = input_data.shift.split(" ").map{|s| s.to_i}

# ユニット生成
enemy = []
player = nil

map = []
input_data.each_with_index do |l,y|
  line =  l.split(//)
  x=0
  line.map! do |c|
    u,c = case c
          when 'V' 
            [EnemyV.new(x,y,c),' ']
          when 'H' 
            [EnemyH.new(x,y,c),' ']
          when 'L' 
            [EnemyL.new(x,y,c),' ']
          when 'R' 
            [EnemyR.new(x,y,c),' ']
          when 'J' 
            [EnemyJ.new(x,y,c),' ']
          when '@'
            player = Player.new(x,y,c)
            [nil,' ']
          else [nil,c]
          end
    enemy << u if u
    x += 1
    c
  end
  map << line.join("")
end

#mapをセット
player.set_map(map)
enemy.each{ |e| e.set_player(player); e.set_map(map)}

game = Game.new(player,enemy,map,0,0,ARGV[0])
game.show_status

#ゲーム開始
loop do
  puts "← ↓ ↑ →"
  puts "h j k l"
  command = STDIN.gets.chomp

  game.mov(command)
  game.show_status  
end
