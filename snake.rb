require 'ruby2d'

set background: 'navy'
set fps_cap: 15

# The window size is 640X480 
# So the width cells are equal to 640 / 20 = 32 
# And the height cells are equal to 480 / 20 = 24 

GRID_SIZE = 20
GRID_WIDTH = Window.width / GRID_SIZE
GRID_HEIGHT = Window.height / GRID_SIZE

SCORE_TEXT_POSITION = [10, 10]
SCORE_TEXT_FONT_SIZE = 25

class GameScore
    def initialize
        @score = 0
        @restarted = false
    end

    def draw
        Text.new(text_message, color: 'green', x: SCORE_TEXT_POSITION[0], y: SCORE_TEXT_POSITION[1], 
                 size: SCORE_TEXT_FONT_SIZE)
    end

    def increase
        @score += 1
    end

    def restart
        @restarted = true
    end

    def was_restarted?
        @restarted
    end

    private
    
    def text_message
        if @restarted
            "Game over, your score was: #{@score}. Press 'N' to restart."
        else
            "Score: #{@score}"
        end
    end
end

class Snake
    attr_writer :direction

    def initialize
        @positions = [[14, 11], [15, 11], [16, 11], [17, 11]]
        @direction = 'right'
        @growing = false 
    end 

    def draw
        @positions.each do |position|
            Square.new(x: position[0] * GRID_SIZE, y: position[1] * GRID_SIZE, 
                       size: GRID_SIZE - 1, color: 'white') # GRID_SIZE - 1 gives an space between each white square
        end
    end

    def move
        if !@growing
            @positions.shift
        end

        case @direction
        when 'up'
            @positions.push(new_coordinates(head[0], head[1] - 1))
        when 'down'
            @positions.push(new_coordinates(head[0], head[1] + 1))
        when 'left'
            @positions.push(new_coordinates(head[0] - 1, head[1]))            
        when 'right'
            @positions.push(new_coordinates(head[0] + 1, head[1]))
        end

        @growing = false
    end

    def can_change_direction_to?(new_direction)
        case @direction
        when 'up' then new_direction != 'down'
        when 'down' then new_direction != 'up'
        when 'left' then new_direction != 'right'        
        when 'right' then new_direction != 'left'
        end
    end

    def x
        head[0]
    end

    def y
        head[1]
    end

    def grow
        @growing = true
    end

    def hit_itself?
        @positions.length != @positions.uniq.length
    end

    private

    def head
        @positions.last
    end

    def new_coordinates(x, y)
        [x % GRID_WIDTH, y % GRID_HEIGHT]
    end 
end

class Ball
    def initialize
        @ball_x = rand(GRID_WIDTH)
        @ball_y = rand(GRID_HEIGHT)
    end

    def draw
        Square.new(x: @ball_x * GRID_SIZE, y: @ball_y * GRID_SIZE, size: GRID_SIZE - 1, color: 'yellow')
    end

    def hide
        Square.new(x: @ball_x * GRID_SIZE, y: @ball_y * GRID_SIZE, size: GRID_SIZE - 1, color: 'navy')
    end

    def was_eaten?(snake_pos_x, snake_pos_y)
        @ball_x == snake_pos_x && @ball_y == snake_pos_y
    end
end

game_score = GameScore.new
snake = Snake.new
ball = Ball.new

update do
    clear

    unless game_score.was_restarted?
        snake.move
    end

    game_score.draw 
    snake.draw
    ball.draw

    if snake.hit_itself?
        ball.hide
        game_score.restart
    end

    if ball.was_eaten?(snake.x, snake.y)
        game_score.increase
        snake.grow
        ball = Ball.new
    end
end

on :key_down do |event|
    if ['down', 'up', 'left', 'right'].include?(event.key)
        if snake.can_change_direction_to?(event.key)
            snake.direction = event.key
        end
    elsif game_score.was_restarted? && event.key == 'n' # You can restart only if you lossed
        game_score = GameScore.new
        snake = Snake.new
        ball = Ball.new
    end
end

show