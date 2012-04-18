#
# Load configuration from
# config/application.yml and config/user_db.yml
# and populate this into environment variables (heroku convention)
#

# If you need to have the users been stored in a different place than
# the rest of your data, just define config/user_db.yml.
# **THIS DOESN'T WORK WITH CBA YET BUT WILL BE IMPLEMENTED IN FURTHER RELEASES**
if File::exists?("#{Rails.root}/config/user_db.yml")
  USER_DATABASE=YAML.load_file("#{Rails.root}/config/user_db.yml")[Rails.env]
else
  USER_DATABASE={ 'use_remote_database' => false }
end

config_file = File.expand_path('../../config/application.yml', __FILE__)
if File.exist?(config_file)
  APPLICATION_CONFIG=YAML.load_file(config_file)[Rails.env]['application']
  CONSTANTS=YAML.load_file(config_file)[Rails.env]['constants']
  APPLICATION_CONFIG.each{|k,v| ENV["APPLICATION_CONFIG_#{k}"] = v.to_s }
  CONSTANTS.each{|k,v| ENV["CONSTANTS_#{k}"] = v.to_s}
end

# MAILSERVER settings
mailserver_file =  File.expand_path('../../config/mailserver_setting.yml', __FILE__)
if File.exist?(mailserver_file)
  YAML.load_file(mailserver_file).each{|k,v| ENV[k.to_s] = v.to_s}
end

# OMNI_AUTH settings
omniauth_file =  File.expand_path('../../config/omniauth_settings.yml', __FILE__)
if File.exist?(omniauth_file)
  YAML.load_file(omniauth_file).each{|k,v| ENV[k.to_s] = v.to_s}
end