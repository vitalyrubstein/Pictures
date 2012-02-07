require 'rubygems'
require 'date' #calls Date library
require 'fileutils'
require 'ftools'
require 'exifr'
require 'quick_magick'
#require 'mysql'
#require "dbi"

class Report
  def initialize
    @title = 'Monthly Report'
    @text = ['Things are going', 'really well.']
  end
  
  def output_report
  end
end

#FileUtils.copy('/Volumes/Extreme/pics/IMG_3558.JPG', '/Volumes/Extreme')
testpic ="/Volumes/Extreme/IMG_3558.JPG"
testpic1 ="/Volumes/Extreme/pics/IMG_3558.JPG"

#date1 = File.mtime('/Volumes/Extreme/pics/IMG_3558.JPG').to_f
#File.utime(date1,date1,testpic)
#date2 = File.mtime(testpic)

puts File.identical?(testpic,testpic1)

#puts date1
#puts date2
=begin
pic = "/Users/ruby/Documents/rt/pics3/IMG_3558.JPG"
dir = "/Users/ruby/Documents/rt/pics3"
rpic = "/Users/ruby/Documents/rt/pics3/resized_pic.JPG"

i = QuickMagick::Image.read(pic).first
        i.width # Retrieves width in pixels
        i.height # Retrieves height in pixels
puts i.width
puts i.height


i = QuickMagick::Image.read(pic).first
        i.resize "300x200!"
        i.save rpic
        

date = EXIFR::JPEG.new(rpic).date_time
date2 = File.atime(rpic)
puts date
puts date2
=end

#a = rand(100)
#puts a
#a = [1, 2, 3, 4]
#aa = [1, 2, 3, 4].inject { |result, element| result + element }
#b = [:A, "Vitaly"], [:B, "Christa"]

#c = b.flatten
#d = a.select {|e| e>1}
#puts d unless d==nil

#f = a.collect {|e| e*2}
#puts f[2]

=begin
hash = [b].inject({}) do |result, element|
  result[element.first.to_s] = element.last
  #result
end

puts hash.each {|k,v| puts "#{k} => #{v}"}


array = [1, 2, 3, 4, 5, 6, 7].inject([]) do |result, element|
  
  result << element.to_s if element % 2 == 0
  result
end

puts array # => ["2", "4", "6"]

a =[1,2,3,4,5]
aa = a.inject(5) do |result, element| 
  result + element
  result
end

puts aa

def set_hash
  hash = {}
  arr = []
  c = 0
  i = 0
  
  until c>5
   
    while i<10
      a = rand(100)
      arr << a
      i +=1
    end

  hash[c] = arr
  arr =[]
  c += 1
  puts hash.values.sort
  end
  return hash
end


hash = set_hash
puts hash[0]
puts "------"
puts hash[3]
#puts aa[2]


a =[[1,2],[3,4]]
b =[2,3,6]
c = a - b
a.each {|a,b| puts a,b}
=end

