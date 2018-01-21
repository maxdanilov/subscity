Subscity::App.controllers :auth do
  get :login, map: '/login' do
    if authenticated?
      redirect(url(:index))
    else
      city = City.get_by_domain(request.subdomains.first)
      render 'auth/login', layout: :layout, locals: { city: city }
    end
  end

  post :login, map: '/login' do
    account = Account.authenticate(params[:email], params[:password])
    if account
      login(account)
      redirect(url(redirect_path))
    else
      redirect(url(:auth, :login))
    end
  end

  get :logout, map: '/logout' do
    logout
    redirect(url(:index))
  end
end
