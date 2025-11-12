# frozen_string_literal: true

resources :workloads, only: %w[index]

# Project-scoped workload routes
scope '/projects/:project_id' do
  resources :workloads, only: %w[index], as: :project_workloads
  resource :wl_project_settings, only: %i[show update], path: 'workload_settings'
end

resources :wl_user_datas, only: %w[edit update]

resources :wl_national_holiday
resources :wl_user_vacations

resources :wl_user_allocations do
  collection do
    post :bulk_update
  end
end

resources :wl_issue_allocations, only: %i[index destroy] do
  collection do
    post :bulk_update
    post :reset
    post :auto_distribute
  end
end
