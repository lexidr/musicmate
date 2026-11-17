class ComparisonChannel < ApplicationCable::Channel
  def subscribed
    comparison = Comparison.find_by(invite_token: params[:token])

    if comparison&.participant?(current_user)
      stream_for comparison
    else
      reject
    end
  end
end
