Padrino.configure_apps do
  # enable :sessions
  set :session_secret, ENV['SC_COOKIES_SECRET']
  #set :protection, true
  set :protection, :except => :path_traversal # 0.12 update
  set :protect_from_csrf, false #true - every post request was 403 cause of it
end

# Mounts the core application for this project
Padrino.mount('Subscity::App', :app_file => Padrino.root('app/app.rb')).to('/')
