# frozen_string_literal: true

require_relative 'frame'

class Game
  def initialize(marks)
    @frames = parse_frames(marks)
  end

  def score
    @frames.each_with_index.sum do |frame, index|
      frame.score + bonus_score(frame, index)
    end
  end

  def parse_frames(marks)
    frames = []
    current_marks = marks.dup

    9.times do
      first = current_marks.shift
      second = first == 'X' ? nil : current_marks.shift
      frames << Frame.new(first, second)
    end

    frames << Frame.new(*current_marks)
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
      next_frame.first_shot.score + next_frame.second_shot.score
    end
  end
end
