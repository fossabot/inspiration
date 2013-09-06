require 'bundler/setup'
require 'padrino-core/cli/rake'

PadrinoTasks.init

desc "Run a local server."
task :local do
  Kernel.exec("shotgun -s thin -p 9393")
end

desc "Get all old favorites."
task :get_old => :environment do
  puts Inspiration::LINK_FILE
  @images = Set.new(File.readlines(Inspiration::LINK_FILE).map {|l| l.strip })

  (0..6000).step(60) do |offset|
    rss_url = "http://backend.deviantart.com/rss.xml?q=favby%3Acalvin166%2F1422412&type=deviation&offset=#{offset}"
    p ({ :deviant => "calvin166", :offset => offset })
    open(rss_url) do |rss|
      feed = RSS::Parser.parse(rss)
      feed.items.each do |item|
        @images.add item.link
      end
    end

    puts "Images: #{@images.count}"
  end

  dribbble_user = "icco"
  dribbble_per_page = 30
  page_count = Dribbble::Base.paginated_list(Dribbble::Base.get("/players/#{dribbble_user}/shots/likes", :query => {:per_page => dribbble_per_page})).pages
  (1..page_count).each do |page|
    p ({ :player => dribbble_user, :page => page })
    data = Dribbble::Base.paginated_list(Dribbble::Base.get("/players/#{dribbble_user}/shots/likes", :query => {:page => page, :per_page => dribbble_per_page}))
    array = data.map {|s| s.url }
    array.each {|l| @images.add l }

    puts "Images: #{@images.count}"
  end

  FlickRaw.api_key = "5c282af934cd475695e1f727dd0404a9"
  FlickRaw.shared_secret = "49b3b77e99947328"
  FlickRaw.secure = true

  # http://www.flickr.com/services/api/misc.urls.html
  (1..25).each do |page|
    p ({ :flickr => '42027916@N00', :page => page })
    favorites = flickr.favorites.getPublicList(:user_id => '42027916@N00', :extras => 'url_n', :page => page).map {|p| "http://www.flickr.com/photos/#{p["owner"]}/#{p["id"]}"}
    favorites.each {|l| @images.add l }
    puts "Images: #{@images.count}"
  end

  @images = @images.delete_if {|i| i.empty? }.to_a.sort

  File.open(Inspiration::LINK_FILE, 'w') {|file| file.write(@images.to_a.join("\n")) }
end
