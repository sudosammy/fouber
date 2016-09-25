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

-- DEBUG - set all to false to disable
debug_gen 				= false
debug_force_auth 		= false
debug_show_requests 	= false
debug_show_creds 		= false
debug_disable_updating 	= false
-- /DEBUG

-- Globals
_version 		= '1.1.0'
_github_url 	= 'https://github.com/sudosammy/fouber'
_app_name 		= 'Fouber'
_W 				= display.pixelWidth
_H 				= display.pixelHeight
display.setStatusBar(display.DarkStatusBar) -- show dark status bar with app

local composer 	= require('composer')
local sqlite 	= require('sqlite3')
local json 		= require('json')
local func 		= require('functions')
local v 		= require('semver')

-- DB open
local path = system.pathForFile('juber.db', system.DocumentDirectory)
local db = sqlite3.open(path)

local function update(event)
	if event.action == 'clicked' then
		local i = event.index
		if i == 1 then
			main()
		elseif i == 2 then -- second button (More Info) was clicked
			system.openURL(_github_url)
		end
	end
end

---------------------
-- Check for Updates
---------------------
local function check_updates(event)
	if event.isError then
		print(event.response)
		generic_error_fatal()
	else
		local github_version = v(event.response)
		
		if v(_version) < github_version then
			-- outdated
			native.showAlert('New Version Available :D',
				'Wow! Can you believe it? A new version is available. Want to go to the GitHub page now to update?', {'Nah, next time', 'Update!'}, update)
		elseif v(_version) == github_version then
			main() -- current version
		else
			native.showAlert('Super Secret Popup', 'hahaha. cats') -- newer than newest version?
		end
	end
end

if not debug_disable_updating then
	network.request('https://raw.githubusercontent.com/sudosammy/fouber/master/VERSION', 'GET', check_updates) -- make update request
end

local function check_auth(event)
	if event.isError then
		print(event.response)
		generic_error_fatal()
	else
		local star_rating = json.decode(event.response)
		-- check star rating returns expected reponse
		if star_rating['message'] == nil then
			composer.gotoScene('login')
		elseif debug_force_auth then
			composer.gotoScene('login')
		elseif string.match(star_rating['message'], 'stars') then
			composer.gotoScene('authed')
		else
			composer.gotoScene('login')
		end
	end
end

--------------------------------------------------
-- Check if user exists and redirect accordingly
--------------------------------------------------
function main()
	for row in db:urows('SELECT COUNT(*) FROM auth') do
		if row == 1 then
			for row in db:nrows('SELECT * FROM auth') do
				if row['user_id'] ~= nil or
					row['token'] ~= nil or
					row['user_id'] ~= '' or
					row['token'] ~= '' then
					-- test token with API call
					call_uber('https://cn-dc1.geixahba.com/support/tickets', 'POST', nil, star_rating_request(row['user_id'], row['token']), check_auth)
				else
					composer.gotoScene('login')	-- if no user exists send to login page
				end
			end
		else
			composer.gotoScene('login') -- this catch all is for first users with nothing in the db
		end
	end
	db:close() -- for politeness 
end
