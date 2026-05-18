#! /usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'

def main
  file_info_list = build_file_info_list

  file_info_list.each do |file_info|
    output(file_info)
  end

  return if ARGV.length <= 1

  total_info = calc_total(file_info_list)
  output(total_info)
end

def build_file_info_list
  options = parse_options
  file_info_list = []
  if ARGV.empty?
    text = $stdin.read
    file_info_list << count_input_file_info(text, options)
  else
    ARGV.each do |file_name|
      text = File.read(file_name)
      file_info_list << count_input_file_info(text, options, file_name)
    end
  end
  file_info_list
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

def count_input_file_info(text, options, file_name = nil)
  file_info = {}
  file_info[:lines] = text.count("\n") if options[:l]
  file_info[:words] = text.split(/\s+/).length if options[:w]
  file_info[:characters] = text.length if options[:c]
  file_info[:file_name] = file_name if !file_name.nil?
  file_info.compact
end

def output(file_info)
  custom_order = [:lines, :words, :characters, :file_name]
  file_info_sorted = file_info.slice(*custom_order)

  file_info_sorted.each do |key, file_info_num|
    if %i[file_name text].include?(key)
      print " #{file_info_num}"
    else
      print file_info_num.to_s.rjust(8)
    end
  end
  puts
end

def calc_total(file_info_list)
  total_num_list = {
    lines: 0,
    words: 0,
    characters: 0,
    file_name: ""
  }

  file_info_list.each do |file_info|
    file_info.each do |key, value|
      total_num_list.delete_if{|key| }
      if key == :file_name
        next
      end
      total_num_list[key] += value
    end
  end

  total_num_list.delete_if { |key, value| !(file_info_list[0].key?(key)) }
  total_num_list[:file_name] = 'total'
  total_num_list
end

main
