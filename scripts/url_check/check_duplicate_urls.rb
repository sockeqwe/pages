path = "../../content/"

at_least_one_duplicate_found=false
used_urls = {}

Dir.entries(path).select { |f| File.file? File.join(path, f) }.each { |file|
        File.open(path+file).readlines
        .map {|l| l.strip }
        .select { |line| 
            line.start_with?("url:")
        }.each { |line|
            if (used_urls[line] == nil)
                used_urls[line] = [file]
            else
                used_urls [line] = used_urls[line].append(file)
            end
        }
    }

used_urls.each { |url, files| 
    if (files.length > 1)
        at_least_one_duplicate_found = true
        puts "found duplicate #{url} used by #{files}"
    end
}

if (at_least_one_duplicate_found)
    exit(1) # For CI systems to fail their jobs
else
    puts "no duplicate URLs found. Good job!"
end