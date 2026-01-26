#! /usr/bin/env ruby
# frozen_string_literal: true

COL_NUM = 3
SPACE_LENGTH = 5

def main
  files = fetch_files
  files_format = format_files(files)
  output(files_format)
end

def fetch_files
  Dir.glob('*')
end

def format_files(files)
  if !files.empty?
    m = files.size.ceildiv(COL_NUM)
    files_slice = files.each_slice(m).to_a
    max_size = files_slice.map(&:size).max
    files_sort = files_slice.map { |file| file.values_at(0...max_size) }
    files_transpose = files_sort.transpose
    files_transpose.map { |files| files.compact }
  else
    []
  end
end

def spaces_num(files)
  files.map(&:size).max + SPACE_LENGTH
end

def output(files)
  files_fetch = fetch_files
  files.each_with_index do |file, _index|
    file.each do |f|
      print f.ljust(spaces_num(files_fetch))
    end
    puts
  end
end

main
