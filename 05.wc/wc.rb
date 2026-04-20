#! /usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'

def main
  options = parse_options
  outputs(options)
  return unless count_input_data.length > 1

  output_count_total(options)
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

def count_input_data
  count_input_data = []

  if ARGV.empty?
    data = $stdin.read
    count_input_data << {
      lines_num: data.split("\n").length.to_s,
      words_num: data.split.length.to_s,
      characters_num: data.bytesize.to_s
    }
  else
    ARGV.each_with_index do |file, index|
      count_input_data << {
        lines_num: File.read(ARGV[index]).count("\n").to_s,
        words_num: File.read(ARGV[index]).split(/\s+/).length.to_s,
        characters_num: File.read(ARGV[index]).length.to_s,
        file_name: file
      }
    end
  end
  count_input_data
end

def count_input_data_total
  lines_num_total = 0
  words_num_total = 0
  characters_num_total = 0

  ARGV.each_with_index do |_file, index|
    lines_num = File.read(ARGV[index]).count("\n")
    words_num = File.read(ARGV[index]).split(/\s+/).length
    characters_num = File.read(ARGV[index]).length
    lines_num_total += lines_num
    characters_num_total += characters_num
    words_num_total += words_num
  end
  {
    lines_num_total: lines_num_total.to_s,
    characters_num_total: characters_num_total.to_s,
    words_num_total: words_num_total.to_s
  }
end

def outputs(options)
  count_input_data.each do |data|
    print data[:lines_num].rjust(8) if options[:l]
    print data[:words_num].rjust(8) if options[:w]
    print data[:characters_num].rjust(8) if options[:c]
    print " #{data[:file_name]}"
    puts
  end
end

def output_count_total(options)
  total_data = count_input_data_total
  print total_data[:lines_num_total].rjust(8) if options[:l]
  print total_data[:words_num_total].rjust(8) if options[:w]
  print total_data[:characters_num_total].rjust(8) if options[:c]
  puts ' total'
end

main
