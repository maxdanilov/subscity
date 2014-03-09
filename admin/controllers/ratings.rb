Subscity::Admin.controllers :ratings do
  get :index do
    @title = "Ratings"
    @ratings = Rating.all
    render 'ratings/index'
  end

  get :new do
    @title = pat(:new_title, :model => 'rating')
    @rating = Rating.new
    render 'ratings/new'
  end

  post :create do
    @rating = Rating.new(params[:rating])
    if @rating.save
      @title = pat(:create_title, :model => "rating #{@rating.id}")
      flash[:success] = pat(:create_success, :model => 'Rating')
      params[:save_and_continue] ? redirect(url(:ratings, :index)) : redirect(url(:ratings, :edit, :id => @rating.id))
    else
      @title = pat(:create_title, :model => 'rating')
      flash.now[:error] = pat(:create_error, :model => 'rating')
      render 'ratings/new'
    end
  end

  get :edit, :with => :id do
    @title = pat(:edit_title, :model => "rating #{params[:id]}")
    @rating = Rating.find(params[:id])
    if @rating
      render 'ratings/edit'
    else
      flash[:warning] = pat(:create_error, :model => 'rating', :id => "#{params[:id]}")
      halt 404
    end
  end

  put :update, :with => :id do
    @title = pat(:update_title, :model => "rating #{params[:id]}")
    @rating = Rating.find(params[:id])
    if @rating
      if @rating.update_attributes(params[:rating])
        flash[:success] = pat(:update_success, :model => 'Rating', :id =>  "#{params[:id]}")
        params[:save_and_continue] ?
          redirect(url(:ratings, :index)) :
          redirect(url(:ratings, :edit, :id => @rating.id))
      else
        flash.now[:error] = pat(:update_error, :model => 'rating')
        render 'ratings/edit'
      end
    else
      flash[:warning] = pat(:update_warning, :model => 'rating', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy, :with => :id do
    @title = "Ratings"
    rating = Rating.find(params[:id])
    if rating
      if rating.destroy
        flash[:success] = pat(:delete_success, :model => 'Rating', :id => "#{params[:id]}")
      else
        flash[:error] = pat(:delete_error, :model => 'rating')
      end
      redirect url(:ratings, :index)
    else
      flash[:warning] = pat(:delete_warning, :model => 'rating', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy_many do
    @title = "Ratings"
    unless params[:rating_ids]
      flash[:error] = pat(:destroy_many_error, :model => 'rating')
      redirect(url(:ratings, :index))
    end
    ids = params[:rating_ids].split(',').map(&:strip)
    ratings = Rating.find(ids)
    
    if Rating.destroy ratings
    
      flash[:success] = pat(:destroy_many_success, :model => 'Ratings', :ids => "#{ids.to_sentence}")
    end
    redirect url(:ratings, :index)
  end
end
