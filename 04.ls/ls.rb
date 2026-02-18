#! /usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'

COL_NUM = 3
SPACE_LENGTH = 5
PERMISSION_PATTERN1 = {
  '01' => 'p',
  '02' => 'c',
  '04' => 'd',
  '06' => 'b',
  '10' => '-',
  '12' => 'l',
  '14' => 's'
}.freeze
PERMISSION_PATTERN2 = {
  '0' => '',
  '1' => %w[t T],
  '2' => %w[s S],
  '4' => %w[s S]
}.freeze
PERMISSION_PATTERN3 = {
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
    offset_length = spaces_num_file_size(files)
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
    fs = File::Stat.new(file)
    uid = fs.uid
    gid = fs.gid
    permission_num = fs.mode.to_s(8).length == 6 ? fs.mode.to_s(8) : "0#{fs.mode.to_s(8)}"
    permission1 = PERMISSION_PATTERN1[permission_num[0..1]]
    permission2 = PERMISSION_PATTERN2[permission_num[2]]
    permission3 = PERMISSION_PATTERN3[permission_num[3]]
    permission4 = PERMISSION_PATTERN3[permission_num[4]]
    permission5 = PERMISSION_PATTERN3[permission_num[5]]
    user_name = Etc.getpwuid(uid).name
    group_name = Etc.getgrgid(gid).name
    link_num = fs.nlink.to_s
    file_size = fs.size.to_s
    print "#{permission1}#{permission2}#{permission3}#{permission4}#{permission5} "
    print "#{link_num} "
    print "#{user_name}  "
    print "#{group_name}  "
    print "#{file_size.rjust(offset_length)} "
    print "#{fs.mtime.strftime('%b')} "
    print fs.mtime.day.to_s.length == 2 ? "#{fs.mtime.day} " : "#{fs.mtime.day.to_s.rjust(2)} "
    print "#{fs.mtime.strftime('%H:%M')} "
    print file
    puts
  end
end

main
