Subscity::Admin.controllers :cinemas do
  get :index do
    @title = "Cinemas"
    @cinemas = Cinema.all
    render 'cinemas/index'
  end

  get :new do
    @title = pat(:new_title, :model => 'cinema')
    @cinema = Cinema.new
    render 'cinemas/new'
  end

  post :create do
    @cinema = Cinema.new(params[:cinema])
    if @cinema.save
      @title = pat(:create_title, :model => "cinema #{@cinema.id}")
      flash[:success] = pat(:create_success, :model => 'Cinema')
      params[:save_and_continue] ? redirect(url(:cinemas, :index)) : redirect(url(:cinemas, :edit, :id => @cinema.id))
    else
      @title = pat(:create_title, :model => 'cinema')
      flash.now[:error] = pat(:create_error, :model => 'cinema')
      render 'cinemas/new'
    end
  end

  get :edit, :with => :id do
    @title = pat(:edit_title, :model => "cinema #{params[:id]}")
    @cinema = Cinema.find(params[:id])
    if @cinema
      render 'cinemas/edit'
    else
      flash[:warning] = pat(:create_error, :model => 'cinema', :id => "#{params[:id]}")
      halt 404
    end
  end

  put :update, :with => :id do
    @title = pat(:update_title, :model => "cinema #{params[:id]}")
    @cinema = Cinema.find(params[:id])
    if @cinema
      if @cinema.update_attributes(params[:cinema])
        flash[:success] = pat(:update_success, :model => 'Cinema', :id =>  "#{params[:id]}")
        params[:save_and_continue] ?
          redirect(url(:cinemas, :index)) :
          redirect(url(:cinemas, :edit, :id => @cinema.id))
      else
        flash.now[:error] = pat(:update_error, :model => 'cinema')
        render 'cinemas/edit'
      end
    else
      flash[:warning] = pat(:update_warning, :model => 'cinema', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy, :with => :id do
    @title = "Cinemas"
    cinema = Cinema.find(params[:id])
    if cinema
      if cinema.destroy
        flash[:success] = pat(:delete_success, :model => 'Cinema', :id => "#{params[:id]}")
      else
        flash[:error] = pat(:delete_error, :model => 'cinema')
      end
      redirect url(:cinemas, :index)
    else
      flash[:warning] = pat(:delete_warning, :model => 'cinema', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy_many do
    @title = "Cinemas"
    unless params[:cinema_ids]
      flash[:error] = pat(:destroy_many_error, :model => 'cinema')
      redirect(url(:cinemas, :index))
    end
    ids = params[:cinema_ids].split(',').map(&:strip)
    cinemas = Cinema.find(ids)
    
    if Cinema.destroy cinemas
    
      flash[:success] = pat(:destroy_many_success, :model => 'Cinemas', :ids => "#{ids.to_sentence}")
    end
    redirect url(:cinemas, :index)
  end
end
