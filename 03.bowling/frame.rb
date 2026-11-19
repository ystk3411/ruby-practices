# frozen_string_literal: true

require_relative 'shot'

class Frame
  attr_reader :shots

  def initialize(*shots)
    @shots = shots
  end

  def score
    @shots.sum(&:score)
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
end
