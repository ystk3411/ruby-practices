#! /usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'

def main
  options = parse_option
  if ARGV.empty?
    data = $stdin.read
    output_pipeline(data, options)
  elsif ARGV.length == 1
    output(options)
  else
    output_plural_files(options)
  end
end

def parse_option
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
  lines_num = File.read(ARGV[0]).count("\n").to_s
  words_num = File.read(ARGV[0]).split(/\s+/).length.to_s
  characters_num = File.read(ARGV[0]).length.to_s
  print lines_num.rjust(8) if options[:l]
  print words_num.rjust(8) if options[:w]
  print characters_num.rjust(8) if options[:c]
  puts " #{ARGV[0]}"
end

def output_plural_files(options)
  lines_num_total = 0
  words_num_total = 0
  characters_num_total = 0

  ARGV.each_with_index do |file, index|
    lines_num = File.read(ARGV[index]).count("\n")
    words_num = File.read(ARGV[index]).split(/\s+/).length
    characters_num = File.read(ARGV[index]).length
    lines_num_total += lines_num
    characters_num_total += characters_num
    words_num_total += words_num
    print lines_num.to_s.rjust(8) if options[:l]
    print words_num.to_s.rjust(8) if options[:w]
    print characters_num.to_s.rjust(8) if options[:c]
    print " #{file}"
    puts
  end
  print lines_num_total.to_s.rjust(8) if options[:l]
  print words_num_total.to_s.rjust(8) if options[:w]
  print characters_num_total.to_s.rjust(8) if options[:c]
  puts ' total'
end

def output_pipeline(data, options)
  lines_num = data.split("\n").length
  words_num = data.split.length
  characters_num = data.bytesize
  print lines_num.to_s.rjust(8) if options[:l]
  print words_num.to_s.rjust(8) if options[:w]
  print characters_num.to_s.rjust(8) if options[:c]
  puts
end

main
