# frozen_string_literal: true

class Game
  def initialize(frames)
    @frames = frames
  end

  def score
    point = @frames.each_with_index.sum do |frame, index|
      next frame.sum if index == 9

      frame.sum + bonus(frame, index)
    end
    puts point
  end

  def bonus(frame, index)
    if frame[0] == 10 # strike
      if @frames[index + 1][0] == 10
        result = 10
        result + index == 8 ? @frames[index + 1][1] : @frames[index + 2][0]
      else
        @frames[index + 1][0..1].sum
      end
    elsif frame.sum == 10 # spare
      @frames[index + 1][0]
    else
      0
    end
  end
end
