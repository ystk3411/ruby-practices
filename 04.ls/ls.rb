#! /usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'
require 'pathname'

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
    output_detail(files)
  else
    offlset_length = spaces_num_file_name(files)
    output(files_format, offlset_length)
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

def get_spaces_num(datas)
  spaces_num_file_name = datas.map { |data| data[:file_name].size }.max + SPACE_LENGTH
  spaces_num_file_size = datas.map { |data| data[:file_size].size }.max
  spaces_num_link = datas.map { |data| data[:link_num].size }.max
  spaces_num_user_name = datas.map { |data| data[:user_name].size }.max
  spaces_num_group = datas.map { |data| data[:group_name].size }.max
  { file_name: spaces_num_file_name,
    file_size: spaces_num_file_size,
    link_num: spaces_num_link,
    user_name: spaces_num_user_name,
    group_name: spaces_num_group }
end

def get_file_metadata(files)
  meta_datas = []
  files.each do |file|
    fls = File.lstat(file)
    permission_num = fls.mode.to_s(8).rjust(6, '0')
    file_name = FileTest.symlink?(file) ? "#{file} -> #{File.readlink(file)}" : file
    meta_data = {
      file_name: file_name,
      user_name: Etc.getpwuid(fls.uid).name,
      group_name: Etc.getgrgid(fls.gid).name,
      link_num: fls.nlink.to_s,
      file_size: fls.size.to_s,
      permission: format_permission(permission_num),
      month: fls.mtime.strftime('%b'),
      day: fls.mtime.day.to_s,
      time: fls.mtime.strftime('%H:%M')
    }
    meta_datas << meta_data
  end
  meta_datas
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

def output(files, offlset_length)
  files.each_with_index do |file, _index|
    file.each do |f|
      print f.ljust(offlset_length)
    end
    puts
  end
end

def output_detail(files)
  meta_datas = get_file_metadata(files)
  spaces_num = get_spaces_num(meta_datas)
  meta_datas.each do |data|
    print "#{data[:permission]} "
    print "#{data[:link_num].rjust(spaces_num[:link_num])} "
    print "#{data[:user_name].ljust(spaces_num[:user_name])}  "
    print "#{data[:group_name].ljust(spaces_num[:group_name])}  "
    print "#{data[:file_size].rjust(spaces_num[:file_size])} "
    print "#{data[:month]} "
    print "#{data[:day].rjust(2)} "
    print "#{data[:time]} "
    print data[:file_name]
    puts
  end
end

main
