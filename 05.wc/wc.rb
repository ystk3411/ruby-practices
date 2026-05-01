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
  counted_datas = calc_counted_datas

  counted_datas.each do |counted_data|
    print counted_data[:lines].rjust(8) if options[:l]
    print counted_data[:words].rjust(8) if options[:w]
    print counted_data[:characters].rjust(8) if options[:c]
    print " #{counted_data[:file_name]}"
    puts
  end

  return unless ARGV.length > 1

  total_data = count_input_data_total(options)
  print total_data[:lines_total].rjust(8)
  print total_data[:words_total].rjust(8)
  print total_data[:characters_total].rjust(8)
  puts ' total'
end

def calc_counted_datas
  counted_datas = []
  if ARGV.empty?
    input_data = $stdin.read
    counted_datas << count_input_data(input_data)
  else
    ARGV.each_with_index do |file_name, index|
      input_data = File.read(ARGV[index])
      counted_datas << count_input_data(input_data)
      counted_datas[index][:file_name] = file_name
    end
  end
  counted_datas
end

def count_input_data_total(options)
  lines_total = 0
  words_total = 0
  characters_total = 0

  ARGV.each_with_index do |_file_name, index|
    file = File.read(ARGV[index])
    lines = file.count("\n")
    words = file.split(/\s+/).length
    characters = file.length
    lines_total += lines
    characters_total += characters
    words_total += words
  end
  counted_input_data_total = {}
  counted_input_data_total[:lines_total] = lines_total.to_s if options[:l]
  counted_input_data_total[:characters_total] = characters_total.to_s if options[:w]
  counted_input_data_total[:words_total] = words_total.to_s if options[:c]
  counted_input_data_total
end

def count_input_data(input_data)
  {
    lines: input_data.count("\n").to_s,
    words: input_data.split(/\s+/).length.to_s,
    characters: input_data.length.to_s
  }
end

main
