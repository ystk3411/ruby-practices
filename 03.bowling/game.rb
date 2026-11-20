# frozen_string_literal: true

require_relative 'frame'
require_relative 'shot'

class Game
  def initialize(marks)
    shots = marks.map { |mark| Shot.new(mark) }
    @frames = create_frames(shots)
  end

  def score
    @frames.each_with_index.sum do |frame, index|
      frame.score + bonus_score(frame, index)
    end
  end

  private

  def create_frames(shots)
    frames = []
    current_shots = shots.dup

    9.times do
      first_shot = current_shots.shift
      if first_shot.strike?
        frames << Frame.new(first_shot)
      else
        second_shot = current_shots.shift
        frames << Frame.new(first_shot, second_shot)
      end
    end

    frames << Frame.new(*current_shots)
    frames
  end

  def bonus_score(frame, index)
    return 0 if index == 9

    next_frame = @frames[index + 1]
    after_next_frame = @frames[index + 2]

    if frame.strike?
      strike_bonus(next_frame, after_next_frame)
    elsif frame.spare?
      next_frame.first_shot.score
    else
      0
    end
  end

  def strike_bonus(next_frame, after_next_frame)
    if next_frame.strike? && after_next_frame
      next_frame.first_shot.score + after_next_frame.first_shot.score
    else
      next_frame.first_shot.score + next_frame.second_shot&.score.to_i
    end
  end
end
