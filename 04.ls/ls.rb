#! /usr/bin/env ruby
# frozen_string_literal: true

COL_NUM = 3

def main
  files = fetch_files
  files_sort = sort_files(files)
  transpose_files(files_sort)
end

def fetch_files
  Dir.glob('*')
end

def sort_files(files)
  max_size = files.map(&:size).max
  m = files.size.ceildiv(COL_NUM)
  files_slice = files.each_slice(m).to_a
  files_slice.map { |file| file.values_at(0...max_size) }
end

def transpose_files(files)
  files.transpose
end

def output
  main.each_with_index do |file, _index|
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
