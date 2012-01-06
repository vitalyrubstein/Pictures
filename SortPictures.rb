require 'rubygems'
require 'date' #calls Date library
require 'fileutils'
require 'ftools'
require 'exifr'
#require 'quick_magick'

#--------- Variables ---------------------
$dr = "/Users/ruby/Documents/rt/pics2/**/*"
$out = "/Users/ruby/Documents/rt/moments/" 
$out2 = "/Users/ruby/Documents/rt/similar/"
$sec = 36000	
$sec2 = 10
$ty = [".JPG", ".jpg"]
#-----------------------------------------

def make_output_dir (output_path)
		Dir.mkdir(output_path)
end

# reading all filenames with coorect extentions from directory and subdirectories
def read_pics_filenames (dir_path)

		files=[]
		pics=[]
		files = Dir[$dr]
		files.each do |f| 
			if $ty.include?(File.extname(f).to_s) # if correct extention
				pics << f
			end
		end
	return pics
end

# reading file EXIF date
def read_pic_date(filename)
		date = EXIFR::JPEG.new(filename).date_time 
			if date == nil 
			date = read_pic_fdate(filename)             
		end
	return date
end

# reading file modified date
def read_pic_fdate(filename)
		date = File.mtime(filename)
end	
	
def read_all_dates #creating hash filename > time(float)
		adates = {}
		read_pics_filenames($dr).each { |n| adates[n] = read_pic_date(n).to_f } 
	return adates
end

def calc_time_diff
	
	i=0
	ftimes = []
	timediff =[]
	
	read_all_dates.values.sort.each do |t| ftimes << t.to_f end

	begin  
		i += 1
		timediff << ftimes[i] - ftimes[i-1]
		
	end until i == ftimes.length-1
	
	return timediff
end

def create_pics_moments(seconds)
	i = 0
	td = calc_time_diff
	pos =[]
	begin
		if td[i] > seconds then
			pos << i+1 #i+1 since # of pictures = # of time differences + 1
		end
	i += 1
	end until i == td.size 
	pos << calc_time_diff.size+1
	return pos
end		

def create_pics_similar(seconds)
	i = 0
	td = calc_time_diff
	pos =[]
	begin
		if td[i] < seconds then
			pos << i+1
		end
	i += 1
	end until i == td.size 
	return pos
	
end	

def copy_pics_similar

	make_output_dir($out2)
	
	ids = create_pics_similar($sec2)
	i = 0
	val = read_all_dates.values.sort
	hash = read_all_dates

	ids.each do |id| 
		i = id
		pic1 = hash.index(val[i-1])
		pic2 = hash.index(val[i])
		File.copy(pic1, "#{$out2}")
		File.copy(pic2, "#{$out2}")
		puts pic1
		puts pic2
	end
end
	
def copy_pics_moments
	
	make_output_dir($out)
	
	ids = create_pics_moments($sec) 
	c = 0 	
	i =0
	val = read_all_dates.values.sort
	hash = read_all_dates
		begin
			make_output_dir("#{$out}/#{c}")
			puts "----------------"
			begin
				pic = hash.index(val[i]) 
				puts pic.to_s + read_pic_date(pic).to_s
				File.copy(pic, "#{$out}/#{c}")
				i += 1
			end until i == ids[c] 
			c += 1
		end until c == ids.size
end

def display_time_diff
  td = calc_time_diff
  avg = td.inject{|sum,el| sum + el}.to_f / td.size

  puts td
  puts "Min: #{td.min}"
  puts "Max: #{td.max}"
  puts "Avg: #{avg.round}" 
end


def directory_exists?(directory)
  return false if Dir[directory].empty? == true
  true
end

$dr_test ="/Users/ruby/Documents/rt/pic4"

# Start ------------------------------------
tn_start = Time.now.to_f
puts "Start"
puts "--------------------------------------"
# ------------------------------------------  
#pics.each {|pic| puts read_pic_date(pic)}
#copy_pics_moments
#copy_pics_similar
#display_time_diff



make_output_dir($dr_test) unless directory_exists?($dr_test) == true
#Dir.delete($dr_test) if directory_exists?($dr_test) == true

# End --------------------------------------
tn_end = Time.now.to_f
tn_diff = "%.2f" % (tn_end - tn_start)
puts "--------------------------------------"
puts "Done in #{tn_diff} seconds."
#-------------------------------------------



