-- DEBUG - set all to false to disable
debug_gen = false
debug_force_auth = false
debug_show_requests = false
debug_show_creds = false
debug_disable_updating = true -- leave this as true, updating function isn't fully operational
-- /DEBUG

local composer = require('composer')
local sqlite = require('sqlite3')
local json = require('json')
local func = require('functions')

-- Globals
display.setStatusBar(display.DarkStatusBar) -- show dark status bar with app
github_url = 'https://github.com/sudosammy/catscatscatscats'
version = '0.1'
app_name = 'Fouber'

_W = display.pixelWidth
_H = display.pixelHeight

if debug_gen then
	print('W: ' .._W)
	print('H: ' .._H)
end

-- DB open
local path = system.pathForFile('juber.db', system.DocumentDirectory)
local db = sqlite3.open(path)

---------------------
-- Check for Updates
---------------------
local function check_updates(event)
	if event.isError then
		print(event.response)
		generic_error_fatal()
	else
		if version < event.response then
			-- outdated
			native.showAlert('New Version Available :D',
				'Wow! Can you believe it. A new version is available, want to go to the GitHub page now to update?', {'Nah, next time', 'Update!'}, goto_github)
		elseif version == event.response then
			return -- current version
		else
			native.showAlert('Super Secret Popup', 'hahaha. cats') -- newer than newest version?
		end
	end
end

if not debug_disable_updating then
	network.request(github_url ..'/version.txt', 'GET', check_updates) -- make update request
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
for row in db:urows('SELECT COUNT(*) FROM auth') do
	if row == 1 then
		for row in db:nrows('SELECT * FROM auth') do
			if row['user_id'] ~= nil or
				row['token'] ~= nil or
				row['user_id'] ~= '' or
				row['token'] ~= '' then
				-- test token with API call
				local star_rating_request = '{"locale":"en_GB","uuid":"' ..row['user_id'].. '","problem_id":"e9302f73-8625-427f-abf7-dbe7ab25af7d","token":"' ..row['token'].. '"}'
				call_uber('https://cn-dc1.geixahba.com/support/tickets', 'POST', nil, star_rating_request, check_auth)
			else
				composer.gotoScene('login')	-- if no user exists send to login page
			end
		end
	else
		composer.gotoScene('login') -- this catch all is for first users with nothing in the db
	end
end

db:close() -- for politeness 
