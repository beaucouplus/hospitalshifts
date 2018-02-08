Rails.application.routes.draw do
  get 'shifts/new'

  get 'shifts/create'

  get 'shifts/index'

  get 'shifts/edit'

  get 'shifts/update'

  get 'workers/new'

  get 'workers/create'

  get 'workers/index'

  get 'workers/edit'

  get 'workers/update'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
