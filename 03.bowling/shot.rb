# frozen_string_literal: true

class Shot
  def initialize(marks)
    @marks = marks
  end

  def score
    @marks.flat_map do |score|
      score == 'X' ? [10, 0] : score.to_i
    end
  end
end
