#! /usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'
require 'pathname'

COL_NUM = 3
SPACE_LENGTH = 5
STICKY_BIT_INDEX = 2
FILE_TYPE = {
  '01' => 'p',
  '02' => 'c',
  '04' => 'd',
  '06' => 'b',
  '10' => '-',
  '12' => 'l',
  '14' => 's'
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
  meta_datas = get_file_metadata(files)
  offlset_length = get_offlset_length(meta_datas)
  if options[:l]
    output_detail(meta_datas, offlset_length)
  else
    output(files_format, offlset_length[:file_name])
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

def get_offlset_length(datas)
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

def get_blocks_total(datas)
  datas.map { |data| data[:block] }.sum
end

def get_file_metadata(files)
  files.map do |file|
    fls = File.lstat(file)
    permission_num = fls.mode.to_s(8).rjust(6, '0')
    file_name = FileTest.symlink?(file) ? "#{file} -> #{File.readlink(file)}" : file
    {
      file_name: file_name,
      user_name: Etc.getpwuid(fls.uid).name,
      group_name: Etc.getgrgid(fls.gid).name,
      link_num: fls.nlink.to_s,
      file_size: fls.size.to_s,
      permission: format_permission(permission_num),
      month: fls.mtime.strftime('%b'),
      day: fls.mtime.day.to_s,
      time: fls.mtime.strftime('%H:%M'),
      block: fls.blocks
    }
  end
end

def format_permission(permission_num)
  file_type = FILE_TYPE[permission_num[0..1]]
  sticky_bit = format('%03b', permission_num[2].to_i)
  permission_user = PERMISSION_PATTERN[permission_num[3]].dup
  permission_group = PERMISSION_PATTERN[permission_num[4]].dup
  permission_other = PERMISSION_PATTERN[permission_num[5]].dup
  permission_num_array = [permission_num[3], permission_num[4], permission_num[5]]
  permission_pattern_array = [permission_user, permission_group, permission_other]

  sticky_bit.each_char.with_index do |bit_num, index|
    permission_num_formatted = format('%03b', permission_num_array[index].to_i)
    next if bit_num == '0'

    permission_pattern_array[index][2] = if bit_num == permission_num_formatted[2]
                                           index == STICKY_BIT_INDEX ? 't' : 's'
                                         else
                                           index == STICKY_BIT_INDEX ? 'T' : 'S'
                                         end
  end
  "#{file_type}#{permission_user}#{permission_group}#{permission_other}"
end

def output(files, offlset_length)
  files.each_with_index do |file, _index|
    file.each do |f|
      print f.ljust(offlset_length)
    end
    puts
  end
end

def output_detail(meta_datas, offlset_length)
  puts "total #{get_blocks_total(meta_datas)}"
  meta_datas.each do |data|
    print "#{data[:permission]} "
    print "#{data[:link_num].rjust(offlset_length[:link_num])} "
    print "#{data[:user_name].ljust(offlset_length[:user_name])}  "
    print "#{data[:group_name].ljust(offlset_length[:group_name])}  "
    print "#{data[:file_size].rjust(offlset_length[:file_size])} "
    print "#{data[:month]} "
    print "#{data[:day].rjust(2)} "
    print "#{data[:time]} "
    print data[:file_name]
    puts
  end
end

main
