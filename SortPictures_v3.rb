require 'rubygems'
require 'date' # to read date
require 'fileutils' # to copy files
require 'ftools' # to copy files
require 'exifr' # to read exif data
require 'quick_magick' # to resize images


#--------- Variables ---------------------
$dr = "/Volumes/Extreme/pics4/**/*"
$out = "/Volumes/Extreme/moments/" 
$out2 = "/Volumes/Extreme/similar/"
$sec = 18000 # time for momments
$sec2 = 30 #time for similar
$ty = [".JPG", ".jpg"]

#-----------------------------------------

def directory_exists?(src_path)
  return false if Dir[src_path].empty? == true
  true
end

# creates new directory (deletes directory + all files if directory already exists)
def make_output_dir (src_path)
    delete_all_files(src_path) if directory_exists?(src_path) == true
    Dir.mkdir(src_path)
end

# deletes all files
def delete_all_files(src_path)
    FileUtils.rm_rf src_path
end

# reads all filenames (incl. full path) with correct extentions from a directory and all subdirectories
def read_pics_filenames(src_path)
  pics=[]
  files = Dir[src_path]
  files.each do |f| 
    if $ty.include?(File.extname(f).to_s) # if correct extention
      pics << f
    end
  end
  return pics
end

# obtains date for a picture (filename should incl. full path)
def read_pic_date(filename)
  date = read_pic_edate(filename) 
    if date == nil 
      date = read_pic_fdate(filename)             
    end
  return date
end

# reads file EXIF date
def read_pic_edate(filename)
  date = EXIFR::JPEG.new(filename).date_time
end 

# reads file modified date
def read_pic_fdate(filename)
  date = File.mtime(filename)
end 
  
# creates a hash key:filename > value:time(float)
def read_all_dates(src_path) 
  hash = {}
  read_pics_filenames(src_path).each { |pic| hash[pic] = read_pic_date(pic).to_f } 
  return hash
end

# calculates time difference between all pictures
def calc_time_diff(src_path)
  i=0
  timediff =[]
  pictimes = read_all_dates(src_path).values.sort
  timediff << 0
  
  until i == pictimes.length-1  
    i +=1
    timediff << pictimes[i] - pictimes[i-1]
  end
  
  return timediff # returns an array of time differences
end

# calculates positions of pictures with a given time difference
def get_td_positions(seconds,src_path)  
  td = calc_time_diff(src_path)
  positions =[]
  i = 0 
  td.each do |diff| 
    positions << i if diff > seconds
    i +=1
  end
  positions << td.size
  return positions # returns an array of pictures positions
end

# sorts pictures by moments with a given time difference
def create_pics_moments(seconds,src_path)
  positions = get_td_positions(seconds, src_path)
  picsgroup = []
  moments = {}
  pictimes = read_all_dates(src_path).values.sort
  hash = read_all_dates(src_path)
  i = 0
  c = 0
  positions.each do |ps|
    
    until i >= ps
    pic = hash.index(pictimes[i])
    picsgroup << pic
    i += 1
    end  
    moments[c] = picsgroup
    picsgroup =[]
    c += 1
  end
  return moments # returns a hash key:groupnumber > value: array of pictures
end

# displays time difference between picturs in a given directory - used for debugging
def display_time_diff(src_path)
  td = calc_time_diff(src_path)
  avg = td.inject{|sum,el| sum + el}.to_f / td.size

  td.each {|t| puts t}
  puts "Size: #{td.size}"
  puts "Min: #{td.min}"
  puts "Max: #{td.max}"
  puts "Avg: #{avg.round}" 
end

# resizes one given pic (pic should include full path)
def resize_pic(filename,resizewidth,out_path)
  nw = resizewidth
  n = File.basename(filename)
  i = QuickMagick::Image.read(filename).first
  w = i.width.to_f # Retrieves width in pixels
  h = i.height.to_f # Retrieves height in pixels
  pr = w/h
  nh = nw/pr    
  i.resize "#{nw}x#{nh}!"
  i.save "#{out_path}/#{n}"
end

#copy one given pic (pic should include full path) with keeping original file created and modified dates
def copy_pic(filename,out_path)
  originaldate = read_pic_date(filename).to_f # get pic date
  File.copy(filename, out_path) # copy pic
  copyfilename = out_path + '/' + File.basename(filename) # new path to pic
  File.utime(originaldate,originaldate,copyfilename) # set original date to pic
end

# main method: assembles all together
def produce_moments_files(seconds,src_path,out_path,htmlfilename,resizewidth)
  c = 0
  moments = create_pics_moments(seconds,src_path)
  make_output_dir(out_path)
  File.open("#{out_path}/#{htmlfilename}", 'a') do |htmlfile| # creates and writes html file
  #htmlfile << %&header\n& # insert here html code before pictures
    while c < moments.size
      dir = "#{out_path}/#{c}" # path to output subdirectory
      rdir = dir + '/resized' # path to subdirectory with resized pictures
      make_output_dir(dir) # making output subdir
      make_output_dir(rdir) # making resized subdir
      htmlfile << %&<div class="images" id="set#{c}">\n& # opening pictures set div
      moments[c].each do |pic| 
        #copy_pic(pic,dir)
        resize_pic(pic,900,dir) # instead of copy_pic
        puts 'copied: ' + pic
        resize_pic(pic,resizewidth,rdir)
        htmlfile << %&   <a target="_blank" href="../_images/#{c}/#{File.basename(pic)}"><img src="../_images/#{c}/resized/#{File.basename(pic)}" alt="#{File.basename(pic)}"></a>\n& # main html
      end
      c +=1
      htmlfile << %&</div>\n& # closing pictures set div
    end
  #htmlfile << %&footer\n& #insert here html code after pictures
  end
end

# Start ------------------------------------

tn_start = Time.now.to_f
puts "Start"
puts "--------------------------------------"
puts "Working..."

# ------------------------------------------  


produce_moments_files(36000,"/Volumes/Extreme/pics/**/*","/Volumes/Extreme/output/moments","moments.html",300)



# End --------------------------------------
  tn_end = Time.now.to_f
  tn_diff = "%.2f" % (tn_end - tn_start)
  puts "--------------------------------------"
  puts "Done in #{tn_diff} seconds."
#-------------------------------------------