#! /usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

COL_NUM = 3
SPACE_LENGTH = 5

def main
  options = parse_option
  files = fetch_files(options)
  files_format = format_files(files)
  offset_length = spaces_num(files)
  output(files_format, offset_length)
end

def parse_option
  options = {}
  opt = OptionParser.new
  opt.on('-a') { |_v| options[:a] = true }
  opt.on('-r') { |_v| options[:r] = true }
  opt.parse!(ARGV)
  options
end

def fetch_files(options)
  flags = options[:a] ? File::FNM_DOTMATCH : 0
  filenames = Dir.glob('*', flags)
  filenames.reverse! if options[:r]
  filenames
end

def format_files(files)
  return [] if files.empty?

  m = files.size.ceildiv(COL_NUM)
  files_slice = files.each_slice(m).to_a
  max_size = files_slice.map(&:size).max
  files_sort = files_slice.map { |file| file.values_at(0...max_size) }
  files_transpose = files_sort.transpose
  files_transpose.map(&:compact)
end

def spaces_num(files)
  files.map(&:size).max + SPACE_LENGTH
end

def output(files, offset_length)
  files.each_with_index do |file, _index|
    file.each do |f|
      print f.ljust(offset_length)
    end
    puts
  end
end

main
