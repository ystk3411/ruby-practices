# frozen_string_literal: true

require_relative 'shot'

class Frame
  attr_reader :first_shot, :second_shot, :third_shot

  def initialize(first_shot, second_shot = Shot.new(nil), third_shot = Shot.new(nil))
    @first_shot = first_shot
    @second_shot = second_shot
    @third_shot = third_shot
  end

  def score
    [first_shot.score, second_shot.score, third_shot.score].sum
  end

  def strike?
    first_shot.strike?
  end

  def spare?
    !strike? && (first_shot.score + second_shot.score == 10)
  end
end
