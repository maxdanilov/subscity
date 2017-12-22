xml.instruct! :xml, :version => "1.0"
  xml.rss "version" => "2.0", "xmlns:dc" => "http://purl.org/dc/elements/1.1/" do
    xml.channel do
      domain = "#{full_domain_name(locals[:city].domain)}"
      xml.title "SubsCity. Сеансы в городе #{locals[:city].name}"
      xml.description "Лента сеансов на языке оригинала (с субтитрами) в кинотеатрах города #{locals[:city].name}"
      xml.lastBuildDate Time.now.to_s(:rfc822)
      xml.link domain + url_for(:movies, :index)
      locals[:screenings].each do |screening|
        movie = locals[:movies].detect { |m| m.movie_id == screening.movie_id} rescue nil
        cinema = locals[:cinemas].detect { |c| c.cinema_id == screening.cinema_id } rescue nil
        next if movie.nil? or cinema.nil?

        title = movie.title
        title += " (#{format_title(movie.title_original)})" unless movie.title_original.to_s.empty?
        description = "#{show_date_time_feed(screening.date_time)}.<br/>«<a target=\"_blank\" href=\"" + domain + url_for(:movies, :index, :id => format_movie_url(movie)) + "\">#{movie.title}</a>» в кинотеатре #{cinema.name}.<br/><img src=\"#{movie.poster_url}\">"
        xml.item do
          xml.title title
          xml.description do
            xml.cdata! description
          end
          xml.pubDate ""#screening.created_at.to_s(:rfc822)
          xml.enclosure :url => movie.poster_url, :length => "", :type => 'image/jpeg'
          xml.link domain + url_for(:movies, :index, :id => format_movie_url(movie))
        end
      end
    end
  end