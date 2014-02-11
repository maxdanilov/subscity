Subscity::Admin.controllers :screenings do
  get :index do
    @title = "Screenings"
    @screenings = Screening.all
    render 'screenings/index'
  end

  get :new do
    @title = pat(:new_title, :model => 'screening')
    @screening = Screening.new
    render 'screenings/new'
  end

  post :create do
    @screening = Screening.new(params[:screening])
    if @screening.save
      @title = pat(:create_title, :model => "screening #{@screening.id}")
      flash[:success] = pat(:create_success, :model => 'Screening')
      params[:save_and_continue] ? redirect(url(:screenings, :index)) : redirect(url(:screenings, :edit, :id => @screening.id))
    else
      @title = pat(:create_title, :model => 'screening')
      flash.now[:error] = pat(:create_error, :model => 'screening')
      render 'screenings/new'
    end
  end

  get :edit, :with => :id do
    @title = pat(:edit_title, :model => "screening #{params[:id]}")
    @screening = Screening.find(params[:id])
    if @screening
      render 'screenings/edit'
    else
      flash[:warning] = pat(:create_error, :model => 'screening', :id => "#{params[:id]}")
      halt 404
    end
  end

  put :update, :with => :id do
    @title = pat(:update_title, :model => "screening #{params[:id]}")
    @screening = Screening.find(params[:id])
    if @screening
      if @screening.update_attributes(params[:screening])
        flash[:success] = pat(:update_success, :model => 'Screening', :id =>  "#{params[:id]}")
        params[:save_and_continue] ?
          redirect(url(:screenings, :index)) :
          redirect(url(:screenings, :edit, :id => @screening.id))
      else
        flash.now[:error] = pat(:update_error, :model => 'screening')
        render 'screenings/edit'
      end
    else
      flash[:warning] = pat(:update_warning, :model => 'screening', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy, :with => :id do
    @title = "Screenings"
    screening = Screening.find(params[:id])
    if screening
      if screening.destroy
        flash[:success] = pat(:delete_success, :model => 'Screening', :id => "#{params[:id]}")
      else
        flash[:error] = pat(:delete_error, :model => 'screening')
      end
      redirect url(:screenings, :index)
    else
      flash[:warning] = pat(:delete_warning, :model => 'screening', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy_many do
    @title = "Screenings"
    unless params[:screening_ids]
      flash[:error] = pat(:destroy_many_error, :model => 'screening')
      redirect(url(:screenings, :index))
    end
    ids = params[:screening_ids].split(',').map(&:strip)
    screenings = Screening.find(ids)
    
    if Screening.destroy screenings
    
      flash[:success] = pat(:destroy_many_success, :model => 'Screenings', :ids => "#{ids.to_sentence}")
    end
    redirect url(:screenings, :index)
  end
end
