# frozen_string_literal: true

require_relative 'shot'

class Frame
  attr_reader :index, :shots

  def initialize(index, *shots)
    @index = index
    @shots = shots
  end

  def score(next_frame = nil, after_next_frame = nil)
    base_score + bonus_score(next_frame, after_next_frame)
  end

  def strike?
    first_shot.strike?
  end

  def spare?
    !strike? && (first_shot.score + second_shot.score == 10)
  end

  def first_shot
    @shots[0]
  end

  def second_shot
    @shots[1]
  end

  private

  def last_frame?
    index == 9
  end

  def base_score
    @shots.sum(&:score)
  end

  def bonus_score(next_frame, after_next_frame)
    return 0 if last_frame?

    if strike?
      strike_bonus(next_frame, after_next_frame)
    elsif spare?
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
