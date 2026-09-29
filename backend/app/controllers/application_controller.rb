class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :render_invalid_record

  private

  def render_success(data, status: :ok)
    render json: { data: data }, status: status
  end

  def render_error(code, message, status:)
    render json: {
      error: {
        code: code,
        message: message
      }
    }, status: status
  end

  def render_not_found
    render_error("NOT_FOUND", "Запись не найдена", status: :not_found)
  end

  def render_invalid_record(error)
    message = error.record.errors.full_messages.join(", ")
    render_error("VALIDATION_ERROR", message, status: :unprocessable_entity)
  end
end
