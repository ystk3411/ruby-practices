#! /usr/bin/env ruby
# frozen_string_literal: true

COL_NUM = 3
SPACE_LENGTH = 20

def main
  files = fetch_files
  files_sort = sort_files(files)
  transpose_files(files_sort)
end

def fetch_files
  Dir.glob('*')
end

def sort_files(files)
  m = files.size.ceildiv(COL_NUM)
  files_slice = files.each_slice(m).to_a
  max_size = files_slice.map(&:size).max
  files_slice.map { |file| file.values_at(0...max_size) }
end

def transpose_files(files)
  files_transpose = files.transpose
  files_transpose.map { |files| files.compact }
end

def output
  main.each_with_index do |file, _index|
    file.each do |f|
      if !f.nil?
        multiplier = 0
        if f.length > SPACE_LENGTH
          multiplier = f.length.ceildiv(SPACE_LENGTH)
          print f.ljust(SPACE_LENGTH * multiplier)
        else
          print f.ljust(SPACE_LENGTH)
        end
      end
    end
    puts
  end
end

output
