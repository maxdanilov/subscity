Subscity::Admin.controllers :movies do
  get :index do
    @title = "Movies"
    @movies = Movie.all
    render 'movies/index'
  end

  get :new do
    @title = pat(:new_title, :model => 'movie')
    @movie = Movie.new
    render 'movies/new'
  end

  post :create do
    @movie = Movie.new(params[:movie])
    if @movie.save
      @title = pat(:create_title, :model => "movie #{@movie.id}")
      flash[:success] = pat(:create_success, :model => 'Movie')
      params[:save_and_continue] ? redirect(url(:movies, :index)) : redirect(url(:movies, :edit, :id => @movie.id))
    else
      @title = pat(:create_title, :model => 'movie')
      flash.now[:error] = pat(:create_error, :model => 'movie')
      render 'movies/new'
    end
  end

  get :edit, :with => :id do
    @title = pat(:edit_title, :model => "movie #{params[:id]}")
    @movie = Movie.find(params[:id])
    if @movie
      render 'movies/edit'
    else
      flash[:warning] = pat(:create_error, :model => 'movie', :id => "#{params[:id]}")
      halt 404
    end
  end

  put :update, :with => :id do
    @title = pat(:update_title, :model => "movie #{params[:id]}")
    @movie = Movie.find(params[:id])
    if @movie
      if @movie.update_attributes(params[:movie])
        flash[:success] = pat(:update_success, :model => 'Movie', :id =>  "#{params[:id]}")
        params[:save_and_continue] ?
          redirect(url(:movies, :index)) :
          redirect(url(:movies, :edit, :id => @movie.id))
      else
        flash.now[:error] = pat(:update_error, :model => 'movie')
        render 'movies/edit'
      end
    else
      flash[:warning] = pat(:update_warning, :model => 'movie', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy, :with => :id do
    @title = "Movies"
    movie = Movie.find(params[:id])
    if movie
      if movie.destroy
        flash[:success] = pat(:delete_success, :model => 'Movie', :id => "#{params[:id]}")
      else
        flash[:error] = pat(:delete_error, :model => 'movie')
      end
      redirect url(:movies, :index)
    else
      flash[:warning] = pat(:delete_warning, :model => 'movie', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy_many do
    @title = "Movies"
    unless params[:movie_ids]
      flash[:error] = pat(:destroy_many_error, :model => 'movie')
      redirect(url(:movies, :index))
    end
    ids = params[:movie_ids].split(',').map(&:strip)
    movies = Movie.find(ids)
    
    if Movie.destroy movies
    
      flash[:success] = pat(:destroy_many_success, :model => 'Movies', :ids => "#{ids.to_sentence}")
    end
    redirect url(:movies, :index)
  end
end
