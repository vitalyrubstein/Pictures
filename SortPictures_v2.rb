require 'rubygems'
require 'date' #calls Date library
require 'fileutils'
require 'ftools'
require 'exifr'
require 'quick_magick'


#--------- Variables ---------------------
$dr = "/Volumes/Extreme/pics4/**/*"
$out = "/Volumes/Extreme/moments/" 
$out2 = "/Volumes/Extreme/similar/"
$sec = 18000 # time for momments
$sec2 = 30 #time for similar
$ty = [".JPG", ".jpg"]

#-----------------------------------------

def directory_exists?(dir_path)
  return false if Dir[dir_path].empty? == true
  true
end

def make_output_dir (dir_path)
    delete_all_files(dir_path) if directory_exists?(dir_path) == true
    Dir.mkdir(dir_path)
end

def delete_all_files(dir_path)
    FileUtils.rm_rf dir_path
end

# reads all filenames with coorect extentions from directory and subdirectories
def read_pics_filenames(dir_path)
  pics=[]
  files = Dir[dir_path]
  files.each do |f| 
    if $ty.include?(File.extname(f).to_s) # if correct extention
      pics << f
    end
  end
  return pics
end

# obtains picture date
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
  
def read_all_dates(dir_path) #creates hash filename > time(float)
  adates = {}
  read_pics_filenames(dir_path).each { |n| adates[n] = read_pic_date(n).to_f } 
  return adates
end

def calc_time_diff(dir_path)
  i=0
  timediff =[]
  ftimes = read_all_dates(dir_path).values.sort
  timediff << 0
  
  until i == ftimes.length-1  
    i +=1
    timediff << ftimes[i] - ftimes[i-1]
  end
  
  return timediff
end

def get_td_positions(seconds,dir_path)  

  td = calc_time_diff(dir_path)
  pos =[]
  i = 0 
  td.each do |d| 
    pos << i if d > seconds
    i +=1
  end
  pos << td.size
  return pos
end

def create_pics_moments(seconds,dir_path)
  
  pos = get_td_positions(seconds, dir_path)
  arr = []
  mom = {}
  ftimes = read_all_dates(dir_path).values.sort
  hash = read_all_dates(dir_path)
  i = 0
  c = 0
  pos.each do |ps|
    
    until i >= ps
    pic = hash.index(ftimes[i])
    arr << pic
    i += 1
    end  
    mom[c] = arr
    arr =[]
    c += 1
  end
  return mom
end

def create_pics_similar(seconds,dir_path)
  i = 0
  td = calc_time_diff(dir_path)
  sim ={}
  pics = []
  val = read_all_dates(dir_path).values.sort
  hash = read_all_dates(dir_path)
  
  until i==td.size-1
    i +=1
    pics << hash.index(val[i-1]) if td[i] < seconds
    pics << hash.index(val[i]) if td[i] < seconds
  end
  sim[0] = pics.uniq
  return sim #returns hash with pictuers: hash[key] => [array of pictures]    
end

def create_pics_summary(seconds,dir_path)
  c = 0
  pics =[]
  summary = {}
  moments = create_pics_moments(seconds,dir_path)
  puts "Size:#{moments.size}" #debuging
  until c > moments.size-1
   #n.times do 
    puts "Set#{c}:-->#{moments[c].size}" #debuging
    r = rand(moments[c].size-1)   
    r = 0 if moments[c].size == 1
    pic = moments[c].at(r)
    pics << pic
    puts "r:#{r} --> #{pic}" #debuging
   #end 
    c += 1
  end
  summary[0] = pics
  return summary 
end

def display_time_diff(dir_path)
  td = calc_time_diff(dir_path)
  avg = td.inject{|sum,el| sum + el}.to_f / td.size

  td.each {|t| puts t}
  puts "Size: #{td.size}"
  puts "Min: #{td.min}"
  puts "Max: #{td.max}"
  puts "Avg: #{avg.round}" 
end

def create_remove_similar(seconds,dir_path,out_path) #seconds and out_path should be the same as in create_pics_similar
  dir = "#{out_path}**/*"
  sim = create_pics_similar(seconds,dir_path)
  simless = read_pics_filenames(dir)
  simf = []
  simlessf = []
  sim[0].each {|f| simf << File.basename(f)}
  simless.each {|ff| simlessf << File.basename(ff)}
  simdiff = simf - simlessf
  return simdiff
end

def delete_remove_similar(seconds,dir_path,out_path) #seconds and out_path should be the same as in create_pics_similar
  
  allpics = read_pics_filenames(dir_path)
  simdiff = create_remove_similar(seconds,dir_path,out_path)
  allpicsh = {}
  
  allpics.each {|f| allpicsh[File.basename(f)] = File.dirname(f)}
  simdiff.each {|ff| File.delete("#{allpicsh[ff]}/#{ff}")}
end

# an alternative method to find similar pictures
def experement_similar(seconds,dir_path)
  hash = create_pics_moments(seconds,dir_path)
  pics = []
  sim = {}
  hash.keys.sort.each {|c| hash[c].each {|p| pics << p} if hash[c].size>1}
  sim[0] = pics
  return sim
end

def resize_pics(new_width,dir_path,out_path)
  nw = new_width
  pics = read_pics_filenames(dir_path)
  
  make_output_dir (out_path)
  
  pics.each do |pic| 
    n = File.basename(pic)
    i = QuickMagick::Image.read(pic).first
    w = i.width.to_f # Retrieves width in pixels
    h = i.height.to_f # Retrieves height in pixels
    pr = w/h
    nh = nw/pr    
    puts "w:#{w} h:#{h} pr:#{pr} --> nw:#{nw} nh:#{nh}" #debuging info
    i.resize "#{nw}x#{nh}!"
    i.save "#{out_path}/#{n}"
  end
end

def copy_pics_files(method,dir_path,out_path)
  c = 0
  i = 0 # for debuging
  hash = method
  #hash2 = read_all_dates(dir_path) # this is for debuging.
  #td = calc_time_diff(dir_path) # for debuging
  make_output_dir(out_path)
  
  while c < hash.size
    dir = "#{out_path}/#{c}"
    make_output_dir(dir)
    hash[c].each do |pic| 
      File.copy(pic, dir)
      #puts "#{pic} --> #{dir} --> #{hash2[pic]} -->#{td[i]}" # this is for debuging purposes. delete when not needed.
      i += 1 # for debuging
    end
    c +=1
  end
end

def produce_html(dir_path,out_path,filename,src_path)
  file = filename
  dir = dir_path
  out = out_path
  src = src_path
  pics = read_pics_filenames("#{dir}/**/*")
  
  File.open("#{out}/#{file}", 'w') do |f|
    
    f << "<html>\n"
    f << "<body>\n"
    f << "<table>\n"
    #f << "<tr>\n" # horizontal
  
    pics.each do |pic|   
      puts "html --> #{pic}" # debuging
      f << %&<tr><td><a target="_blank" href="#{src}/#{File.basename(pic)}"><img src="#{pic}"></a></td>\n& # vertical
      #f << %&<td><a target="_blank" href="#{src}/#{File.basename(pic)}"><img src="#{pic}"></a></td>\n& #horizontal
    end
  
    f << "</tr>\n"
    f << "</table>\n"
    f << "</body>\n"
    f << "</html>\n"
  end
  puts "Done"
end


# Start ------------------------------------
tn_start = Time.now.to_f
puts "Start"
puts "--------------------------------------"
puts "Working..."
# ------------------------------------------  

#puts read_pic_edate("/Volumes/Extreme/similar/R/IMG_3567.JPG_resized.JPG")



#delete_remove_similar($sec2,$dr,$out2)
#copy_pics_files(create_pics_moments(18000,"/Volumes/Extreme/pics4/**/*"),"/Volumes/Extreme/pics4/**/*","/Volumes/Extreme/moments")
#copy_pics_files(experement_similar(20,$dr),$dr,$out2)

#copy_pics_files(create_pics_summary(100,"/Volumes/Extreme/moments/3/**/*"),"/Volumes/Extreme/moments/3/**/*","/Volumes/Extreme/summary")
#resize_pics(300,"/Volumes/Extreme/similar/**/*","/Volumes/Extreme/similarR")
produce_html("/Volumes/Extreme/similarR","/Volumes/Extreme/similarR","output.html","/Volumes/Extreme/similar/0")

#create_pics_summary(300,"/Volumes/Extreme/moments/3/**/*")
#display_time_diff("/Volumes/Extreme/moments/1/**/*")

# End --------------------------------------
tn_end = Time.now.to_f
tn_diff = "%.2f" % (tn_end - tn_start)
puts "--------------------------------------"
puts "Done in #{tn_diff} seconds."
#-------------------------------------------