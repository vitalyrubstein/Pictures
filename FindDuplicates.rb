require 'digest/md5'
require 'digest/sha1'

$BUF_SIZE = 1024*1024*1024

class Folder_Md5
  
  def initialize(folder)
    @md5_to_files = Hash.new  
    @folder = folder
  end 
    
  def scan
    @md5_to_files.clear
    compute_md5(@folder)
  end   
  
  def md5_for_file(file_path)
    @md5_to_files[file_path]
  end 
  
  def identical_count
    total = 0
    @md5_to_files.each_value do |value|
        if value.size >= 2
          total+= value.size    
        end 
      end
    return total  
  end 
  
  def list_identical
    total = 0
    identities = 0
    puts 'The List of identical files'
    @md5_to_files.each_value do |value|
        if value.size >= 2
          identities+=1
          total+= value.size
          puts 'Idenitical files:'
          value.each{|file_name| puts file_name}
        end 
      end
    puts "got #{identities} identities impling #{total} files"
  end
  
  private 
    def compute_md5(file_path)
      if File.directory?(file_path)
        crt_dir = Dir.new(file_path)
        crt_dir.each do |file_name|
          if file_name != '.' &&  file_name != '..'       
            compute_md5("#{crt_dir.path}#{file_name}")    
          end
        end 
      else
        md5_val = md5(file_path)
        if @md5_to_files[md5_val] == nil
          @md5_to_files[md5_val]  = [file_path] 
        else          
           @md5_to_files[md5_val] << file_path
        end   
      end
    end
    
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
end

worker = Folder_Md5.new('/Volumes/')
worker.scan
worker.list_identical