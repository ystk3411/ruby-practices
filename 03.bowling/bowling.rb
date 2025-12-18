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

point = 0
frames.each_with_index do |frame, index|
  if index == 9
    point += frame.sum
    next
  end
  if frame[0] == 10 # strike
    point += 10
    if index == 8 && frames[index + 1][0] == 10
      point += (10 + frames[index + 1][1])
      next
    end
    if frames[index + 1][0] == 10
      point += 10
      if frames[index + 1] == 9
        point += frames[index + 1][1..2].sum
        next
      end
      point += frames[index + 2][0]
    else
      point += frames[index + 1][0..1].sum
    end
  elsif frame.sum == 10 # spare
    point += 10
    if !frames[index + 1].nil?
      point += if frames[index + 1][0] == 10
                 10
               else
                 frames[index + 1][0]
               end
    end
  else
    point += frame.sum
  end
end
puts point
