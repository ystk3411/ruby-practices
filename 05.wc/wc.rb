#! /usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'

def main
  counted_file_info_list = calc_counted_file_info_list

  counted_file_info_list.each do |file_info|
    outputs(file_info)
  end

  return if ARGV.length <= 1

  total_num_list = calc_total_file_info(counted_file_info_list)
  outputs(total_num_list)
end

def calc_counted_file_info_list
  options = parse_options
  counted_file_info_list = []
  if ARGV.empty?
    input_file_info = $stdin.read
    counted_file_info_list << count_input_file_info(input_file_info, options)
  else
    ARGV.each do |file_name|
      input_file_info = File.read(file_name)
      counted_input_file_info = count_input_file_info(input_file_info, options)
      counted_input_file_info[:file_name] = file_name
      counted_file_info_list << counted_input_file_info
    end
  end
  counted_file_info_list
end

def parse_options
  options = {}
  opt = OptionParser.new
  opt.on('-l') { options[:l] = true }
  opt.on('-w') { options[:w] = true }
  opt.on('-c') { options[:c] = true }
  opt.parse!(ARGV)
  options = { l: true, w: true, c: true } if options.empty?
  options
end

def count_input_file_info(input_file_info, options)
  lines = input_file_info.count("\n").to_s if options[:l]
  words = input_file_info.split(/\s+/).length.to_s if options[:w]
  characters = input_file_info.length.to_s if options[:c]
  {
    lines: lines,
    words: words,
    characters: characters
  }.compact
end

def outputs(file_info)
  file_info.each do |key, file_info_num|
    if %i[file_name text].include?(key)
      print " #{file_info_num}"
    else
      print right_justify(file_info_num)
    end
  end
  puts
end

def right_justify(text)
  text.is_a?(String) ? text.rjust(8) : text.to_s.rjust(8)
end

def calc_total_file_info(file_info_list)
  lines_total = 0
  words_total = 0
  characters_total = 0

  file_info_list.each do |file_info|
    lines_total += file_info[:lines].to_i
    words_total += file_info[:words].to_i
    characters_total += file_info[:characters].to_i
  end

  total_num_list = {
    lines: lines_total,
    words: words_total,
    characters: characters_total
  }

  total_num_list.delete_if { |_key, value| value.zero? }
  total_num_list[:text] = 'total'
  total_num_list
end

main
