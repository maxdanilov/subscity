xml.instruct! :xml, :version => "1.0"
  xml.rss "version" => "2.0", "xmlns:dc" => "http://purl.org/dc/elements/1.1/" do
    xml.channel do
      domain = 'http://' + request.main_domain
      xml.title "SubsCity"
      xml.description "Лента последних фильмов расписания показа фильмов на языке оригинала (с субтитрами) в кинотеатрах Москвы и Санкт-Петербурга."
      xml.lastBuildDate Time.now.to_s(:rfc822)
      xml.link domain + url_for(:movies)

      for movie in locals[:movies]
        title = movie.title
        title += " (#{movie.title_original})" unless movie.title_original.nil?
        description = movie.description.to_s
        xml.item do
          xml.title title
          xml.description description
          xml.pubDate movie.created_at.to_s(:rfc822)
          xml.link domain + url_for(:movies, :id => movie.id)
        end
      end
    end
  end