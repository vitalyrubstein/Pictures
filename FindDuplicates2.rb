require 'digest/md5'
require 'digest/sha1'

$BUF_SIZE = 1024*1024*1024

def md5(file_path)
      hasher = Digest::MD5.new
      open(file_path, "r") do |io|
        counter = 0
        while (!io.eof)
          readBuf = io.readpartial($BUF_SIZE)
          putc '.' if ((counter+=1) % 3 == 0)
          hasher.update(readBuf)
        end
      end     
      return hasher.hexdigest
end 


puts md5('/Volumes/Extreme/IMG_3.JPG')
puts md5('/Volumes/Extreme/IMG_3558.JPG')
puts md5('/Volumes/Extreme/pics/IMG_3559.JPG')
