require 'json'

Subscity::App.controllers :movies2 do
  get :index, with: :id, id: /\d+.*/, provides: %i[html txt] do
    case content_type
    when :html
      cache(request.cache_key, expires: CACHE_TTL) do
        city = Api.get_city(request.subdomains.first)
        movie = Api.get_movie(city.domain, params[:id])
        if movie.nil?
          render 'errors/404', layout: :layout
        else
          title = movie.title
          title += " (#{movie.title_original})" unless movie.title_original.to_s.empty?
          title += ' на языке оригинала в кино'
          render 'movie/show', layout: :layout, locals: {
            title: title, cinemas: [], city: city,
            screenings: [], ratings: [], movie: movie
          }
        end
      end
    when :txt
      auth_allow_for_role :admin
      render 'movie/show.text', locals: { city: city, movie: movie, ratings: ratings }
    else
      render 'errors/404', layout: :layout
    end
  end
end
