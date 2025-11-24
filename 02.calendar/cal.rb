#! /usr/bin/env ruby
require 'optparse'
require 'date'

options = {}
opt = OptionParser.new
opt.on('-m month') { |month| options[:month] = month.to_i }
opt.on('-y year') { |year| options[:year] = year.to_i }
opt.parse!(ARGV)

begin
  today = Date.today
  month = options[:month] || today.month
  year = options[:year] || today.year
  first_date = Date.new(year, month, 1)
  last_date = Date.new(year, month, -1)
rescue StandardError
  puts "入力されたオプションの値は適切ではありません"
  exit
end

space = '   ' * first_date.wday

puts "#{month}月 #{year}".rjust(13)
puts '日 月 火 水 木 金 土'
print space

(1..last_date.day).each do |date|
  print date.to_s.rjust(2)
  print ' '
  puts "\n" if Date.new(year, month, date).saturday?
end
