#! /usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'

COL_NUM = 3
SPACE_LENGTH = 5
FILE_TYPE = {
  '01' => 'p',
  '02' => 'c',
  '04' => 'd',
  '06' => 'b',
  '10' => '-',
  '12' => 'l',
  '14' => 's'
}.freeze
STICKY_BIT_PATTERN = {
  '1' => %w[t T],
  '2' => %w[s S],
  '3' => [%w[t T], %w[s S]],
  '4' => %w[s S],
  '5' => [%w[t T], %w[s S]],
  '6' => %w[s S],
  '7' => [%w[t T], %w[s S]]
}.freeze
PERMISSION_PATTERN = {
  '0' => '---',
  '1' => '--x',
  '2' => '-w-',
  '3' => '-wx',
  '4' => 'r--',
  '5' => 'r-x',
  '6' => 'rw-',
  '7' => 'rwx'
}.freeze

def main
  options = parse_option
  files = fetch_files(options)
  files_format = format_files(files)
  if options[:l]
    offset_length = {}
    offset_length[:file_size] = spaces_num_file_size(files)
    offset_length[:link] = spaces_num_link(files)
    offset_length[:user_name] = spaces_num_user_name(files)
    offset_length[:group_name] = spaces_num_group(files)
    output_detail(files, offset_length)
  else
    offset_length = spaces_num_file_name(files)
    output(files_format, offset_length)
  end
end

def parse_option
  options = {}
  opt = OptionParser.new
  opt.on('-a') { |_v| options[:a] = true }
  opt.on('-r') { |_v| options[:r] = true }
  opt.on('-l') { |_v| options[:l] = true }
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

def spaces_num_file_name(files)
  files.map(&:size).max + SPACE_LENGTH
end

def spaces_num_file_size(files)
  files.map do |file|
    fs = File::Stat.new(file)
    file_size = fs.size
    file_size.to_s.length
  end.max
end

def spaces_num_link(files)
  files.map do |file|
    fs = File::Stat.new(file)
    link_num = fs.nlink
    link_num.to_s.length
  end.max
end

def spaces_num_user_name(files)
  files.map do |file|
    user_name = get_file_metadata(file)[:user_name]
    user_name.length
  end.max
end

def spaces_num_group(files)
  files.map do |file|
    group_name = get_file_metadata(file)[:group_name]
    group_name.length
  end.max
end

def get_file_metadata(file)
  fs = File::Stat.new(file)
  permission_num = fs.mode.to_s(8).rjust(6, '0')
  uid = fs.uid
  gid = fs.gid
  {
    file_name: file,
    user_name: Etc.getpwuid(uid).name,
    group_name: Etc.getgrgid(gid).name,
    link_num: fs.nlink.to_s,
    file_size: fs.size.to_s,
    permission: format_permission(permission_num),
    month: fs.mtime.strftime('%b'),
    day: fs.mtime.day.to_s,
    time: fs.mtime.strftime('%H:%M')
  }
end

def format_permission(permission_num)
  file_type = FILE_TYPE[permission_num[0..1]]
  sticky_bit = format('%03b', permission_num[2].to_i)
  permission_pattern1 = PERMISSION_PATTERN[permission_num[3]].dup
  permission_pattern2 = PERMISSION_PATTERN[permission_num[4]].dup
  permission_pattern3 = PERMISSION_PATTERN[permission_num[5]].dup
  permission_num_array = [permission_num[3], permission_num[4], permission_num[5]]
  permission_pattern_array = [permission_pattern1, permission_pattern2, permission_pattern3]
  num = 0

  sticky_bit.each_char do |n|
    permission_num_formatted = format('%03b', permission_num_array[num].to_i)
    if (n.to_i & permission_num_formatted[2].to_i) == 1
      permission_pattern_array[num][2] = num == 2 ? 't' : 's'
    elsif (n.to_i == 1) && permission_num_formatted[2].to_i.zero?
      permission_pattern_array[num][2] = num == 2 ? 'T' : 'S'
    end
    num += 1
  end
  "#{file_type}#{permission_pattern1}#{permission_pattern2}#{permission_pattern3}"
end

def output(files, offset_length)
  files.each_with_index do |file, _index|
    file.each do |f|
      print f.ljust(offset_length)
    end
    puts
  end
end

def output_detail(files, offset_length)
  files.each do |file|
    meta_data = get_file_metadata(file)
    print "#{meta_data[:permission]} "
    print "#{meta_data[:link_num].rjust(offset_length[:link])} "
    print "#{meta_data[:user_name].ljust(offset_length[:user_name])}  "
    print "#{meta_data[:group_name].ljust(offset_length[:group_name])}  "
    print "#{meta_data[:file_size].rjust(offset_length[:file_size])} "
    print "#{meta_data[:month]} "
    print "#{meta_data[:day].rjust(2)} "
    print "#{meta_data[:time]} "
    print meta_data[:file_name]
    puts
  end
end

main
