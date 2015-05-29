xml.instruct! :xml, :version => "1.0"
  xml.rss "version" => "2.0", "xmlns:dc" => "http://purl.org/dc/elements/1.1/" do
    xml.channel do
      domain = "http://#{locals[:city].domain}.#{request.main_domain}"
      xml.title "SubsCity (#{locals[:city].name}) сеансы"
      xml.description "#{locals[:screenings].size} Лента сеансов фильмов на языке оригинала (с субтитрами) в кинотеатрах Москвы и Санкт-Петербурга."
      xml.lastBuildDate Time.now.to_s(:rfc822)
      xml.link domain + url_for(:movies, :index)
      locals[:screenings].each do |screening|
        movie = locals[:movies].detect { |m| m.movie_id == screening.movie_id} rescue nil
        cinema = locals[:cinemas].detect { |c| c.cinema_id == screening.cinema_id } rescue nil
        next if movie.nil? or cinema.nil?

        title = movie.title
        title += " (#{format_title(movie.title_original)})" unless movie.title_original.to_s.empty?
        poster_url = domain + "/images/posters/#{movie.movie_id}.jpg"
        description = "#{show_date_time_feed(screening.date_time)}<br/><a target=\"_blank\" href=\"" + domain + url_for(:movies, :index, :id => format_movie_url(movie)) + "\">#{movie.title}</a> в кинотеатре #{cinema.name}"
        xml.item do
          xml.title title
          xml.description do
            xml.cdata! description
          end
          xml.pubDate screening.created_at.to_s(:rfc822)
          xml.enclosure :url => poster_url, :length => "", :type => 'image/jpeg'
          xml.link domain + url_for(:movies, :index, :id => format_movie_url(movie))
        end
      end
    end
  end