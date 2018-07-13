require 'open-uri'
require 'nokogiri'
require 'rubygems'
require 'mysql'

# スクレイピング先のURL
url = 'https://gurutabi.gnavi.co.jp/i/gl2/'

charset = nil
html = open(url) do |f|
  charset = f.charset # 文字種別を取得
  f.read # htmlを読み込んで変数htmlに渡す
end

data = []
# htmlをパース(解析)してオブジェクトを作成
doc = Nokogiri::HTML.parse(html, nil, charset)

doc.xpath('//ul[@class="list-group-main-list"]').each do |node|
  # tilte
  node.search("li").each_with_index do |li|
    href = li.search("a").attribute("href").value
    data.push(href)
  end
end

article_details = []
data.each do |urlPath|
#test = data[0]
  element = []

  url = 'https:' + urlPath
  print(url)

  html = open(url) do |f|
    charset = f.charset # 文字種別を取得
    f.read # htmlを読み込んで変数htmlに渡す
  end

  doc = Nokogiri::HTML.parse(html, nil, charset)

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

  article_details.push(element)
end

client = Mysql::new('127.0.0.1', 'root', '', 'TripApp')
for num in 0..article_details.count - 1

  puts article_details[num]
#  client.query("insert into article_details (article_title, article_text, address, longitude, latitude) values (\"#{article_details}[#{num}][0]\", \"#{article_details}[#{num}][1]\", \"#{article_details}[#{num}][4]\", \"#{article_details}[#{num}][5]\", \"#{article_details}[#{num}][6]\")")
#client.query("insert into article_details (article_title, article_text, address, longitude, latitude) values (\"#{article_details}[#{num}][0]\", \"#{article_details}[#{num}][1]\", \"#{article_details}[#{num}][4]\", \"#{article_details}[#{num}][5]\", \"#{article_details}[#{num}][6]\")")

  sql = %{
    insert into article_details (article_title, article_text, address, longitude, latitude) values (?, ?, ?, ?, ?)
  }
  stmt = client.prepare(sql)
  res = stmt.execute(article_details[num][0], article_details[num][1], article_details[num][4], article_details[num][5], article_details[num][6])

#  client.query("insert into article_details (article_title, article_text, address, longitude, latitude) values (\"#{article_details[0][0]}\", \"#{article_details[0][1]}\", \"#{article_details[0][4]}\", #{article_details[0][5]}, #{article_details[0][6]})")

#  client.query("insert into article_details (article_title, article_text, address, longitude, latitude) values (\"#{article_details}\"[#{num}][0], \"#{article_details}\"[#{num}][1], \"#{article_details}\"[#{num}][4], #{article_details}[#{num}][5], #{article_details}[#{num}][6])")
#p result = client.query("select * from article_detail")
end
#end
