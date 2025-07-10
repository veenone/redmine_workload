# frozen_string_literal: true

# Global routes
resources :workloads, only: %w[index]
resources :wl_user_datas, only: %w[edit update]
resources :wl_national_holiday
resources :wl_user_vacations

# Project-scoped routes
resources :projects do
  resources :workloads, only: %w[index]
end
