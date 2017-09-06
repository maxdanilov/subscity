def is_authenticated?
	!current_user_id.nil?
end

def current_user
	if is_authenticated?
		@user ||= Account.find(current_user_id) rescue nil
	else
		@user = nil
	end
	@user
end

def current_user_id
	session[:user_id] rescue nil
end

def set_current_user(user)
	session[:user_id] = user.nil? ? nil : user.id
end

def login user
	set_current_user user
end

def logout
	session.clear
end

def current_role
	current_user.role rescue nil
end

def admin?
	#ADMIN_IP == request.ip
	return true if is_role? :admin
	false
end

def set_redirect_path path
	session[:redirect_path] = path
end

def get_redirect_path
	value = session[:redirect_path]
	set_redirect_path nil
	value ||= :index
	value
end

def is_role? (role = :any)
	return false unless is_authenticated?
	role == :any or role == nil or role == current_role.to_sym
end

def auth_allow_for_role (role = :any, redirect_path = request.path)
	set_redirect_path redirect_path
	redirect(url(:auth, :login)) unless is_role?(role)
end