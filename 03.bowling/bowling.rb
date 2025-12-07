# frozen_string_literal: true

scores = gets.chomp.split(',')
shots = []
scores.each do |s|
  if s == 'X'
    shots << 10
    shots << 0
  else
    shots << s.to_i
  end
end

frames = shots.each_slice(2).to_a
if frames.count >= 11
  frames[9].push(frames[10]).flatten! unless frames[10].nil?
  frames[9].push(frames[11]).flatten! unless frames[11].nil?
  if frames[9][0] == 10
    frames[9].delete(nil)
    frames[9].delete(0) if frames[9].count > 3
    frames[9] << 0 until frames[9].count == 3
  end
  frames.slice!(10, 11)
end

point = 0
frames.each_with_index do |frame, index|
  if frame[0] == 10 # strike
    point += 10
    if index == 8
      if frames[index + 1][0] == 10
        point += (10 + frames[index + 1][1])
        next
      end
      point += (frames[index + 1][0] + frames[index + 1][1])
      next
    end
    if index == 9
      point += (frame[1] + frame[2])
      next
    end
    if frames[index + 1][0] == 10
      point += 10
      if frames[index + 1] == 9
        point += (frames[index + 1][1] + frames[index + 1][2])
        next
      end
      point += if frames[index + 2][0] == 10
                 10
               else
                 frames[index + 2][0]
               end
    else
      point += (frames[index + 1][0] + frames[index + 1][1])
    end
  elsif frame.sum == 10 # spare
    point += 10
    if !frames[index + 1].nil? && !frames[index + 2].nil?
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
