-- Copyright 2016 Sam Reid

-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at

--     http://www.apache.org/licenses/LICENSE-2.0

-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

local composer 	= require('composer')
local sqlite 	= require('sqlite3')
local widget 	= require('widget')
local font 		= 'HelveticaNeue' or system.nativeFont
local json 		= require('json')
local func 		= require('functions')
local scene 	= composer.newScene()
local ui_group 	= display.newGroup()

-------------------------
-- Forward declarations
-------------------------
local row = {}
local num_rides
local db_num_rides
local star_rating
local driver_name

-----------------
-- Refresh page
-----------------
local function refresh(event)
	if event.phase == 'ended' then
		composer.removeScene('authed')
		composer.gotoScene('authed')
	end
end

--------------------------
-- Create visual elements
--------------------------
-- Background
local background = display.newRect(0, 0, _W, _H)
background:setFillColor(100, 100, 100);
background:addEventListener('tap', background)
ui_group:insert(background)

-- Help button
local help_button = widget.newButton {
	left = 175,
	top = 20,
	labelColor = { default={ 0, 0, 0, 1 }, over={ 1, 1, 1, 1 } },
	id = 'help_button',
	onEvent = show_help,
	shape = 'roundedRect',
	width = 120,
	height = 40,
	cornerRadius = 2,
	fillColor = { default={ 1, 1, 1, 1 }, over={ 0, 0, 0, 1 } },
	strokeColor = { default={ 0, 0, 0, 1 }, over={ 0, 0, 0, 1 } },
	strokeWidth = 2
}
help_button:setEnabled(true)
help_button:setLabel('Show Help')
ui_group:insert(help_button)

-- Refresh button
local refresh_button = widget.newButton {
	left = 20,
	top = 20,
	labelColor = { default={ 0, 0, 0, 1 }, over={ 1, 1, 1, 1 } },
	id = 'refresh_button',
	onEvent = refresh,
	shape = 'roundedRect',
	width = 120,
	height = 40,
	cornerRadius = 2,
	fillColor = { default={ 1, 1, 1, 1 }, over={ 0, 0, 0, 1 } },
	strokeColor = { default={ 0, 0, 0, 1 }, over={ 0, 0, 0, 1 } },
	strokeWidth = 2
}
refresh_button:setEnabled(true)
refresh_button:setLabel('Refresh')
ui_group:insert(refresh_button)

---------------------
-- Open the database
---------------------
local path = system.pathForFile('juber.db', system.DocumentDirectory)
local db = sqlite3.open(path)

-------------------------------------------
-- Test&Set Credentials - Bail out if fail
-------------------------------------------
native.setActivityIndicator(true) -- we use an indicator to notify peeps who click the 'refresh' button that something actually happened

for db_row in db:nrows('SELECT * FROM auth') do
	if db_row['user_id'] == nil or
		db_row['token'] == nil or
		db_row['user_id'] == '' or
		db_row['token'] == '' then
		
		print('Error selecting Uber token from local db')
		generic_error_fatal()
	else
		row['user_id'] = db_row['user_id']
		row['token'] = db_row['token']
	end
end


-----------------------------------------------
-- Parse what we want out of the Uber responses
-----------------------------------------------
function parse_user_rating(response)
	local response = json.decode(response)
	for rating in string.gmatch(response['message'], '%S+') do
		-- get star rating
		if tonumber(rating) ~= nil then -- loop through each of the message segments until something looks like a star rating
			if debug_gen then
				print('Current Uber rating: ' ..rating)
			end
			return rating
		end
	end
end

function parse_ride_history(response)
	local response = json.decode(response) -- what does this look like if the user has no Uber rides yet?
	-- get number of trips
	local num_rides = tonumber(#response['trips'])
	if debug_gen then
		print('Current # rides: ' ..num_rides)
	end
	return num_rides
end

------------------------
-- Save to db functions
------------------------
function save_ride_history(event)
	if event.isError then
		print(event.response)
		generic_error_fatal()
	else
		local num_rides = parse_ride_history(event.response) -- get number of trips
		local ride_history = json.decode(event.response)
		-- process and save to db
		for key, trip in pairs(ride_history['trips']) do
			local stmt = "INSERT OR IGNORE INTO history (num_rides, most_recent_ride) VALUES ('" ..num_rides.. "', '" ..trip['date'].. "')"
			db:exec(stmt)
			if db:errcode() ~= 0 then
				print(db:errcode(), db:errmsg())
				generic_error_fatal()
			end
			break -- break after first (latest) trip
		end
	end
end

function save_user_rating(event)
	if event.isError then
		print(event.response)
		generic_error_fatal()
	else
		local rating = parse_user_rating(event.response)
		local stmt = "INSERT OR IGNORE INTO star_rating (rating) VALUES ('" ..rating.. "')"
		db:exec(stmt)
		if db:errcode() ~= 0 then
			print(db:errcode(), db:errmsg())
			generic_error_fatal()
		end
	end
end

function update_db()
	-- save star rating
	local body = '{"locale":"en_GB","uuid":"' ..row['user_id'].. '","problem_id":"e9302f73-8625-427f-abf7-dbe7ab25af7d","token":"' ..row['token'].. '"}'
	call_uber('https://cn-dc1.geixahba.com/support/tickets', 'POST', nil, body, save_user_rating)

	-- save history
	call_uber('https://cn-dc1.oojoovae.org/support/users/' ..row['user_id'].. '/trips?user_type=client&locale=en_GB&token=' ..row['token'].. '&offset=0&limit=500', 'GET', nil, nil, save_ride_history)
end


------------------
-- Check History
------------------
for row in db:urows("SELECT COALESCE((SELECT MAX(num_rides) FROM history), 0)") do
	db_num_rides = tonumber(row) -- get number of rides out of this for loop
	if db_num_rides <= 0 then -- no history = likely a first time user (or something has gone terribly wrong)
		
		update_db()
		native.setActivityIndicator(false)

		-- display help
		native.showAlert('Welcome! Now what?',
			'Looks like it\'s your first time using ' ..app_name.. '! Here\'s the low-down: ' ..app_name.. ' will calculate the star rating your most recent Uber driver gave you. You need to open ' ..app_name.. ' after each ride otherwise the rating it calculates won\'t be accurate. Have fun!', {'Okay'})

		local driver_text = {
			text = 'Come back after you\'ve taken a ride',
			x = 160,
			y = 200,
			width = 300,
			align = 'center',
			font = font,
			fontSize = 26,
			anchorY = 0,
		}
		-- supporting text for page
		local driver_text = display.newText(driver_text)
		driver_text:setTextColor(0, 0, 0)
		ui_group:insert(driver_text)
	end
end

-----------------------------------------------------------
-- If not a new user we set num_rides and star_rating here
-- Here is where we'd get the drivers name
-----------------------------------------------------------
function get_ride_history(event)
	if event.isError then
		print(event.response)
		generic_error_fatal()
	else
		num_rides = parse_ride_history(event.response) -- get number of trips

		local ride_history = json.decode(event.response) -- what does this look like if the user has no Uber rides yet?
		-- process and save to db
		for key, trip in pairs(ride_history['trips']) do
			driver_name = trip['driver_name']
			break -- break after first loop (most recent trip)
		end

		native.setActivityIndicator(false) -- turn spinner off
		main_func()
	end
end

call_uber('https://cn-dc1.oojoovae.org/support/users/' ..row['user_id'].. '/trips?user_type=client&locale=en_GB&token=' ..row['token'].. '&offset=0&limit=500', 'GET', nil, nil, get_ride_history)

function get_stars(event)
	if event.isError then
		print(event.response)
		generic_error_fatal()
	else
		star_rating = parse_user_rating(event.response)
	end
end

local body = '{"locale":"en_GB","uuid":"' ..row['user_id'].. '","problem_id":"e9302f73-8625-427f-abf7-dbe7ab25af7d","token":"' ..row['token'].. '"}'
call_uber('https://cn-dc1.geixahba.com/support/tickets', 'POST', nil, body, get_stars)


function main_func()
	---------------------------------------------------------------------------------------------------------------
	-- So where are we at?
	-- We've set up the pages visual elements
	-- We've checked the status of the history table in the db
	-- db_num_rides set
	-- 		If they're a new user to this app, we've populated the history and star rating from Uber's API
	--		db_num_rides = 0
	-- We've grabbed the ride history from Uber
	-- num_rides set
	-- 		We need that so we can check how many rides have been taken since the app was last opened
	-- We've grabbed the star rating from Uber
	-- star_rating set

	-- Now what?
	-- We compare db_num_rides with num_rides and decide whether we calculate
	-- If we do, we already have the variables required to run do_calc()
	-- Then we update the local database so:
	-- 		db_num_rides == num_rides
	--		b == star_rating (b is really db_star_rating, we just don't use db_star_rating anywhere else though)
	---------------------------------------------------------------------------------------------------------------
	if db_num_rides <= 0 then
		---------------------------------------------------
		-- This gets called if it's the first time the user
		-- is opening the app. Sucky, I know.
		---------------------------------------------------
		if debug_gen then
			print('db_num_rides == 0')
		end
		return
	end

	if debug_gen then
		print('# rides database: ' ..db_num_rides)
		print('# rides Uber API: ' ..num_rides)
	end

	if db_num_rides == num_rides then
		-----------------------------------------------------------------------
		-- No rides have been taken since last opening the app
		-- We check if we can calculate the rating from the most recent drive
		-- Otherwise we display a message saying the app is ready to go
		-----------------------------------------------------------------------
		for row in db:urows("SELECT COALESCE((SELECT rating FROM star_rating ORDER BY rating_id DESC LIMIT 1 OFFSET 1), 0)") do
			if row ~= 0 then
				----------------------------------------------------------------------------------------------------------
				-- This is a funny one because db_star_rating at this point has been updated to match star_rating
				--
				-- We get the db rating before the most recent one, which should be most recent one before the update_db
				-- We don't want to update the database afterwards because nothing has happened on the API side
				----------------------------------------------------------------------------------------------------------
				do_calc(0, 1)

			else
				native.showAlert('Ready. Set. Go!',
					'You\'re all set to ' ..app_name.. '! Remember to open the app after EVERY Uber ride to accurately calculate what your driver rated you.', {'Okay'})

				local driver_text = {
					text = 'Come back after you\'ve taken a ride',
					x = 160,
					y = 200,
					width = 300,
					align = 'center',
					font = font,
					fontSize = 26,
					anchorY = 0,
				}
				-- supporting text for page
				local driver_text = display.newText(driver_text)
				driver_text:setTextColor(0, 0, 0)
				ui_group:insert(driver_text)
			end
		end

	elseif db_num_rides + 1 == num_rides then
		-----------------------------------------------------------------------
		-- One ride has been taken since opening the app :)
		-- Calculate the rating and update the database to match the Uber API
		-- Next refresh/open the conditional above ^ will fire
		-----------------------------------------------------------------------
		do_calc(1, 0)

	elseif db_num_rides + 1 < num_rides then
		-----------------------------------------------------------------------
		-- More than one ride has been taken since opening the app :(
		-- Calculate the rating and update the database to match the Uber API
		-- Next refresh/open the first conditional ^^ will fire
		-----------------------------------------------------------------------
		native.showAlert('You neglected me :(',
			'You\'ve taken multiple Uber rides without opening ' ..app_name.. '. The rating for your most recent trip won\'t be accurate.', {'Okay'})

		do_calc(1, 0)

	else
		print('Ouch. This was not meant to happen!')
		generic_error_fatal()
	end
end

function do_calc(perform_update, offset)
	-- c = a(e-b)+e
	-- a = number of rides subtract 1
	-- e = new star rating
	-- b = old star rating
	-- c = drivers rating needed for e

	-- check offset
	if offset ~= 1 then
		local offset = 0
	end

	-- a = number of rides subtract 1
	local a = tonumber(num_rides) - 1
	if debug_gen then
		print('Number of rides - 1: ' ..a)
	end

	-- e = new star rating
	local e = tonumber(star_rating)
	if debug_gen then
		print('Current star rating: ' ..e)
	end

	-- b = old star rating
	local b = ''
	for row in db:urows("SELECT rating FROM star_rating ORDER BY rating_id DESC LIMIT 1 OFFSET " ..offset) do
		b = tonumber(row)
	end
	if debug_gen then
		print('Previous star rating: ' ..b)
	end

	-- c = drivers rating needed for e
	local x = e - b
	local c = a * x + e
	print('DRIVER GAVE YOU: ' ..c)
	display_stars(c, e)

	if perform_update ~= 0 then
		update_db()
	end
end

local function fitImage(displayObject, fitWidth, fitHeight, enlarge)
	-- Source: https://coronalabs.com/blog/2014/06/10/tutorial-fitting-images-to-a-size/
	-- first determine which edge is out of bounds
	--
	local scaleFactor = fitHeight / displayObject.height 
	local newWidth = displayObject.width * scaleFactor
	if newWidth > fitWidth then
		scaleFactor = fitWidth / displayObject.width 
	end
	if not enlarge and scaleFactor > 1 then
		return
	end
	displayObject:scale( scaleFactor, scaleFactor )
end

function display_stars(drivers_rating, cur_star_rating)
	local drivers_rating_rounded = math.round(drivers_rating) -- round to nearest whole star rating

	-- star rating image options
	local image_options = {
		width = 660,
		height = 144,
		numFrames = 5
	}
	local sheet = graphics.newImageSheet('star-ratings.png', image_options)

	local driver_text = {
		text = driver_name.. ' rated you ' ..drivers_rating_rounded.. ' stars!',
		x = 160,
		y = 120,
		width = 300,
		align = 'center',
		font = font,
		fontSize = 26,
		anchorY = 0,
	}
	-- supporting text for page
	local driver_text = display.newText(driver_text)
	driver_text:setTextColor(0, 0, 0)
	ui_group:insert(driver_text)

	-- make a cool star rating image!
	local star_number = display.newImage(ui_group, sheet, drivers_rating_rounded, 160, 220)
	fitImage(star_number, 300, 144, false)

	local star_text = {
		text = 'Your current rating is: ' ..cur_star_rating.. ' stars',
		x = 160,
		y = 340,
		width = 300,
		align = 'center',
		font = font,
		fontSize = 26,
		anchorY = 0,
	}
	-- supporting text for page
	local star_text = display.newText(star_text)
	star_text:setTextColor(0, 0, 0)
	ui_group:insert(star_text)
end


-- destroy()
function scene:destroy(event)
	-- Code here runs prior to the removal of scene's view
	ui_group:removeSelf()
	db:close() -- given the db isn't closed anywhere else in this scene maybe we're leaving it open? Investigate
end

----------------------------------
-- Scene event function listeners
----------------------------------
scene:addEventListener('destroy', scene)

return scene
