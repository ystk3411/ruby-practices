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
  file_info_list = []
  if ARGV.empty?
    text = $stdin.read
    file_info_list << count_input_file_info(text)
  else
    ARGV.each do |file_name|
      text = File.read(file_name)
      file_info_list << count_input_file_info(text, file_name)
    end
  end
  file_info_list
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
  file_info = {}
  file_info[:lines] = text.count("\n")
  file_info[:words] = text.split(/\s+/).length
  file_info[:bytesize] = text.bytesize
  file_info[:file_name] = file_name if !file_name.nil?
  file_info
end

def output(file_info, options)
  custom_order = %i[lines words bytesize file_name]
  custom_order.each do |key|
    file_info_value = file_info[key]
    next if file_info_value.nil?

    if %i[file_name].include?(key)
      print " #{file_info_value}"
    elsif options[key.to_sym]
      print file_info_value.to_s.rjust(8)
    end
  end
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
    file_info.each do |key, value|
      next if key == :file_name

      total_num_list[key] += value
    end
  end

  total_num_list.delete_if { |key| !file_info_list[0].key?(key) }
  total_num_list
end

main
