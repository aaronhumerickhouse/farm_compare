require 'selenium-webdriver'
require 'rspec'

describe 'Selenium Sample' do
	before :all do 
		@driver = Selenium::WebDriver.for :firefox
		@driver.get 'http://bit.ly/watir-example'

		@wait = Selenium::WebDriver::Wait.new(:timeout => 10)

	end
	it 'drives the example', :group_2 => true do

		name_element = @driver.find_element id: 'entry_1000000'
		name_element.send_keys "Aaron Humerickhouse"

		story_element = @driver.find_element id: 'entry_1000001'
		story_element.send_keys 'I am a test automation engineer trying to figure out what the best way to run a distributed automation framework in parallel.'

		#radio buttons
		watir_radio_element = @driver.find_element id: 'group_1000002_1'
		watir_radio_element.click
		expect(watir_radio_element.selected?).to be true

		selenium_radio_element = @driver.find_element id: 'group_1000002_2'
		expect(selenium_radio_element.selected?).to be false
		selenium_radio_element.click
		expect(watir_radio_element.selected?).to be false
		expect(selenium_radio_element.selected?).to be true


		#checkbox buttons
		ruby_checkbox_element = @driver.find_element id: 'group_1000003_1'
		java_checkbox_element = @driver.find_element id: 'group_1000003_2'
		python_checkbox_element = @driver.find_element id: 'group_1000003_3'

		ruby_checkbox_element.click
		expect(ruby_checkbox_element.selected?).to be true
		expect(java_checkbox_element.selected?).to be false
		expect(python_checkbox_element.selected?).to be false

		#dropdown
		browser_dropdown_element = @driver.find_element id: 'entry_1000004'
		dropdown_options = browser_dropdown_element.find_elements(tag_name: 'option')
		dropdown_options.each do |option| 
			option.click if option.text == 'Firefox'
		end

		selected_option = dropdown_options.map { |option| option.text if option.selected? }.join
		expect(selected_option).to eq 'Firefox'

		#radio buttons
		happy_1_radio_element = @driver.find_element id: 'group_1000005_1'
		happy_2_radio_element = @driver.find_element id: 'group_1000005_2'
		happy_3_radio_element = @driver.find_element id: 'group_1000005_3'
		happy_4_radio_element = @driver.find_element id: 'group_1000005_4'
		happy_5_radio_element = @driver.find_element id: 'group_1000005_5'
		happy_1_radio_element.click
		expect(happy_1_radio_element.selected?).to be true
		expect(happy_2_radio_element.selected?).to be false
		expect(happy_3_radio_element.selected?).to be false
		expect(happy_4_radio_element.selected?).to be false
		expect(happy_5_radio_element.selected?).to be false

		item_1_1_radio_element = @driver.find_element id: 'group_1000006_1'
		item_1_2_radio_element = @driver.find_element id: 'group_1000006_2'
		item_1_3_radio_element = @driver.find_element id: 'group_1000006_3'
		item_1_4_radio_element = @driver.find_element id: 'group_1000006_4'
		item_1_5_radio_element = @driver.find_element id: 'group_1000006_5'
		item_1_5_radio_element.click
		expect(item_1_1_radio_element.selected?).to be false
		expect(item_1_2_radio_element.selected?).to be false
		expect(item_1_3_radio_element.selected?).to be false
		expect(item_1_4_radio_element.selected?).to be false
		expect(item_1_5_radio_element.selected?).to be true

		item_2_1_radio_element = @driver.find_element id: 'group_1000007_1'
		item_2_2_radio_element = @driver.find_element id: 'group_1000007_2'
		item_2_3_radio_element = @driver.find_element id: 'group_1000007_3'
		item_2_4_radio_element = @driver.find_element id: 'group_1000007_4'
		item_2_5_radio_element = @driver.find_element id: 'group_1000007_5'
		item_2_3_radio_element.click
		expect(item_2_1_radio_element.selected?).to be false
		expect(item_2_2_radio_element.selected?).to be false
		expect(item_2_3_radio_element.selected?).to be true
		expect(item_2_4_radio_element.selected?).to be false
		expect(item_2_5_radio_element.selected?).to be false

		#button
		submit_element = @driver.find_element id: 'ss-submit'
		submit_element.click

		#header on next page
		message_element = nil
		@wait.until { message_element = @driver.find_element css: 'div.ss-resp-message'}
		expect(message_element.text.start_with? 'Thanks!').to be true

	end

	after :all do
		@driver.quit
	end
end
