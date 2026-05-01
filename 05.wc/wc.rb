#! /usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'

def main
  options = parse_options
  output(options)
end

def parse_options
  options = {}
  opt = OptionParser.new
  opt.on('-l') { |_v| options[:l] = true }
  opt.on('-w') { |_v| options[:w] = true }
  opt.on('-c') { |_v| options[:c] = true }
  opt.parse!(ARGV)
  options = { l: true, w: true, c: true } if options.empty?
  options
end

def output(options)
  counted_file_info_list = calc_counted_file_info_list

  counted_file_info_list.each do |file_info|
    print file_info[:lines].rjust(8) if options[:l]
    print file_info[:words].rjust(8) if options[:w]
    print file_info[:characters].rjust(8) if options[:c]
    print " #{file_info[:file_name]}"
    puts
  end

  return unless ARGV.length > 1

  total_data = count_input_file_info_total(options)
  print total_data[:lines_total].rjust(8)
  print total_data[:words_total].rjust(8)
  print total_data[:characters_total].rjust(8)
  puts ' total'
end

def calc_counted_file_info_list
  counted_file_info_list = []
  if ARGV.empty?
    input_file_info = $stdin.read
    counted_file_info_list << count_input_file_info(input_file_info)
  else
    ARGV.each do |file_name|
      input_file_info = File.read(file_name)
      counted_input_file_info = count_input_file_info(input_file_info)
      counted_input_file_info[:file_name] = file_name
      counted_file_info_list << counted_input_file_info
    end
  end
  counted_file_info_list
end

def count_input_file_info_total(options)
  lines_total = 0
  words_total = 0
  characters_total = 0

  ARGV.each_with_index do |file_name, index|
    file = File.read(file_name)
    lines = file.count("\n")
    words = file.split(/\s+/).length
    characters = file.length
    lines_total += lines
    characters_total += characters
    words_total += words
  end
  counted_input_file_info_total = {}
  counted_input_file_info_total[:lines_total] = lines_total.to_s if options[:l]
  counted_input_file_info_total[:characters_total] = characters_total.to_s if options[:w]
  counted_input_file_info_total[:words_total] = words_total.to_s if options[:c]
  counted_input_file_info_total
end

def count_input_file_info(input_file_info)
  {
    lines: input_file_info.count("\n").to_s,
    words: input_file_info.split(/\s+/).length.to_s,
    characters: input_file_info.length.to_s
  }
end

main
