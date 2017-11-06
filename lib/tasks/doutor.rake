# URLにアクセスするためのライブラリの読み込み
require 'nokogiri'
require 'open-uri'
require 'csv'

namespace :doutor do
  task :url_list => :environment do
    File.open("doutor_url_list.txt", "w") do |file|
      list = []
      pages = [*('1'..'67')]
      pages.each do |page|
        sleep 3
        url = 'https://sasp.mapion.co.jp/b/doutor/attr/?start=' + page + '&t=attr_con'
        pp url
        charset = nil
        html = open(url) do | f |
          charset = f.charset
          f.read
        end
        doc = Nokogiri::HTML.parse(html, nil, charset)
        links = doc.css('table.MapiTable tbody tr#m_stripe td dl dt a')
        links.each do |link|
          list.push('https://sasp.mapion.co.jp' + link.attr("href"))
        end
      end
      list.each do |h|
        file.write(h + "\n")
      end
    end
  end

  task :create_csv => :environment do
    url_list = []
    File.foreach("doutor_url_list.txt"){|line|
      url_list << line.chomp
    }
    CSV.open("create_doutor.csv", "w") do |csv|
      url_list.each_with_index do |url, i|
        p i + 1
        charset = nil
        sleep 1
        html = open(url) do |f|
          charset = f.charset
          f.read
        end
        doc = Nokogiri::HTML.parse(html, nil, charset)
        data = []

        name = doc.css('div.MapiInner h1').inner_text.strip
        information = {'url' => url, '店舗名' => name }
        doc.css('table.MapiInfoTable').each do |t|
          headers = t.css('th').map { |h| h.inner_text.strip }
          bodies = t.css('td').map { |d| d.inner_text.strip.gsub('\n','') }
          headers.each_with_index do |h, i|
            information[h] = bodies[i]
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

  task :url_list_gnavi => :environment do
    File.open("doutor_url_list_gnavi.txt", "w") do |file|
      list = []
      pages = [*('1'..'34')]
      pages.each_with_index do | page, i |
        sleep 1
        if i==0
          url = 'https://r.gnavi.co.jp/brand/1cae31a6/'
        else
          url = 'https://r.gnavi.co.jp/brand/1cae31a6/?p=' + page
        end
        charset = nil
        p i + 1
        html = open(url) do | f |
          charset = f.charset
          f.read
        end
        doc = Nokogiri::HTML.parse(html, nil, charset)
        links = doc.css('div.shop__main-right ul.shop__list li a.shop-casset__link')
        links.each do |link|
          list.push(link.attr("href"))
        end
      end
      list.each do |h|
        file.write(h + "\n")
      end
    end
  end

  task :create_csv_gnavi => :environment do
    url_list = []
    data = []
    File.foreach("doutor_url_list_gnavi.txt"){|line|
      url_list << line.chomp
    }
    CSV.open("create_doutor_gnavi.csv", "w") do |csv|
      url_list.each_with_index do |url, i|
        p i + 1
        p url
        charset = nil
        sleep 1
        html = open(url) do |f|
          charset = f.charset
          f.read
        end
        doc = Nokogiri::HTML.parse(html, nil, charset)
        data = []
        header = doc.css('div#header-main-unit')
        kana = header.css('span#header-main-ruby').inner_text.strip
        kanji = header.css('h1').inner_text.strip
        p kana
        p kanji
        data << kana
        data << kanji
        csv << data
      end
    end
  end
end
