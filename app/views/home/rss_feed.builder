atom_feed(:url => feed_path) do |feed|
   feed.title(ENV['APPLICATION_CONFIG_rss_title'])
   feed.updated(Time.now) #@feed_items.first ? @feed_items.first.updated_at : Time.now.utc )
   for item in @feed_items
     feed.entry(item.object, :url => item.url) do |entry|
       entry.title(item.title)
       begin
         content = ""
         if item.object.respond_to?(:render_body)
           with_format self, 'html' do
             content = item.object.render_body(nil).gsub( /\[EDIT_COMPONENT_LINK:([^\]]*)\]/,"" )
           end
         else
           content = sanitize(simple_format(item.body))
         end
         if defined? item.object.cover_picture
           content +=  image_tag(item.object.cover_picture.url(:medium))
         end
       rescue => e
         content = e.inspect
       end
       entry.content( content, :type => :html )
       entry.updated item.updated_at
       entry.author(item.name||'-')
     end
   end
end