require 'test_helper'

class PageTest < ActiveSupport::TestCase

  def setup
    Page.delete_all
    @long_text = "Lorem ipsum dolor sit amet, consectetur adipisicing elit, \
      sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim \
      veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo \
      consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum \
      dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident"
  end

  test "sould not save without a title and a body" do
    p = Page.new
    assert !p.valid?, "A page without a title and body should not be valid"
    p.title = 'Testtitle'
    assert !p.valid?, "A page with a title but no body should not be valid"
    p.body = 'lorem ipsum'
    assert p.valid?, "A page with a title and a body should be valid"
  end

  test "Title should be unique" do
    p1 = Page.new(:title => "My Title", :body => 'Lorem', :is_draft => false)
    p2 = Page.new(:title => "My Title", :body => 'Lorem', :is_draft => false)

    assert p1.save, "Should save if title is unique"
    assert !p2.save, "Should not save with the same title again."
  end

  test "A comment should have a body" do
    p1 = Page.new(:title => "My Title", :body => 'Lorem', :is_draft => false)
    p1.comments.build( :email => 'test@server.to', :comment => '', :is_draft => false)
    assert !p1.save
  end

  test "Long titles should be truncated for permalinks" do
    p1 = Page.new(:title => @long_text, :body => "Parag One\n\nParag Two", :is_draft => false)
    assert p1.short_title_for_url =~ /^Lorem ipsum/, "Start of text should be returned"
    assert p1.short_title_for_url =~ /\$$/, "Truncated url should end with $-sign"
    assert p1.short_title_for_url != @long_text, "Title should be truncated"
  end

  test "Page select should not include templates" do
    Page.delete_all
    template_page = Page.create(:title => 'This is a template page',
                                :body => "I'm a template",
                                :is_template => true,
                                :is_draft => false)
    standard_page = Page.create(:title => 'This is a standard page', :body => "Standard", :is_draft => false)
    sp = Page.first
    tp = Page.templates.first
    assert sp.title == 'This is a standard page', 'First without param is_template should be the standard page'
    assert tp.title == 'This is a template page', 'Using Page.templates.first should be the template page'
  end

  test "A page marked as draft should not be in the default scope" do
    Page.delete_all
    online_page = Page.create(:title => 'This is online',
                                :body => "I'm visible",
                                :is_template => false,
                                :is_draft => false)
    draft_page = Page.create(:title => 'This is offline',
                                :body => 'I am hidden',
                                :is_template => false,
                                :is_draft => true)
    assert Page.published.count == 1, "Drafts should not be counted in default scope"
    assert Page.drafts.first.body == 'I am hidden', "Scope draft should fetch first draft page"
  end


  test "A page should have a referecne to the page_template" do
    Page.delete_all
    online_page = Page.create(:title => 'This is a Template',
                                :body => "A Template Body",
                                :is_template => true,
                                :is_draft => false)
    derived_page = Page.create(:title => 'This is derived from This is a Template',
                                :body => 'Some Text',
                                :is_template => false,
                                :is_draft => false,
                                :template_id => online_page.to_param)
    assert derived_page.derived?, "This should be a derived page"
    assert derived_page.template == online_page
  end


end
