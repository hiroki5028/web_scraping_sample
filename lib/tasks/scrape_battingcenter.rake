# URLにアクセスするためのライブラリの読み込み
require 'nokogiri'
require 'open-uri'
require 'csv'

namespace :scrape_battingcenter do
  task :sitemap => :environment do
    # スクレイピング先のURL
    url = 'https://www.battingcenter.com/sitemap/index.html'
    charset = nil
    html = open(url) do |f|
      charset = f.charset # 文字種別を取得
      f.read # htmlを読み込んで変数htmlに渡す
    end
    # htmlをパース(解析)してオブジェクトを作成
    doc = Nokogiri::HTML.parse(html, nil, charset)
    list = []
    File.open("sitemap.txt", "w") do |file|
      links = doc.css('#sitemap_list .cat-item:not(.cat-item-2):not(.cat-item-51) ul li a')
      links.each do |link|
        list.push(link.attr("href"))
      end
      list.each do |h|
        file.write(h + "\n")
      end
    end
  end

  task :create_csv => :environment do
    url_list = []

    File.foreach("sitemap.txt"){|line|
      url_list << line.chomp
    }
    CSV.open("create_csv.csv", "w") do |csv|
      url_list.each_with_index do |url, i|
        p url
        charset = nil
        sleep 3
        html = open(url) do |f|
          charset = f.charset # 文字種別を取得
          f.read # htmlを読み込んで変数htmlに渡す
        end
        # htmlをパース(解析)してオブジェクトを作成
        doc = Nokogiri::HTML.parse(html, nil, charset)
        data = []
        # タイトルの取得
        doc.css('div[@id="content"]').each do |node|
          name = node.css('h2').inner_text
          information = { '名前' => name,
                          '住所' => nil,
                          'TEL' => nil,
                          '営業時間' => nil,
                          '定休日' => nil,
                          'PRポイント' => nil,
                          'バット持込' => nil,
                          '高さ調整' => nil,
                          '打席からホームラン\r\n      までの距離' => nil,
                          '料　金' => nil,
                          'レーン' => nil,
                          '打席' => nil,
                          'ボール' => nil,
                          '球種' => nil,
                          '球速' => nil,
                          '投手画像' => nil,
                          '電車でのアクセス' => nil,
                          '車でのアクセス' => nil,
                          '駐車場' => nil,
                          'ホームページ' => nil
                         }
          # 基本情報の取得
          doc.css('table.table1').each do |t|
            headers = t.css('th').map { |h| h.inner_text.strip }
            bodies = t.css('td').map { |d| d.inner_text.strip }

            headers.each_with_index do |h, i|
              if information.has_key?(h)
                information[h] = bodies[i]
              end
            end

          end
          data << information
          if i==0
            csv << data.map(&:keys).flatten
          end
          csv << data.map(&:values).flatten
        end
      end
    end
  end

  task :txt_read => :environment do
    url_list = []
    File.foreach("sitemap.txt"){|line|
      url_list << line.chomp
    }
    p url_list.length
  end

end
