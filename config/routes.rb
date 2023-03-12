Rails.application.routes.draw do
  get "/healthcheck", to: proc { [200, {}, ["Ok"]] }
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  require 'sidekiq/web'

  mount Sidekiq::Web => '/sidekiq'


  namespace :account_block, default: {format: :json} do
    resource :accounts
    resources :ratings
    get 'accounts/privacy_policy', to: "accounts#privacy_policy"
    get 'accounts/get_hr_details', to: "accounts#get_hr_details"

    get 'all_users_feedbacks', to: 'ratings#all_users_feedbacks'
    get 'user_feedback', to: 'ratings#user_feedback'
    delete 'delete_ratings', to: 'ratings#delete_ratings'
  end

  namespace :bx_block_roles do
    resources :roles
  end

  namespace :bx_block_push_notifications do
    resources :push_notifications
    post 'device_token', to: "push_notifications#device_token"
    post 'send_notifications', to: "push_notifications#send_notifications"
  end

  namespace :bx_block_companies do
    resources :companies
    get 'get_all_details', to: "companies#get_all_details"
    get 'get_coaches', to: "companies#get_coaches"
    get 'get_employees', to: "companies#get_employees"
    get 'get_hrs', to: "companies#get_hrs"
    delete 'delete_user', to: "companies#delete_user"
    put 'update_company', to: 'companies#update_company'
    get 'get_company', to: 'companies#get_company'
    get 'coach_expertise', to: 'companies#coach_expertise'
  end

  namespace :bx_block_admin do
    resources :admins
    post 'create_coach', to: "admins#create_coach"
    get 'get_coach', to: "admins#get_coach"
    put 'update_coach', to: "admins#update_coach"
    get 'get_hr', to: "admins#get_hr"
    post 'update_hr', to: "admins#update_hr"
    delete 'delete_hr', to: "admins#delete_hr"

  end

  namespace :bx_block_wellbeing do
    resources :well_beings
    get 'all_categories', to: 'well_beings#all_categories'
    get 'question_categories', to: 'well_beings#question_categories'
    get 'question', to: 'well_beings#question'
    post 'user_answer', to: 'well_beings#user_answer'
    get 'get_result',to: 'well_beings#get_result'
    get 'user_strength',to: 'well_beings#user_strength'
    get 'insights',to: 'well_beings#insights'
    delete 'delete_answers', to: 'well_beings#delete_answers'
  end

  namespace :bx_block_login do
    resources :logins, only: [:create]
    delete 'logins/logout', to: "logins#destroy"
  end

  namespace :bx_block_contact_us, default: {format: :json} do
    resource :contacts
  end

  namespace :bx_block_attachment do
    resources :attachments
    post 'attachments/save_print_properties'
  end

  namespace :bx_block_assessmenttest do
    resources :choose_answers, only: [:create]
    resources :select_answers, only: [:create]
    resources :assess_yourself_choose_answers, only: [:create]
    resources :assess_select_answers, only: [:create]
    resources :focus_areas, only: [:create]
    resources :goals, only: [:create]
    resources :action_items, only: [:create]
    get 'personality_test_questions', to: 'assesment_test_questions#questions'
    get 'niya_test_questions', to: 'assesment_test_questions#questions'
    get 'show_personality_test_answer', to: 'assesment_test_answers#show'
    get 'assess_yourself_test_questions', to: 'assess_yourself_questions#questions'
    get 'show_assess_yourself_test_answer', to: 'assess_yourself_answers#show'

    get '/completed_goals', to: 'goals#completed_goals'
    get '/current_goals', to: 'goals#current_goals'
    get '/goal_boards', to: 'goals#goal_boards'
    put '/update_goal', to: 'goals#update'
    delete '/destroy_goal', to: 'goals#destroy'
    # put '/completed_goal', to: 'goals#completed_goals'
    # post '/complete_goal_date', to: 'goals#complete_date'

    get '/completed_actions', to: 'action_items#completed_actions'
    get '/current_actions', to: 'action_items#current_actions'
    put '/update_action', to: 'action_items#update'
    delete '/destroy_action', to: 'action_items#destroy'
    put '/complete_action', to: 'action_items#complete'
    post '/complete_action_date', to: 'action_items#complete_date'
    get  '/my_progress', to: 'focus_areas#my_progress'
    get  '/start_game', to: 'action_items#start_game'

  end
  namespace :bx_block_forgot_password do
    post 'otps', to: 'otps#create'
    post 'otp_confirmations', to: 'otp_confirmations#otp_confirmation'
     post 'forgot_password', to: 'otp_confirmations#create'
  end

  namespace :bx_block_calendar do
    resources :booked_slots, only: [:create, :index]
    get "booked_slots/view_coach_availability"
    get "booked_slots/current_coach"
    get "booked_slots/past_coach"
    get "booked_slots/coach_with_upcoming_appointments"
    get "booked_slots/coach_with_past_appointments"
    get "booked_slots/coach_upcoming_appointments"
    get "booked_slots/coach_past_appointments"
    get "booked_slots/user_appointments"
    get "booked_slots/video_call"
    post "booked_slots/user_action_item"

  end

  namespace :bx_block_time_tracking_billing do
    resources :time_tracks, only: [:index]
    resources :summary_tracks, only: [:index]
  end

  put 'update_profile', to: 'bx_block_profile/profiles#update_bio'
  get 'profile_details', to: 'bx_block_profile/profiles#profile_details'
  get '/motions', to: 'bx_block_assessmenttest/motions#index'
  post '/select_motion', to: 'bx_block_assessmenttest/motions#select_motion'
  post '/select_motion_answers', to: 'bx_block_assessmenttest/motions#select_motion_answer'
  get '/emo_journey_status', to: 'bx_block_assessmenttest/motions#emo_journey_status'

  get '/conversation', to: 'bx_block_chat/chats#conversation'
  get '/delete_conversation', to: 'bx_block_chat/chats#delete_conversation'
  get '/assess_score', to: 'bx_block_assessmenttest/assess_select_answers#assess_score'
  delete '/delete_assess_answer', to: 'bx_block_assessmenttest/assess_select_answers#delete_assess_answer'
  delete '/delete_answer', to: 'bx_block_assessmenttest/assesment_test_questions#delete_answer'






  namespace :bx_block_appointment_management do
    resources :availabilities
  end

  # namespace :bx_block_upload do
  #   resources :audios, only: [:audio_list, :video_list, :docs_list]
  # end


  get '/audio_list', to: 'bx_block_upload/audios#audio_list'
  get '/artical_list', to: 'bx_block_upload/audios#docs_list'
  get '/video_list', to: 'bx_block_upload/audios#video_list'
  get '/suggestion', to: 'bx_block_upload/audios#suggestion'
end