require 'rubygems'
require 'face' # to detect faces on images
require 'date' # to read date
require 'fileutils' # to copy files
require 'ftools' # to copy files

def read_pics_filenames(src_path)
  types = [".JPG", ".jpg"]
  pics=[]
  files = Dir[src_path]
  files.each do |f| 
    if types.include?(File.extname(f).to_s) # if correct extention
      pics << f
    end
  end
  return pics #returns array of full paths
end

def face_init
  Face.get_client(:api_key => '0a177b4e57080f4617080a51c64433a2', :api_secret => 'b430351b87de49047d12192442d125db')
end

def detect_faces(arrayOfURLs)
client = face_init
json = client.faces_detect(:urls => arrayOfURLs) # returns hash of hashes and arrays
end

def save_tag(tid, uid)
client = face_init
json = client.tags_save(:tids => tid, :uid => uid) # returns hash of hashes and arrays
end

def recognize_faces(arrayOfURLs)
client = face_init
json = client.faces_recognize(:urls => arrayOfURLs, :uids => 'all@r76') # returns hash of hashes and arrays
end

def train_faces(arrayOfUIDs)
client = face_init
json = client.faces_train(:uids => arrayOfUIDs) # returns hash of hashes and arrays
end

def create_pics_urls(src_path)
picsFileNames = read_pics_filenames(src_path).sort #sorts pics by name
picsURLs = [];

picsFileNames.each do |pic| 
  
  picBaseName = File.basename(pic)
  picURL = 'http://dl.dropbox.com/u/2500577/Test/' + picBaseName 
  picsURLs << picURL
  end
  return picsURLs # returns array of urls
end

def make_html(urls,outputPath,outputFile)
  
  out = outputPath + '/' + outputFile
  
  File.open(out, 'w') do |f|
    
    f << "<html>\n"
    f << "<body>\n"
    f << "<div>\n"
    
    urls.each do |url|
      f << %&<a href="#{url}"><img src="#{url}"></a>\n&
    end
  
    f << "</div>\n"
    f << "</body>\n"
    f << "</html>\n"

  end
end

def main

puts "Working..."
src = "/Users/ruby/Desktop/Dropbox/Public/Test/**/*" #dropbox directory with picstures
testPics = create_pics_urls(src)
json = recognize_faces(testPics) #reads face data from all pictures
status = json['status'] #reads detect status
photos = json['photos'] #array of hashes with data

hash1 = {}
hash2 = {}
hash3 = {}

photos.each  do |photoItems| # returns hash with keys: pid, url, tags, height, width
  photoURL = photoItems['url']
  photoWidth = photoItems['width'].to_f
  photoHeight = photoItems['height'].to_f
  photoArea = photoWidth * photoHeight
  #puts "W: #{photoWidth} H: #{photoHeight}"
  photoTags = photoItems['tags'] #returns array of hashes for each tag 0,1,2 ...
  if photoTags.size >0
    i = 0
    photoTags.each do |tagItems| # returns hash with face item keys: pitch, roll, yaw, height, width ... 
      
      # getting face TID
      faceTID = tagItems['tid']
      
      # getting recognized UIDs
      faceUID = tagItems['uids']
      faceRUID = []
      faceRConfidence = []
      # assinging values to faceRUID and faceRConfidence
      if faceUID.empty?
        faceRUID = 0
        faceRConfidence = 0
      else
        faceUID.each do |uidItems| 
          faceRUID << uidItems['uid'] # array of recognized UID
          faceRConfidence << uidItems['confidence'] # array of recognition confidences
        end
      end
      # puts faceRUID[0]
      
      # getting face size
      faceWidthPercent = tagItems['width'].to_f/100 # % of photoWidth
      faceHeightPercent = tagItems['height'].to_f/100 # % of photoHeight
      faceWidth = photoWidth * faceWidthPercent
      faceHeight = photoHeight * faceHeightPercent
      faceArea = faceWidth * faceHeight
      faceAreaPercent = faceArea/photoArea
      #puts "FW: #{faceWidth} FH: #{faceHeight} FA: #{faceArea} FA%: #{faceAreaPercent} PA: #{photoArea}"
      
      # getting face recognizable
      faceRecognizable = tagItems['recognizable']
      
      # getting face confidence
      faceAttributes = tagItems['attributes'] # returns hash
      faceFace = faceAttributes['face']
      faceConfidence = faceFace['confidence'].to_f
      
      # getting face rotation
      faceYaw = tagItems['yaw'].to_f.abs
      #faceRoll
      #facePitch
      
      
      if faceRecognizable && faceConfidence > 80 && faceYaw < 35 && faceAreaPercent > 0.005
        
        faceIndex = faceAreaPercent*100 #calculate the weighted index based on area, yaw, roll and pitch. make % for each as variable
        #puts faceArea
        #puts "%: #{faceAreaPercent*100} Y: #{faceYaw} I: #{faceIndex} #{photoURL}"
        hash1[faceTID] = photoURL
        hash2[faceTID] = faceIndex # replace faceArea with new faceIndex
        hash3[faceTID] = i
        #puts "TID: #{faceTID} A: #{faceArea}"
      end
    i += 1
    end
  end
end

# produces necessary order of faces for recognition process
tids =[]
urls = []
tagIDs = []

hash2.values.sort.reverse.each {|fi| tids << hash2.index(fi)} # produces array of TIDs sorted according to faceIndex

tids.each do |t| 
  
  urls << hash1[t] # sorts URLs according to sorted TIDs
  tagIDs << hash3[t] # sorts tagIDs according to sorted TIDs
  
  puts t # prings TID
  puts hash1[t] # prints urls
  puts hash3[t] # prints tagID
end
end # end main

main
#uniqueUrls = urls.uniq

#make_html(uniqueUrls,'/Users/ruby/Desktop/Dropbox/Public/Test','output.html')

=begin testing saving and traing
tid1 = 'TEMP_F@f8c97212ccfaedc6b0d0845d43651d98_0a177b4e57080f4617080a51c64433a2_18.72_27.58_1_1'
tid2 = 'TEMP_F@f8c97212ccfaedc6b0d0845d43651d98_0a177b4e57080f4617080a51c64433a2_35.72_35.75_1_1'
uid1 = 'vitaly@r76'
uid2 = 'christa@r76'

puts 'save1'
jsonS1 = save_tag(tid1, uid1)
puts jsonS1['status']
puts 'train1'
jsonT1 = train_faces(uid1)
puts jsonT1['status']
puts 'save2'
jsonS2 = save_tag(tid2, uid2)
puts jsonS2['status']
puts 'train2'
jsonT2 = train_faces(uid1)
puts jsonT2['status']
=end


=begin
url1 = 'http://dl.dropbox.com/u/2500577/Test/IMG_3659.JPG'
jsonT = train_faces('christa@r76')
puts jsonT['status']
puts jsonT.keys
puts 'Done'
=end