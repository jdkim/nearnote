class UsersController < ApplicationController
  def show
    @user = User.find_by!(email: params[:email])
    @note_search_form = NoteSearchForm.new(search_params)
    note_ids = search_note_ids(@note_search_form, @user)

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

  # Cache search results if validation passed.
  # if validation failed, return the last successful search result (if cache exist).
  def search_note_ids(form, user)
    if form.valid?
      cache_key = SecureRandom.uuid
      session[:last_valid_user_note_ids_search] = cache_key
      form.search_ids(user.notes, cache_key)
    else
      Rails.cache.read(session[:last_valid_user_note_ids_search]) || []
    end
  end
end
