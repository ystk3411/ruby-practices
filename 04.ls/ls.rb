#! /usr/bin/env ruby
# frozen_string_literal: true

COL_NUM = 3

def transpose_files
  files = Dir.glob('*')
  max_size = files.map(&:size).max
  files_sort = sort_files(files).map { |file| file.values_at(0...max_size) }
  files_sort.transpose
end

def sort_files(files)
  m = files.size.ceildiv(COL_NUM)
  files_slice = files.each_slice(m).to_a
end

def output
  arrange_files.each_with_index do |file, _index|
    file.each do |f|
      if !f.nil?
        multiplier = 0
        if f.length > 20
          multiplier = f.length.ceildiv(20)
          print f.ljust(20 * multiplier)
        else
          print f.ljust(20)
        end
      end
    end
    puts
  end
end

output
