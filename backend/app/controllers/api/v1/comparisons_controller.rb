module Api
  module V1
    class ComparisonsController < ApplicationController
      before_action :authenticate_user!
      before_action :find_comparison, only: %i[show join]

      def create
        comparison = Comparison.create_for!(current_user)
        render_success(comparison_data(comparison), status: :created)
      rescue Comparison::Error => error
        render_error("COMPARISON_ERROR", error.message, status: :unprocessable_entity)
      end

      def show
        if comparison.completed? && !comparison.participant?(current_user)
          return render_error("FORBIDDEN", "Это сравнение принадлежит другим пользователям", status: :forbidden)
        end

        render_success(comparison_data(comparison))
      end

      def join
        comparison.join!(current_user)
        render_success(comparison_data(comparison))
      rescue Comparison::Error => error
        render_error("COMPARISON_ERROR", error.message, status: :unprocessable_entity)
      end

      private

      attr_reader :comparison

      def find_comparison
        @comparison = Comparison.find_by!(invite_token: params[:token])
      end

      def comparison_data(comparison)
        result = comparison.result

        {
          invite_token: comparison.invite_token,
          invite_url: "#{frontend_url}/compare/#{comparison.invite_token}",
          status: comparison.status,
          score: comparison.score,
          creator: user_data(comparison.creator),
          guest: user_data(comparison.guest),
          common_artists: result ? result[:common_artists] : [],
          common_tracks: result ? result[:common_tracks] : [],
          is_creator: comparison.creator == current_user,
          can_join: comparison.waiting? && comparison.creator != current_user
        }
      end

      def user_data(user)
        return unless user

        {
          id: user.id,
          name: user.name,
          avatar_url: user.avatar_url
        }
      end

      def frontend_url
        ENV.fetch("FRONTEND_URL", "http://localhost:5173")
      end
    end
  end
end
