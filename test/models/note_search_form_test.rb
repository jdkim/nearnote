require "test_helper"

class NoteSearchFormTest < ActiveSupport::TestCase
  setup do
    @user1 = User.create!(email: "aaa@example.com", password: "password", confirmed_at: Time.now)
    @user2 = User.create!(email: "bbb@example.com", password: "password", confirmed_at: Time.now)
    @note1 = Note.create!(title: "aaa", updated_at: 1.days.ago, user: @user1)
    @note2 = Note.create!(title: "bbb", updated_at: 3.day.ago, user: @user2)
    @cache_key = "dummy-cache-key"
  end

  test "should searchable by title" do
    form = NoteSearchForm.new({ title: "aaa" }, @cache_key)
    result = form.search

    assert_includes result, @note1
    assert_not_includes result, @note2
  end

  test "should searchable by author" do
    form = NoteSearchForm.new({ author: "aaa@example.com" }, @cache_key)
    result = form.search

    assert_includes result, @note1
    assert_not_includes result, @note2
  end

  test "should searchable by updated_at start date" do
    form = NoteSearchForm.new({ start_date: 2.days.ago.to_date }, @cache_key)
    result = form.search

    assert_includes result, @note1
    assert_not_includes result, @note2
  end

  test "should searchable by updated_at end date" do
    form = NoteSearchForm.new({ end_date: 2.days.ago.to_date }, @cache_key)
    result = form.search

    assert_includes result, @note2
    assert_not_includes result, @note1
  end

  test "should searchable by updated_at start and end date" do
    note3 = Note.create!(title: "ccc", updated_at: 5.day.ago, user: @user1)
    form = NoteSearchForm.new({ start_date: 4.days.ago.to_date, end_date: 2.days.ago.to_date }, @cache_key)
    result = form.search

    assert_includes result, @note2
    assert_not_includes result, @note1
    assert_not_includes result, note3
  end

  test "should be invalid when end_date is before start_date" do
    form = NoteSearchForm.new({ start_date: 2.days.ago.to_date, end_date: 4.days.ago.to_date }, @cache_key)
    assert_not form.valid?
  end
end
