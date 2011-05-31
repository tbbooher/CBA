if defined? GovKit
  GovKit.configure do |config|
    # Get an API key for Sunlight's Open States project here:
    # http://services.sunlightlabs.com/accounts/register/
    config.sunlight_apikey = 'f25dd21268c7474bb9d75422887ecc46'

    ##API key for Votesmart
    # http://votesmart.org/services_api.php
    config.votesmart_apikey = '1ea9a7b3c110a813a05aec2592389761'

    # API key for NIMSP. Request one here:
    # http://www.followthemoney.org/membership/settings.phtml
    config.ftm_apikey = 'YOUR_FTM_API_KEY'

    # Api key for OpenCongress
    # http://www.opencongress.org/api
    config.opencongress_apikey = '24bfbe695c7ac1f497faeb61df83d3cb30d20364'
    
    # Technorati API key
    config.technorati_apikey = 'YOUR_TECHNORATI_APIKEY'
    
    # Other things you could set here include alternate URLs for
    # the APIs. See GovKit::Configuration for available attributes.
  end
end
