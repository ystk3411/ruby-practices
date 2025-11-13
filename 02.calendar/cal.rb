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
  day_first = Date.new(year, month, 1)
  day_last = Date.new(year, month, -1)
rescue StandardError
  p "入力されたオプションの値は適切ではありません"
  exit
end

space = '   ' * day_first.wday

puts "#{month}月 #{year}".rjust(13)
puts '日 月 火 水 木 金 土'
print space

(1..day_last.day).each do |date|
  print date

  print ' ' if date < 10

  print ' '

  puts "\n" if (day_first.wday + date) % 7 == 0
end
