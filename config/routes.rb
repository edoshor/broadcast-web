BroadcastWeb::Application.routes.draw do

  root to: 'pages#home'

  get 'transcoder_console', controller: :TranscoderConsole, action: :index
  post 'transcoder_console/perform'

  get 'transcoder_test', controller: :TranscoderTest, action: :index
  post 'transcoder_test/perform'
  get 'transcoder_test/status'
  get 'transcoder_test/host',controller: :TranscoderTest, action: :change_transcoder

  namespace :admin do
    resources :captures
    resources :sources
    resources :presets
    resources :schemes

    resources :transcoders do
      member do
        get :action
        get :create_slot
        get :start_slot
        get :stop_slot
        get :slots_status
        get :get_slots
        delete :delete_slot
      end
    end

    resources :events do
      member do
        get :action
        get :add_slot
        get :status
        delete :remove_slot
      end
    end
  end

end
