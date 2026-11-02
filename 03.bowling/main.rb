# frozen_string_literal: true

require_relative 'shot'
require_relative 'frame'
require_relative 'game'

class Main
  def self.run
    marks = gets.chomp.split(',')
    shot = Shot.new(marks).score
    frame = Frame.new(shot)
    frame.arrange_frames
    Game.new(frame.frames).score
  end
end

Main.run
