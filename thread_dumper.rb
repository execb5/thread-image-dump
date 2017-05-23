require 'nokogiri'
require 'open-uri'
require 'fileutils'
require 'parallel'

DUMP_FOLDER = "dump"

FileUtils.mkdir_p DUMP_FOLDER

thread_url = ARGV[0]
page = Nokogiri::HTML(open(thread_url))

subject = page.css('.subject')[1].text
local_folder = "#{DUMP_FOLDER}/#{subject}"
FileUtils.mkdir_p local_folder

images = page.css('.fileText a')
Parallel.each(images, in_processes: 8, progress: "Downloading... #{subject} thread") do |img|
  fnum = img['href'].split('/').last.split('.').first
  local_fname = "#{DUMP_FOLDER}/#{subject}/#{fnum}_#{img.text}"
  remote_url = "http:#{img['href']}"
  unless File.exists? local_fname
    begin
      img_content = open(remote_url).read
    rescue Exception=>e
      puts "Error: #{e}"
    else
      File.open(local_fname, 'wb'){|file| file.write(img_content)}
    end
  end
end
