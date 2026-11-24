# frozen_string_literal: true

require_relative 'game'

class Main
  def self.run
    marks = ARGV[0].split(',')

    game = Game.new(marks)
    puts game.score
  end
end

Main.run
