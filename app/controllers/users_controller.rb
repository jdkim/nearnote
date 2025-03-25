class UsersController < ApplicationController
  def show
    @user = User.find_by!(email: params[:email])
    @note_search_form = NoteSearchForm.new(search_params, @user.notes)
    note_ids = @note_search_form.search_ids(session)

    @notes = Note.where(id: note_ids)
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
