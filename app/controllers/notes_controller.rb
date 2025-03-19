class NotesController < ApplicationController
  before_action :authenticate_user!, except: %i[index show]
  before_action :set_note, only: %i[update destroy]

  def index
    @note_search_form = NoteSearchForm.new(search_params)
    note_ids = search_note_ids(@note_search_form)

    @notes = Note.where(id: note_ids)
                 .order_by(params[:sort_column], params[:sort_direction])
                 .page(params[:page])
    @sort_column = params[:sort_column]
    @sort_direction = params[:sort_direction]
  end

  def show
    @note = Note.find_by!(uuid: params[:id])
  end

  def new
    @note = current_user.notes.new()
  end

  def create
    @note = current_user.notes.new(note_params)

    if @note.save
      redirect_to note_path(@note), notice: "Note was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @note = Note.find_by!(uuid: params[:id])

    unless @note.user == current_user
      flash.now[:alert] = "You do not have permission to edit this note."
      render template: "notes/show", status: :forbidden
    end
  end

  def update
    if @note.update(note_params)
      redirect_to note_path(@note), notice: "Note was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @note.destroy
    redirect_to notes_path, notice: "Note was successfully deleted."
  end

  private

  def set_note
    @note = current_user.notes.find_by!(uuid: params[:id])
  end

  def note_params
    params.require(:note).permit(:title, :body)
  end

  def search_params
    params.fetch(:q, {}).permit(:title, :author, :start_date, :end_date)
  end

  # Cache search results if validation passed.
  # if validation failed, return the last successful search result (if cache exist).
  def search_note_ids(form)
    if form.valid?
      cache_key = SecureRandom.uuid
      session[:last_valid_note_ids_search] = cache_key
      form.search_ids(Note, cache_key)
    else
      Rails.cache.read(session[:last_valid_note_ids_search]) || []
    end
  end
end
