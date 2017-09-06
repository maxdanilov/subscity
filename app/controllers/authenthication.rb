Subscity::App.controllers :auth do
    get :login, :map => "/login" do
        if is_authenticated?
            redirect(url(:index))
        else
            render 'auth/login', layout: :layout
        end
    end

    post :login, :map => "/login" do
        if params[:email] && params[:password] && account = Account.authenticate(params[:email], params[:password])
            login(account)
            redirect(url(get_redirect_path))
        else
            redirect(url(:auth, :login))
        end
    end

    get :logout, :map => "/logout" do
        logout
        redirect(url(:index))
    end
end