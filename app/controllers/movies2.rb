require 'json'

Subscity::App.controllers :movies2 do
  get :index, with: :id, id: /\d+.*/, provides: %i[html txt] do
    case content_type
    when :html
      cache(request.cache_key, expires: CACHE_TTL) do
        id = params[:id].to_i
        city = Api.get_city(request.subdomains.first)
        movie = Api.get_movie(city.domain, id)
        if movie.nil?
          render 'errors/404', layout: :layout
        else
          screenings = Api.get_movie_screenings(city.domain, id)
          cinemas = Api.get_cinemas(city.domain)
          title = movie.title
          title += " (#{movie.title_original})" unless movie.title_original.to_s.empty?
          title += ' на языке оригинала в кино'
          render 'movie/show', layout: :layout, locals: {
            title: title, cinemas: cinemas, city: city,
            screenings: screenings, ratings: [], movie: movie
          }
        end
      end
    when :txt
      data = Api.authenticate()
      puts data
      # auth_allow_for_role :admin
      id = params[:id].to_i
      city = Api.get_city(request.subdomains.first)
      movie = Api.get_movie(city.domain, id)
      render 'movie/show.text', locals: { city: city, movie: movie, ratings: nil }
    else
      render 'errors/404', layout: :layout
    end
  end
end
