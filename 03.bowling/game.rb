# frozen_string_literal: true

require_relative 'frame'
require_relative 'shot'

class Game
  def initialize(marks)
    shots = marks.map { |mark| Shot.new(mark) }
    @frames = create_frames(shots)
  end

  def score
    @frames.sum do |frame|
      frame.score(@frames[frame.index + 1, 2])
    end
  end

  private

  def create_frames(shots)
    current_shots = shots.dup

    10.times.map do |index|
      length =
        if index == 9
          current_shots.size
        else
          current_shots[0].strike? ? 1 : 2
        end
      Frame.new(index, *current_shots.shift(length))
    end
  end
end
