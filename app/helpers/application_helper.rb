# -*- encoding : utf-8 -*-

# Helpers for the entire application
# STYLE: Don't place methods here if they are used in one special controller only
#
module ApplicationHelper

  # yield :google_analytics in HTML-HEAD
  def insert_google_analytics_script
    if File::exist?(
         filename=File::join(Rails.root,"config/google_analytics.head")
       )
       File.new(filename).read.html_safe
    end
  end

  # insert google site search if file exists
  def insert_google_site_search
    if File::exist?(
         filename=File::join(Rails.root,"config/google_site_search.html")
       )
       File.new(filename).read.html_safe
    end
  end

  # Insert extra headers to html-head
  # Most of this meta-tags are configurable in `application.yml`
  def insert_extra_headers
    "<meta name='Language' content='#{t('locales.'+I18n.locale.to_s)}, #{I18n.locale}' />
    <meta name='Author' content='#{ENV['APPLICATION_CONFIG_copyright']}' />
    <meta name='publisher' content='#{ENV['APPLICATION_CONFIG_copyright']}' />
    <meta name='robots' content='index, follow, noarchive' />
    <meta name='distribution' content='global' />
    <meta name='page-topic' content='RAILS, Programming, Mac OS X, iOS, Web-Development' />
    <meta name='description' content='#{strip_tags(ENV['APPLICATION_CONFIG_name'])} | #{strip_tags(ENV['APPLICATION_CONFIG_slogan'])}' />
    <meta name='keywords' content='RAILS, CBA, Application Template, devise, cancan, omniAuth, Programming, Mac OS X, iOS, Web-Development' />
    <meta name='revisit-after' content='2 days' />
    <meta http-equiv='reply-to' content='#{ENV['APPLICATION_CONFIG_admin_notification_address']}' />
    ".html_safe
  end

  # Return `current_user.field` if current_user, otherwise return `default`
  # @param [String] fieldname - field of class {User}
  # @param [String] default - will be returned if no current_user exists.
  # @return String - current-user's field (may be nil if User.field not exists!) or `default`
  def current_user_field(fieldname,default='')
    if user_signed_in?
      current_user.try(fieldname) || ''
    else
      default
    end
  end

  # See the main-layout application.html.erb where this buttons
  # will be displayed at runtime. Renders partial 'home/action_buttons'
  def setup_action_buttons
    content_for :action_buttons do
      render :partial => '/home/action_buttons'
    end
  end

  # Insert a new file-field to form
  # @param [String] name - The name of the field
  # @param [FormHelper] f - The FormHelper of the form to insert.
  # @param [String] association - The detail-model we will insert fields for
  # @return the link_to_function-html-code.
  def link_to_add_fields(name,f,association)
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields  = f.fields_for(association,new_object, :child_index=>"new_#{association}") do |builder|
      render(association.to_s.pluralize+"/"+association.to_s.singularize + "_fields", :f => builder)
    end
    ui_link_to_function('add',name,"add_fields(this,\"#{association}\", \"#{escape_javascript(fields)}\")")
  end

  # Remove an attached file
  # Set the hidden field to destroy this detail-record on update-attributes
  # @param [String] name - Name of the field to remove
  # @param [FormHelper] f - FormHelper to use.
  def link_to_remove_fields(name, f)
    f.hidden_field(:_destroy) + "&nbsp;".html_safe + ui_link_to_function('delete',name,"remove_fields(this)")
  end

  # Check if paginate is on last page
  # @param [WillPaginate-Array] collection
  # @return Boolean - true if on last page
  def is_on_last_page(collection)
    collection.total_pages && (collection.current_page < collection.total_pages)
  end

  # Display errors for resource
  # @param [ActiveModel] resource
  # @return String - html-div id='error_explanation'
  def errors_for(resource)
    rc = ""
    if resource.errors.any?
      rc += "<div id='error_explanation'>"+
              "<h2>"+
                t(:errors, :count => resource.errors.count) + ": " +
                t(:prohibited_this_resource_from_being_saved, :resource => t(resource.class.to_s.downcase.to_sym)) +
              "</h2>"+
              "<ul>" +
                 resource.errors.full_messages.map { |msg|
                   "<li><b>"+ msg.split(" ",2)[0] + "</b>: " + msg.split(" ",2)[1] +"</li>"
                 }.join
            if defined? resource.attachments
              rc += "<ul>" +
                    resource.attachments.map { |p|
                       p.errors.map { |error|
                         "<li>" + p.errors[error].join(", ".html_safe) + "</li>"
                       }.join
                    }.join +
                    "</ul>"
            end
      rc += "</ul></div>"
      rc.html_safe
    end

  end

  # @return Integer current_user's roles_mask if current_user exists, 0 (Guest) otherwise
  def current_role
    current_user ? (current_user.roles_mask||0) : 0
  end

  # Force rendering of a given block with `format` and then switch back to
  # the format defined before.
  #
  # @param [ActionView] view - the view to use
  # @param [Symbol] format - force this format
  # @param [Block] - do this block with the forced format
  def with_format(view, format, &block)
    old_formats = view.formats
    view.formats = [:html]
    yield
    view.formats = old_formats
  end

  # added by Tim
  def format_votes(vote_hash)
    o = "<ul class=\"votes\">"
    o += "<li>For: #{vote_hash[:ayes]}</li>"
    o += "<li>Against:#{vote_hash[:nays]}</li>"
    o += "<li>Abstain:#{vote_hash[:abstains]}</li>"
    o += "<li>Present:#{vote_hash[:presents]}</li>"
    o += "</ul>"
    o.html_safe
  end

  def format_pie_chart(vote_hash)

  end

  def short_tally(vote_hash)
    "#{vote_hash[:ayes]}, #{vote_hash[:nays]}, #{vote_hash[:abstains]}, #{vote_hash[:presents]}"
  end

  # added by nate
  # cool, easy
  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = (column == sort_column) ? "current #{sort_direction}" : nil
    direction = (column == sort_column) && sort_direction == "asc" ? "desc" : "asc"
    link_to title, {:sort => column, :direction => direction}, {:class => css_class}
  end
  

  # @return Boolean - true if a partial named '_sidebar_left' exists for the current controller
  def sidebar_partial_exists?
    ['haml', 'html', 'html.erb'].each do |ext|
      return true if File::exist?(
        File::join( Rails.root, "app", "views", controller_name.underscore, "_sidebar_left.#{ext}")
      )
    end
    false
  end

  # @return String - Path of the sidebar-partial of the current controller
  def current_view_sidebar_left_path
    path = "/#{controller_name.underscore}/sidebar_left"
  end

  # A helper to load presenters
  # @param [Object] object - The object to be presented
  # @param [Class] klass - If not using OBJECTPresenter as class-name
  def present(object, klass=nil)
    klass ||= "#{object.class}Presenter".constantize
    presenter = klass.new(object, self)
    yield presenter if block_given?
    presenter
  end


  # Load a presenter and assign an Interpreter for it
  # @param [Object] object - The object to be presented
  # @param [Interpreter] interpreter - The interpreter to be used. If nil a new one will be initialized
  # @param [Class] klass - If not using OBJECTPresenter as class-name
  def interpret(object,interpreter=nil,klass=nil)
    presenter = present(object,klass)
    interpreter ||= Interpreter.new(object,presenter,self)
    presenter.interpreter = interpreter
    yield presenter if block_given?
    presenter
  end
  
end
