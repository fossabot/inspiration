require "pp"

class ImageDB
  def initialize
    @images = Set.new(File.readlines(Inspiration::LINK_FILE).map(&:strip))
  end

  def images
    @images.to_a
  end

  def sample(count)
    images.sample count
  end

  def self.dribbble_client
    Dribbble::Client.new token: Inspiration::DRIBBBLE_TOKEN
  end

  def self.instagram_client
    Instagram.client(access_token: Inspiration::INSTAGRAM_TOKEN)
  end

  def update
    # DeviantArt
    rss_url = "http://backend.deviantart.com/rss.xml?q=favby%3Acalvin166%2F1422412&type=deviation"
    open(rss_url) do |rss|
      feed = RSS::Parser.parse(rss)
      feed.items.each do |item|
        @images.add item.link
      end
    end

    # Dribbble
    data = ImageDB.dribbble_client.get_user("icco").likes
    data.each { |l| @images.add l.html_url }

    # Flickr
    favorites = flickr.favorites.getPublicList(user_id: "42027916@N00", extras: "url_n").map { |p| "http://www.flickr.com/photos/#{p['owner']}/#{p['id']}" }
    favorites.each { |l| @images.add l }

    # Write all image links to disk
    all_images = @images.delete_if(&:empty?).to_a.sort
    File.open(Inspiration::LINK_FILE, "w") { |file| file.write(all_images.to_a.join("\n")) }

    # VeryGoods.co
    products = open "https://verygoods.co/site-api-0.1/users/icco/goods?limit=20" do |j|
      data = Oj.compat_load(j)
      data["_embedded"]["goods"].map { |g| "https://verygoods.co/site-api-0.1#{g['_links']['product']['href']}" }
    end
    products.each { |p| @images.add p }

    # Instagram
    ImageDB.instagram_client.user_liked_media.each do |i|
      @images.add i.link
    end

    true
  end

  def full_update
    # Flickr Personal Favorites Set
    # NOTE: Page count verified 2015-07-22
    (1..3).each do |page|
      p ({ flickr: "42027916@N00", set: "72157601200827657", page: page })
      begin
        resp = flickr.photosets.getPhotos(photoset_id: "72157601200827657", extras: "url_n", page: page)
        favorites = resp["photo"].map { |p| "http://www.flickr.com/photos/#{resp['owner']}/#{p['id']}" }
        favorites.each { |l| @images.add l }
        puts "Images: #{@images.count}"
      rescue
        puts "Failed to get."
      end
    end

    # DA Favorites
    # NOTE: Offset count verified 2015-07-22
    (0..6000).step(60) do |offset|
      rss_url = "http://backend.deviantart.com/rss.xml?q=favby%3Acalvin166%2F1422412&type=deviation&offset=#{offset}"
      p ({ deviant: "calvin166", offset: offset })
      open(rss_url) do |rss|
        feed = RSS::Parser.parse(rss)
        feed.items.each do |item|
          @images.add item.link
        end
      end

      puts "Images: #{@images.count}"
    end

    # Dribbble
    # NOTE: Page count verified 2015-09-02
    dribbble_user = "icco"
    page_count = 30

    (1..page_count).each do |page|
      data = ImageDB.dribbble_client.get_user(dribbble_user).likes page: page
      p ({ player: dribbble_user, page: page })
      data.each { |l| @images.add l.html_url }

      puts "Images: #{@images.count}"
    end

    # Flickr Favorites
    # http://www.flickr.com/services/api/misc.urls.html
    # NOTE: Page count verified 2015-07-22
    (1..30).each do |page|
      p ({ flickr: "42027916@N00", page: page })
      favorites = flickr.favorites.getPublicList(user_id: "42027916@N00", extras: "url_n", page: page).map { |p| "http://www.flickr.com/photos/#{p['owner']}/#{p['id']}" }
      favorites.each { |l| @images.add l }
      puts "Images: #{@images.count}"
    end

    # VeryGoods.co
    domain = "https://verygoods.co/site-api-0.1"
    url = domain + "/users/icco/goods?limit=20"
    while url
      p ({ verygoods: url })
      j = open url
      data = Oj.compat_load(j)
      if data["_links"]["next"]
        url = domain + data["_links"]["next"]["href"]
      else
        url = nil
      end
      products = data["_embedded"]["goods"].map { |g| "http://verygoods.co" + g["_links"]["product"]["href"].gsub(/products/, "product") }
      products.each { |p| @images.add p }
      puts "Images: #{@images.count}"
    end

    # Instagram
    #
    # No idea if the max_id stuff works here, all instagram likes currently fit
    # in one page.
    max_id = nil
    user = ImageDB.instagram_client.user.username
    loop do
      p ({ instagram: max_id, user: user })
      args = { max_like_id: max_id }.delete_if { |_k, v| v.nil? }
      data = ImageDB.instagram_client.user_liked_media(args)
      data.each do |i|
        @images.add i.link
        max_id = i.id
      end

      puts "Images: #{@images.count}"
      break if data.count == 0
    end

    # Clean UP.
    @images = @images.delete_if(&:empty?).to_a.sort

    # Write to file.
    File.open(Inspiration::LINK_FILE, "w") { |file| file.write(@images.to_a.join("\n")) }

    true
  end
end
