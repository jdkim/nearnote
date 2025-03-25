class UsersController < ApplicationController
  def show
    @user = User.find_by!(email: params[:email])
    cache_key = "#{session.id}-#{self.class.name}"
    @note_search_form = NoteSearchForm.new(search_params, cache_key, @user.notes)
    @notes = @note_search_form.search
                              .order_by(params[:sort_column], params[:sort_direction])
                              .page(params[:page])

    @sort_column = params[:sort_column]
    @sort_direction = params[:sort_direction]
  end

  private

  def search_params
    params.fetch(:q, {}).permit(:title, :author, :start_date, :end_date)
  end
end
