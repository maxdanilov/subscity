xml.instruct! :xml, version: '1.0'
xml.rss 'version' => '2.0', 'xmlns:dc' => 'http://purl.org/dc/elements/1.1/' do
  xml.channel do
    domain = full_domain_name(locals[:city].domain).to_s
    xml.title "SubsCity (#{locals[:city].name})"
    xml.description 'Лента последних фильмов на языке оригинала (с субтитрами) в кинотеатрах Москвы и Санкт-Петербурга.'
    xml.lastBuildDate Time.now.to_s(:rfc822)
    xml.link domain + url_for(:movies, :index)

    locals[:movies].each do |movie|
      title = movie.title
      title += " (#{format_title(movie.title_original)})" unless movie.title_original.to_s.empty?
      description = movie.description_formatted.gsub('<br/>', '')
      xml.item do
        xml.title title
        xml.description description
        xml.pubDate movie.created_at.to_s(:rfc822)
        xml.link domain + url_for(:movies, :index, id: format_movie_url(movie))
      end
    end
  end
end
