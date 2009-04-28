openid_server 'openid_server', :controller => 'openid_server'

open_id_complete 'session', 
  { :controller => 'sessions', 
    :action     => 'create',
    :conditions => { :method => :get },
    :open_id_complete => true }

resource :session

login 'login',   :controller => 'sessions', :action => 'new'
logout 'logout', :controller => 'sessions', :action => 'destroy'

if ActiveRecord::Agent.activation_class
  activate 'activate/:activation_code', 
           :controller => ActiveRecord::Agent.activation_class.to_s.tableize, 
           :action => 'activate', 
           :activation_code => nil
  lost_password 'lost_password', 
                  :controller => ActiveRecord::Agent.activation_class.to_s.tableize,
                  :action => 'lost_password'
  reset_password 'reset_password/:reset_password_code', 
                 :controller => ActiveRecord::Agent.activation_class.to_s.tableize,
                 :action => 'reset_password',
                 :reset_password_code => nil
end

resources :entries, :member => { :media => :any,
                               :edit_media => :get,
                               :details => :any }
resources :categories
resources :tags

resource :site do |site|
  site.resources :entries, :categories
  if Site.table_exists?
    site.resources :performances, :requirements => { :site_id => Site.current.id }
  end
  site.resources *ActiveRecord::Content.symbols
end

resources *( ( ActiveRecord::Resource.symbols | 
               ActiveRecord::Content.symbols  | 
               ActiveRecord::Agent.symbols ) - 
              ActiveRecord::Container.symbols 
           )

resources(*(ActiveRecord::Container.symbols) - Array(:sites)) do |container|
  container.resources(*ActiveRecord::Content.symbols)
  container.resources :entries, :categories
end

resources :logos

resources(*(ActiveRecord::Logoable.symbols - Array(:sites))) do |logoable|
  logoable.resource :logo
end

resources :roles
resources :invitations, :member => { :accept => :get }

resources(*ActiveRecord::Stage.symbols - Array(:sites)) do |stage|
  stage.resources :performances
  stage.resources :invitations
  stage.resources :join_requests
end

resources :performances

root :controller => 'entries'
