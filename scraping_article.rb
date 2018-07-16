require 'open-uri'
require 'nokogiri'
require 'rubygems'
require 'mysql'
require 'fileutils'

# スクレイピング先のURL
url = 'https://gurutabi.gnavi.co.jp/i/gl2/'

charset = nil
html = open(url) do |f|
  charset = f.charset # 文字種別を取得
  f.read # htmlを読み込んで変数htmlに渡す
end

# 記事一覧を取得する
# 記事一覧テーブルに挿入するデータをスクレイピング 
article_list = []
doc = Nokogiri::HTML.parse(html, nil, charset)
doc.xpath('//div[@class="list-group-main-body"]').each do |node|
  # tilte
  element = []
  title = node.css('.list-group-main__ttl-txt').inner_text
  area = node.css('.list-group-main__support-txt\ list-group-main__area').inner_text
  element.push(title.encode("ASCII-8BIT", "ASCII-8BIT"))
  element.push(area.encode("ASCII-8BIT", "ASCII-8BIT"))

  article_list.push(element)
end

# 記事詳細を取得する
# まず取得する各詳細画面のURLを格納する
urldata = []
doc.xpath('//ul[@class="list-group-main-list"]').each do |node|
  # tilte
  node.search("li").each_with_index do |li|
    href = li.search("a").attribute("href").value
    urldata.push(href)
  end
end

# 取得した詳細取得先URLから詳細情報をスクレイピング
article_details = []
urldata.each do |urlPath|
#  url = 'https:' + urldata[0]
  url = 'https:' + urlPath
  html = open(url) do |f|
    charset = f.charset # 文字種別を取得
    f.read # htmlを読み込んで変数htmlに渡す
  end

  element = []
  doc = Nokogiri::HTML.parse(html, nil, charset)
#  print(doc)
  article_title = doc.css('.main-content__headline').inner_text.strip
  article_text = doc.search('//div[@class="mt40"]').search('p')[-1].inner_text.strip
  element.push(article_title.encode("ASCII-8BIT", "ASCII-8BIT"))
  element.push(article_text.encode("ASCII-8BIT", "ASCII-8BIT"))
  doc.xpath('//table[@class="plan-detail-table"]').each do |detail|
    category = detail.search('td')[0].inner_text.strip
    area = detail.search('td')[1].at('a').inner_text.strip
    address = detail.search('td')[2].inner_text.strip
    element.push(category.encode("ASCII-8BIT", "ASCII-8BIT"))
    element.push(area.encode("ASCII-8BIT", "ASCII-8BIT"))
    element.push(address.encode("ASCII-8BIT", "ASCII-8BIT"))
  end
  doc.xpath('//div[@class="access-map mt40"]').each do |detail|
    longitude = detail.search("input[id='longitudeValue']").attribute("value").value
    latitude = detail.search("input[id='latitudeValue']").attribute("value").value
    element.push(longitude)
    element.push(latitude)
  end

# 画像パスもいったん配列に保存し、insertのあとでディレクトリ内にファイルを作成する
  images = []
  doc.xpath('//div[@class="main-content__slideshow"]').css('img').each do |img|
    urlPath = "https:" + img.attribute("src").value
    images.push(urlPath)
  end
  element.push(images)

# ひとつの詳細情報を、全詳細情報の配列に保存する
  article_details.push(element)
end


# DBに接続して、スクレイピングしたデータをinsertする
client = Mysql::new('127.0.0.1', 'root', '', 'TripApp')
# 記事一覧
for i in 0..article_list.count - 1
# テーブルに一覧情報をinsert
  puts article_list[i]
  sql = %{
    insert into article_list (article_title, category, area,status_flg) values (?, "test", ?, 1)
  }
#  stmt = client.prepare(sql)
#  res = stmt.execute(article_list[i][0], article_list[i][1])
end

# 記事詳細
for num in 0..article_details.count - 1
# テーブルに詳細情報をinsert
  puts article_details[num]
  sql = %{
    insert into article_details (article_title, article_text, address, longitude, latitude) values (?, ?, ?, ?, ?)
  }
#  stmt1 = client.prepare(sql)
#  res = stmt1.execute(article_details[num][0], article_details[num][1], article_details[num][4], article_details[num][5], article_details[num][6])

# 記事IDを取得して、ディレクトリを作成し画像ファイルを保存する
  id = ""
  getsql = %{
    select article_id from article_details where article_title = "#{article_details[num][0]}"
  }
#  stmt2 = client.prepare(getsql)
#  result = stmt2.execute(article_details[num][0])
  result = client.query(getsql)
  result.each_hash do |row|
    id = row["article_id"]
  end

  for num2 in 0..article_details[num][7].count - 1
    dirName = "/var/www/TripApp/images/" + id + "/"
    fileTitle = num2 + 1
    fileName = fileTitle.to_s + ".jpg"
    filePath = dirName + fileName
    FileUtils.mkdir_p(dirName) unless FileTest.exist?(dirName)
    open(article_details[num][7][num2]) { |image|
      File.open(filePath, "wb") do |file|
      file.puts image.read
    end
    }
  end
end


