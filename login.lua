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

--------------------------------------------------------------------------
-- Revieve callback from Uber, check repsponse, add to db if token present
--------------------------------------------------------------------------
function authenticate(event)
	if event.isError then
		print(event.response)
		generic_error_fatal()
	else
		local user = json.decode(event.response)
		-- test Uber returned access token
		if user['token'] then
			-----------------------------------------------------------------
			-- We open database connection in here, to be polite
			-- Open the db as late as possible, close it as soon as possible
			-----------------------------------------------------------------
			local path = system.pathForFile('juber.db', system.DocumentDirectory)
			local db = sqlite3.open(path)

			-- save token
			local stmt = "INSERT OR REPLACE INTO auth (user_id, token) VALUES ('" ..user['uuid'].. "','" ..user['token'].. "')"
			db:exec(stmt)
			if db:errcode() ~= 0 then
				print(db:errcode(), db:errmsg())
				generic_error_fatal()
			end
			
			db:close() -- ma lady
			composer.removeScene('login')
			composer.gotoScene('authed') -- move to authed page
		else
			-- if not - prompt for credentials again
			print(event.response)
			native.showAlert('Bad Credentials :(',
				'Authenticate with your Uber credentials. This application does not store your credentials.', {'Okay'})
		end
	end
end

------------------------------------------------
-- Listener for email address / password fields 
------------------------------------------------
function text_listener(event)
	if event.phase == 'ended' or
		event.phase == 'submitted' then
		-- dismiss (hide) the native keyboard
		native.setKeyboardFocus(nil)
	elseif event.phase == 'editing' then
		function delay(event) end
		timer.performWithDelay(100, delay)
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

function background:tap(event)
	native.setKeyboardFocus(nil) -- hide keyboard on background tap
end

-- Email label
local email_label = display.newText(ui_group, 'Email Address', 100, 70, 140, 30, font)
email_label:setTextColor(0, 0, 0)

-- Password label
local password_label = display.newText(ui_group, 'Password', 100, 120, 140, 30, font)
password_label:setTextColor(0, 0, 0)

-- Email field
local email_field = native.newTextField(230, 70, 140, 30)
email_field:setTextColor(0, 0, 0)
email_field:addEventListener('userInput', text_listener)
ui_group:insert(email_field)

-- Password field
local password_field = native.newTextField(230, 115, 140, 30)
password_field.isSecure = true
password_field:addEventListener('userInput', text_listener)
ui_group:insert(password_field)

---------------------------------------------------------------------------------------
-- Login function takes email address / password and is called upon login button click
---------------------------------------------------------------------------------------
function submit_login(event)
	if event.phase == 'ended' then
		local email_addr = email_field.text
		local password = password_field.text 

		if debug_show_creds then
			print(email_addr)
			print(password)
		end
		
		if email_addr == nil or
			email_addr == '' or
			password == nil or
			password == '' then
			
			native.showAlert('Empty Username/Password',
				'Authenticate with your Uber credentials. This application does not store your credentials.', {'Okay'})
		else
			local headers = {
				['Content-Type'] = 'application/json; charset=UTF-8',
				['x-uber-client-name'] = 'client',
				['x-uber-device'] = 'android',
			}
			local body = json.encode({
				['password'] = password,
				['username'] = email_addr,
			})
			call_uber('https://cn-dca1.uber.com/rt/users/login', 'POST', headers, body, authenticate)
		end
	end
end

-----------------------------------------------------------------------------------------------------
-- Create login button - must be under login function because it uses submit_login() as its callback
-----------------------------------------------------------------------------------------------------
local login_button = widget.newButton {
	left = 30,
	top = 180,
	labelColor = { default={ 0, 0, 0, 1 }, over={ 1, 1, 1, 1 } },
	id = 'login_button',
	onEvent = submit_login,
	shape = 'roundedRect',
	width = 120,
	height = 40,
	cornerRadius = 2,
	fillColor = { default={ 1, 1, 1, 1 }, over={ 0, 0, 0, 1 } },
	strokeColor = { default={ 0, 0, 0, 1 }, over={ 0, 0, 0, 1 } },
	strokeWidth = 2
}
login_button:setEnabled(true)
login_button:setLabel('Log In')
ui_group:insert(login_button)

--------------------------------
-- Show alert instructing user
--------------------------------
native.showAlert('Please Authenticate',
	'Authenticate with your Uber credentials. This application does not store your credentials.', {'Okay'})

-- destroy()
function scene:destroy(event)
	-- Code here runs prior to the removal of scene's view
	ui_group:removeSelf()
end

----------------------------------
-- Scene event function listeners
----------------------------------
scene:addEventListener('destroy', scene)

return scene
