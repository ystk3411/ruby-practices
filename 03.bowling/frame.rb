# frozen_string_literal: true

class Frame
  attr_reader :frames

  FRAME_LAST_THROW = 3
  FRAME_ELEVENTH = 10
  FRAME_TWELFTH = 11

  def initialize(shot)
    @frames = shot.each_slice(2).to_a
  end

  def arrange_frames
    return unless @frames.count >= FRAME_TWELFTH

    @frames[9].push(@frames.values_at(FRAME_ELEVENTH, FRAME_TWELFTH)).flatten!
    @frames[9].compact!

    if @frames[9][0] == 10

      @frames[9].delete(0) if @frames[9].count > FRAME_LAST_THROW
      @frames[9] << 0 until @frames[9].count == FRAME_LAST_THROW
    end
    @frames.slice!(FRAME_ELEVENTH, FRAME_TWELFTH)
  end
end
