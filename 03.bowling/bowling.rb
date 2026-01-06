# frozen_string_literal: true

FRAME_LAST_THROW = 3
FRAME_TENTH = 9
FRAME_ELEVENTH = 10
FRAME_TWELFTH = 11

scores = gets.chomp.split(',')
shots = scores.flat_map do |score|
  score == 'X' ? [10, 0] : score.to_i
end

frames = shots.each_slice(2).to_a
if frames.count >= FRAME_TWELFTH
  frames[9].push(frames.values_at(FRAME_ELEVENTH, FRAME_TWELFTH)).flatten!
  frames[9].compact!

  if frames[9][0] == 10

    frames[9].delete(0) if frames[9].count > FRAME_LAST_THROW
    frames[9] << 0 until frames[9].count == FRAME_LAST_THROW
  end
  frames.slice!(FRAME_ELEVENTH, FRAME_TWELFTH)
end
point = frames.each_with_index.sum do |frame, index|
  next frame.sum if index == 9

  frame.sum + if frame[0] == 10 # strike
                if frames[index + 1][0] == 10
                  result = 10
                  result += index == 8 ? frames[index + 1][1] : frames[index + 2][0]
                else
                  frames[index + 1][0..1].sum
                end
              elsif frame.sum == 10 # spare
                frames[index + 1][0]
              else
                0
              end
end
puts point
