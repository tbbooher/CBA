# -*- encoding : utf-8 -*-

# Helpers for the entire application
# STYLE: Don't place methods here if they are used in one special controller only
#
module ApplicationHelper

  # yield :google_analytics will be loaded in HTML-HEAD
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

  # Return the field if current_user or the default if not
  def current_user_field(fieldname,default='')
    if user_signed_in?
      current_user.try(fieldname) || ''
    else
      default
    end
  end

  # See the main-layout application.html.erb where this buttons
  # will be displayed at runtime.
  def setup_action_buttons
    content_for :action_buttons do
      render :partial => '/home/action_buttons'
    end
  end

  # Insert a new file-field to form
  def link_to_add_fields(name,f,association)
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields  = f.fields_for(association,new_object, :child_index=>"new_#{association}") do |builder|
      render(association.to_s.pluralize+"/"+association.to_s.singularize + "_fields", :f => builder)
    end
    ui_link_to_function('add',name,"add_fields(this,\"#{association}\", \"#{escape_javascript(fields)}\")")
  end

  # Remove an attached file
  def link_to_remove_fields(name, f)
    f.hidden_field(:_destroy) + "&nbsp;".html_safe + ui_link_to_function('delete',name,"remove_fields(this)")
  end

  # Check if paginate is on last page
  def is_on_last_page(collection)
    collection.total_pages && (collection.current_page < collection.total_pages)
  end

  # Display errors for resource
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

  def current_role
    current_user ? (current_user.roles_mask||0) : 0
  end
  
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
  
  def present(object, klass=nil)
    klass ||= "#{object.class}Presenter".constantize
    presenter = klass.new(object, self)
    yield presenter if block_given?
    presenter
  end

end
