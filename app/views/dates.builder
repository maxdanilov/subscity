xml.instruct! :xml, version: '1.0'
xml.rss 'version' => '2.0', 'xmlns:dc' => 'http://purl.org/dc/elements/1.1/' do
  xml.channel do
    domain = full_domain_name(locals[:city].domain).to_s
    xml.title "SubsCity. Сеансы в городе #{locals[:city].name} (#{show_date locals[:date]})"
    xml.description "Лента сеансов на языке оригинала (с субтитрами) в кинотеатрах города #{locals[:city].name}"
    xml.lastBuildDate Time.now.to_s(:rfc822)
    xml.link domain + url_for(:movies, :index)
    locals[:screenings].each do |movie, cinemas|
      next if movie.nil? || cinemas.nil? || movie.hidden? || movie.russian?

      title = movie.title
      title += " (#{format_title(movie.title_original)})" unless movie.title_original.to_s.empty?
      description = "#{show_date(locals[:date], true, true)}."
      cinemas.each do |cinema, screenings|
        description += "<br/>«#{movie.title}» в кинотеатре «#{cinema.name}» в " \
          "#{screenings.map { |s| show_time(s.date_time) }.join ', '}."
      end
      description += "<br/><img src=\"#{movie.poster_url}\">"
      xml.item do
        xml.title title
        xml.description do
          xml.cdata! description
        end
        xml.pubDate '' # movie.created_at.to_s(:rfc822)
        xml.enclosure url: movie.poster_url, length: '', type: 'image/jpeg'
        xml.link domain + url_for(:movies, :index, id: format_movie_url(movie))
      end
    end
  end
end
