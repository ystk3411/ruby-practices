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
      frame.score(@frames[frame.index + 1], @frames[frame.index + 2])
    end
  end

  private

  def create_frames(shots)
    current_shots = shots.dup

    frames = 9.times.map do |index|
      first_shot = current_shots.shift
      if first_shot.strike?
        Frame.new(index, first_shot)
      else
        second_shot = current_shots.shift
        Frame.new(index, first_shot, second_shot)
      end
    end

    frames << Frame.new(9, *current_shots)
  end
end
