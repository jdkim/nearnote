class NoteSearchForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :title, :string
  attribute :author, :string
  attribute :start_date, :date
  attribute :end_date, :date

  validate :start_date_must_be_before_end_date

  def initialize(attributes = nil, base_scope = Note)
    @base_scope = base_scope
    super(attributes)
  end

  # Cache search results if validation passed.
  # if validation failed, return the last successful search result (if cache exist).
  def search_ids(cache_key)
    if valid?
      notes = @base_scope.includes(:user)
      notes = filter_by_title(notes)
      notes = filter_by_author(notes)
      notes = filter_by_updated_at(notes)
      ids = notes.pluck(:id)

      Rails.cache.write(cache_key, ids, expires_in: 5.minutes)
      ids
    else
      Rails.cache.read(cache_key) || []
    end
  end

  private

  def filter_by_title(notes)
    return notes unless title.present?

    notes.where("title LIKE ?", "%#{title}%")
  end

  def filter_by_author(notes)
    return notes unless author.present?

    notes.joins(:user).where("users.email LIKE ?", "%#{author}%")
  end

  def filter_by_updated_at(notes)
    notes = notes.where(updated_at: start_date..) if start_date.present?
    notes = notes.where(updated_at: ..end_date) if end_date.present?
    notes
  end

  def start_date_must_be_before_end_date
    return unless start_date.present? && end_date.present?

    errors.add(:base, "The 'Updated at' end date must be on or after the start date.") if end_date < start_date
  end
end
