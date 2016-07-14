require 'nokogiri'
require 'open-uri'
require 'fileutils'

DUMP_FOLDER = "dump"

FileUtils.mkdir_p DUMP_FOLDER

thread_url = ARGV[0]
page = Nokogiri::HTML(open(thread_url))

subject = page.css('.subject')[0].text
local_folder = "#{DUMP_FOLDER}/#{subject}"
FileUtils.mkdir_p local_folder

images = page.css('.fileText a')
images.each do |img|
	local_fname = "dump/#{subject}/#{img.text}"
	remote_url = "http://#{img['href'][2..-1]}"
	unless File.exists? local_fname
		puts "Fetching #{remote_url}..."
		begin
			img_content = open(remote_url).read
		rescue Exception=>e
			puts "Error: #{e}"
			sleep 5
		else
			File.open(local_fname, 'wb'){|file| file.write(img_content)}
			puts "\t...Success, saved to #{local_fname}"
		ensure
			sleep 1.0 + rand
		end
	end
end


