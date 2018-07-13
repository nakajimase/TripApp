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

article_list = []
# htmlをパース(解析)してオブジェクトを作成
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

client = Mysql::new('127.0.0.1', 'root', '', 'TripApp')
for i in 0..article_list.count - 1
puts article_list[i]

sql = %{
  insert into article_list (article_title, category, area,status_flg) values (?, "test", ?, 1)
}
stmt = client.prepare(sql)
res = stmt.execute(article_list[i][0], article_list[i][1])

#client.query("insert into article_list (article_title, category, area, status_flg) values (\"#{article_list[0][0]}\", \"spot\" , \"#{article_list[0][1]}\", 1)")
#client.query("insert into article_list (article_title, category, area, status_flg) values (\"#{article_list}\[#{i}][0]\", \"spot\", \"#{article_list}\[#{i}][1]\", 1)")
end
