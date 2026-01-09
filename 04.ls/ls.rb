#! /usr/bin/env ruby
# frozen_string_literal: true

COL_NUM = 3

def files_arrange
  files = Dir.glob('*')
  m = Rational(files.size, COL_NUM).ceil
  max_size = files.map(&:size).max
  files_slice = files.each_slice(m).to_a
  files_sort = files_slice.map { |file| file.values_at(0...max_size) }
  files_sort.transpose
end

def output
  files_arrange.each_with_index do |file, _index|
    file.each do |f|
      print f.ljust(20)
    end
    print "\n"
  rescue StandardError
    print "\n"
    next
  end
end

output
