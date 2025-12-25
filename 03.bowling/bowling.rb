# frozen_string_literal: true

FRAME_THIRD = 3
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

    frames[9].delete(0) if frames[9].count > FRAME_THIRD
    frames[9] << 0 until frames[9].count == FRAME_THIRD
  end
  frames.slice!(FRAME_ELEVENTH, FRAME_TWELFTH)
end
point = frames.each_with_index.sum do |frame, index|
  next frame.sum if index == 9

  if frame[0] == 10 # strike
    next frames[index + 1][0..1].sum + frame.sum unless frames[index + 1][0] == 10

    result = (10 + frame.sum)
    result += index == 8 ? frames[index + 1][1] : frames[index + 2][0]
    next result

  elsif frame.sum == 10 # spare
    next frames[index + 1][0] + frame.sum
  end
  frame.sum
end
puts point
