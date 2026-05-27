#! /usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'

def main
  options = parse_options
  file_info_list = build_file_info_list

  file_info_list.each do |file_info|
    output(file_info, options)
  end

  return if ARGV.length <= 1

  total_info = calc_total(file_info_list)
  output(total_info, options)
end

def build_file_info_list
  if ARGV.empty?
    text = $stdin.read
    [count_input_file_info(text)]
  else
    ARGV.map do |file_name|
      text = File.read(file_name)
      count_input_file_info(text, file_name)
    end
  end
end

def parse_options
  options = {}
  opt = OptionParser.new
  opt.on('-l') { options[:lines] = true }
  opt.on('-w') { options[:words] = true }
  opt.on('-c') { options[:bytesize] = true }
  opt.parse!(ARGV)
  options = { lines: true, words: true, bytesize: true } if options.empty?
  options
end

def count_input_file_info(text, file_name = nil)
  {
    lines: text.count("\n"),
    words: text.split(/\s+/).length,
    bytesize: text.bytesize,
    file_name: file_name
  }
end

def output(file_info, options)
  %i[lines words bytesize].each do |key|
    print file_info[key].to_s.rjust(8) if options[key]
  end
  print " #{file_info[:file_name]}"
  puts
end

def calc_total(file_info_list)
  total_num_list = {
    lines: 0,
    words: 0,
    bytesize: 0,
    file_name: 'total'
  }

  file_info_list.each do |file_info|
    file_info.except(:file_name).each do |key, value|
      total_num_list[key] += value
    end
  end

  total_num_list
end

main
