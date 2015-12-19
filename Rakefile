require "bundler/setup"
require "./site"

task :default do
  puts "No tests written."
end

desc "Run a local server."
task :local do
  Kernel.exec("shotgun -s thin -p 9393")
end

desc "Update links."
task :update_some_links do
  idb = ImageDB.new
  idb.update
end

desc "Get update all links."
task :update_links do
  idb = ImageDB.new
  idb.full_update
end

desc "Build a cache of the image db."
task :build_cache do
  cdb = CacheDB.new
  idb = ImageDB.new

  idb.images.to_a.shuffle.each do |i|
    cdb.cache i
  end
end

desc "Try to update 10 images in the cache."
task :build_cache_random do
  cdb = CacheDB.new
  idb = ImageDB.new

  idb.images.to_a.sample(10).each do |i|
    cdb.cache i
  end
end

desc "Remove unused images in cache."
task :clean do
  cdb = CacheDB.new
  idb = ImageDB.new

  cdb.clean idb.images
end

task :import_sqlite do
  cdb = CacheDB.new
  cdb.load_sql_to_json "cache.db"
end

desc "Download all images into a folder."
task :download do
  require "open-uri"
  require "uri"
  require "digest/sha1"
  require "mime/types"

  cdb = CacheDB.new
  cdb.all.map { |_k, v| v["image"] }.delete_if { |i| i.nil? || i.empty? }.sort.each do |i|
    url = URI(i)
    filename = Digest::SHA1.hexdigest(i)

    open(url) do |u|
      ext = MIME::Types[u.content_type].first.extensions.first
      path = "/Users/nat/Dropbox/Photos/Inspiration/#{filename}.#{ext}"
      open(path, "wb") do |file|
        begin
          puts "Downloading #{i}"
          file << u.read
        rescue OpenURI::HTTPError => e
          puts "Open URI error - #{e}"
        end
      end
    end
  end
end
