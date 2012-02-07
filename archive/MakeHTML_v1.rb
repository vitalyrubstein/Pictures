# Creates HTML file with all pictures in the directory

File.open('/Volumes/Extreme/summaryR/output.html', 'w') do |f|
    
f << "<html>\n"
f << "<body>\n"
f << "<table>\n"
f << "<tr>\n"
Dir.foreach("/Volumes/Extreme/summaryR") do |entry|
   if File.extname(entry) == ".JPG" then
		puts entry
		#f << %&<tr><td><img src="/Volumes/Extreme/summaryR/#{entry}"></td>\n&
		f << %&<td><img src="/Volumes/Extreme/summaryR/#{entry}"></td>\n&
	 end
end
f << "</tr>\n"
f << "</table>\n"
f << "</body>\n"
f << "</html>\n"
puts "Done"
end
