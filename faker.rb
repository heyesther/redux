require 'optparse'
require 'date'
require 'time'

FILE = "fakes.md"
min = 1
max = 10

options = {}

parser = OptionParser.new do |opts|
  opts.banner = "Usage: ruby faker.rb --date start_date end_date [options] ..."
  opts.separator ""
  opts.separator "Dates must be formatted as M-D-YY"
  opts.separator ""

  options[:dates] = nil
  opts.on("--dates date1,date2", Array, "Starting and ending dates") do |dates|
    options[:dates] = dates
  end

  options[:fixed] = nil
  opts.on("-f", "--fixed [number]", Integer, "Keeps commit count a fixed number") do |f|
    options[:fixed] = f
  end

  options[:range] = nil
  opts.on("-r", "--range [min,max]", Array, "Limit to specific min/max values") do |range|
    options[:range] = range
  end

  opts.on("-h", "--help", "Display help screen") do
    puts opts
    exit
  end
end


parser.parse!

if options[:range]
  min = options[:range][0].to_i
  max = options[:range][1].to_i
end

start_date = Date.strptime(options[:dates][0], "%m-%d-%y")
end_date = Date.strptime(options[:dates][1], "%m-%d-%y")

if end_date < start_date
  puts "Start date must be before end date."
  exit
end

unless min < max
  puts "Minimum must be less than maximum value."
  exit
end

date = start_date
num = options[:fixed]
commits = 0

while date <= end_date
  num = rand(min..max) unless options[:fixed]
  time = Time.parse(date.to_s)
  num.times do
    File.open(FILE, "a") do |file|
      file.puts "#{time.strftime("Commit on %B %-d, %Y")}"
      file.puts
    end
    %x(git add #{FILE})
    %x(git commit --date="#{time.strftime("%Y-%m-%d %H:%M:%S")}" -m "commit on #{time.strftime("%-m-%-d-%y")}")
    time += 1
    commits += 1
  end
  date += 1
end

puts "#{commits} commit#{commits == 1 ? '' : 's'} written."
