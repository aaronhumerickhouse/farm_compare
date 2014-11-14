require 'rspec'
require 'uri'
require 'logger'

RSpec.configure do |config|
	config.before :all do 
		@logger = Logger.new STDOUT
		@logger.datetime_format = '%y-%m-#d %H:%M:%S'
		@logger.formatter = proc do |severity, datetime, _, msg|
			format = "\n[#{severity} - #{datetime}] - #{msg}"
		end

		BROWSER ||= :firefox
		BROWSERSTACK_URL ||= "http://#{ENV['BS_USERNAME']}:#{ENV['BS_AUTHKEY']}@hub.browserstack.com/wd/hub"
		SAUCELABS_URL ||= "http://#{ENV['SAUCE_USERNAME']}:#{ENV['SAUCE_ACCESS_KEY']}@ondemand.saucelabs.com:80/wd/hub"

		case ENV['DRIVER']

		when 'SAUCELABS'
			@logger.info 'Creating Sauce Labs driver'
			caps = Selenium::WebDriver::Remote::Capabilities.firefox
			caps.platform = 'Windows 8'
			caps.version = '31'
			caps['browserName'] = 'firefox'
			caps['selenium-version'] = '2.43.0'

			@driver = Selenium::WebDriver.for(:remote, :url => URI(SAUCELABS_URL), :desired_capabilities => caps)

		when 'BROWSERSTACK'
			@logger.info 'Creating Browserstack driver'
			caps = Selenium::WebDriver::Remote::Capabilities.new
			caps['os'] = 'Windows'
			caps['os_version'] = '8'
			caps['browser'] = 'firefox'
			caps['browser_version'] = '31'

			caps['browserstack.selenium_version'] = '2.43.1'

			@driver = Selenium::WebDriver.for(:remote, :url => BROWSERSTACK_URL, :desired_capabilities => caps)

		when 'GRID'
			@logger.info 'Creating Selenium 2 Grid driver'
			caps = Selenium::WebDriver::Remote::Capabilities.new
			caps['platform'] = 'WIN8'
			caps['browserName'] = 'firefox'
			#only 31 is intalled

			hub = "http://10.0.2.162:4444/wd/hub"
			@driver = Selenium::WebDriver.for(:remote, :url => hub, :desired_capabilities => caps)
		when 'JENKINS'
			@logger.info 'Creating Jenkins Distributed driver'
			@driver = Selenium::WebDriver.for BROWSER
		when 'LOCAL'
			@logger.info 'Creating Local driver'

			@driver = Selenium::WebDriver.for BROWSER
		else
			@driver = Selenium::WebDriver.for BROWSER
		end

		@logger.info 'Navigating to watir-example'
		@driver.get 'http://bit.ly/watir-example'
		@wait = Selenium::WebDriver::Wait.new(:timeout => 10)
	end

	config.after :all do
		@logger.info 'Quitting driver'
		@driver.quit unless @driver.nil?
	end
end