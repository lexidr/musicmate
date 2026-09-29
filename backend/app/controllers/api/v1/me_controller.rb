module Api
  module V1
    class MeController < ApplicationController
      before_action :authenticate_user!

      def show
        render_success({
          id: current_user.id,
          name: current_user.name,
          email: current_user.email,
          avatar_url: current_user.avatar_url
        })
      end
    end
  end
end
