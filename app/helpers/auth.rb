def authenticated?
  !current_user_id.nil?
end

def current_user
  if authenticated?
    @user ||= Account.find(current_user_id) rescue nil
  else
    @user = nil
  end
  @user
end

def current_user_id
  session[:user_id] rescue nil
end

def change_current_user(user)
  session[:user_id] = user.nil? ? nil : user.id
end

def login(user)
  change_current_user user
end

def logout
  session.clear
end

def current_role
  current_user.role rescue nil
end

def admin?
  return true if role? :admin

  false
end

def change_redirect_path(path)
  session[:redirect_path] = path
end

def redirect_path
  value = session[:redirect_path]
  change_redirect_path nil
  value ||= :index
  value
end

def role?(role = :any)
  return false unless authenticated?

  role == :any || role.nil? || role == current_role.to_sym
end

def auth_allow_for_role(role = :any, redirect_path = request.path)
  change_redirect_path redirect_path
  redirect(url(:auth, :login)) unless role?(role)
end
