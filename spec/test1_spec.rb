require 'selenium-webdriver'
require 'spec_helper.rb'

describe 'Selenium Sample' do
	

	it 'drives the example', :group_1 => true do
		@logger.info 'Entering Aaron Humerickhouse into name_element'
		@wait.until { @name_element = @driver.find_element id: 'entry_1000000' }
		@name_element.send_keys "Aaron Humerickhouse"

		@logger.info 'Filling in story_element'
		@wait.until { @story_element = @driver.find_element id: 'entry_1000001' }
		@story_element.send_keys 'I am a test automation engineer trying to figure out what the best way to run a distributed automation framework in parallel.'

		#radio buttons
		@logger.info 'Selecting driver radio buttons'
		@wait.until { @watir_radio_element = @driver.find_element id: 'group_1000002_1' }
		@watir_radio_element.click
		expect(@watir_radio_element.selected?).to be true

		@wait.until { @selenium_radio_element = @driver.find_element id: 'group_1000002_2' }
		expect(@selenium_radio_element.selected?).to be false
		@selenium_radio_element.click
		expect(@watir_radio_element.selected?).to be false
		expect(@selenium_radio_element.selected?).to be true


		#checkbox buttons
		@logger.info 'Selecting language checkbox'
		@wait.until { @ruby_checkbox_element = @driver.find_element id: 'group_1000003_1' }
		@wait.until { @java_checkbox_element = @driver.find_element id: 'group_1000003_2' }
		@wait.until { @python_checkbox_element = @driver.find_element id: 'group_1000003_3' }

		@ruby_checkbox_element.click
		expect(@ruby_checkbox_element.selected?).to be true
		expect(@java_checkbox_element.selected?).to be false
		expect(@python_checkbox_element.selected?).to be false

		#dropdown
		@logger.info 'Selecting Dropdown'
		@wait.until{ @browser_dropdown_element = @driver.find_element id: 'entry_1000004' }
		@browser_dropdown_element.click
		dropdown_options = @browser_dropdown_element.find_elements(tag_name: 'option')
		dropdown_options.each do |option| 
			@wait.until { option.displayed? }
			begin
				option.click if option.text == 'Firefox'
			rescue => ex
				raise ex
			end
		end

		selected_option = dropdown_options.map { |option| option.text if option.selected? }.join
		expect(selected_option).to eq 'Firefox'

		#radio buttons
		@logger.info 'Selecting happy radio element'
		@wait.until { @happy_1_radio_element = @driver.find_element id: 'group_1000005_1' }
		@wait.until { @happy_2_radio_element = @driver.find_element id: 'group_1000005_2' }
		@wait.until { @happy_3_radio_element = @driver.find_element id: 'group_1000005_3' }
		@wait.until { @happy_4_radio_element = @driver.find_element id: 'group_1000005_4' }
		@wait.until { @happy_5_radio_element = @driver.find_element id: 'group_1000005_5' }
		@happy_1_radio_element.click
		expect(@happy_1_radio_element.selected?).to be true
		expect(@happy_2_radio_element.selected?).to be false
		expect(@happy_3_radio_element.selected?).to be false
		expect(@happy_4_radio_element.selected?).to be false
		expect(@happy_5_radio_element.selected?).to be false

		@logger.info 'Selecting item radio elements'
		@wait.until { @item_1_1_radio_element = @driver.find_element id: 'group_1000006_1' }
		@wait.until { @item_1_2_radio_element = @driver.find_element id: 'group_1000006_2' }
		@wait.until { @item_1_3_radio_element = @driver.find_element id: 'group_1000006_3' }
		@wait.until { @item_1_4_radio_element = @driver.find_element id: 'group_1000006_4' }
		@wait.until { @item_1_5_radio_element = @driver.find_element id: 'group_1000006_5' }
		@item_1_5_radio_element.click
		expect(@item_1_1_radio_element.selected?).to be false
		expect(@item_1_2_radio_element.selected?).to be false
		expect(@item_1_3_radio_element.selected?).to be false
		expect(@item_1_4_radio_element.selected?).to be false
		expect(@item_1_5_radio_element.selected?).to be true

		@wait.until { @item_2_1_radio_element = @driver.find_element id: 'group_1000007_1' }
		@wait.until { @item_2_2_radio_element = @driver.find_element id: 'group_1000007_2' }
		@wait.until { @item_2_3_radio_element = @driver.find_element id: 'group_1000007_3' }
		@wait.until { @item_2_4_radio_element = @driver.find_element id: 'group_1000007_4' }
		@wait.until { @item_2_5_radio_element = @driver.find_element id: 'group_1000007_5' }
		@item_2_3_radio_element.click
		expect(@item_2_1_radio_element.selected?).to be false
		expect(@item_2_2_radio_element.selected?).to be false
		expect(@item_2_3_radio_element.selected?).to be true
		expect(@item_2_4_radio_element.selected?).to be false
		expect(@item_2_5_radio_element.selected?).to be false

		#button
		@logger.info 'Clicking submit button'
		@wait.until{ @submit_element = @driver.find_element id: 'ss-submit' }
		@submit_element.click

		#header on next page
		@logger.info 'Verifying navigation to next page'
		@wait.until { @message_element = @driver.find_element css: 'div.ss-resp-message' }
		expect(@message_element.text.start_with? 'Thanks!').to be true
	end
end
