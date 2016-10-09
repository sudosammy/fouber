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

-----------------------------------------------------------------------------------------
--
-- Whole lot of functions likely only used once
-- Convenient
-- 
-----------------------------------------------------------------------------------------
local json = require('json') -- we do JSON things in here

function show_help(event)
	if event.phase == 'ended' then
		native.showAlert('It\'s all pretty simple',
			'Here\'s the low-down: ' .._app_name.. ' will calculate the star rating your most recent Uber driver gave you. You need to open ' .._app_name.. ' after each Uber ride to keep the ratings accurate. Have fun!', {'Got It', 'More Info'}, goto_github)
	end
end

local function close_app(event)
	if event.action == 'clicked' then
		native.requestExit()
	end
end

function generic_error_fatal()
	native.showAlert('It\'s Broke :(', 'There was an unrecoverable error. I am so sorry.', {'Close'}, close_app)
end

function star_rating_request(user_id, token)
	return json.encode({
		['locale'] = 'en_GB',
		['uuid'] = user_id,
		['problem_id'] = 'e9302f73-8625-427f-abf7-dbe7ab25af7d',
		['token'] = token,
	})
end

function call_uber(url, method, req_headers, req_body, callback)
	local params = {}
	params.body = req_body

	-- notify if we're going to lose this request
	if callback == nil then
		print('WARNING: No callback available - Request will be lost: ' ..url)
	end
	
	-- common header for JSON requests
	params.headers = {
		['Content-Type'] = 'application/json; charset=UTF-8',
	}
	-- if additional headers are required
	if req_headers ~= nil then
		for k, v in pairs(req_headers) do
			params.headers [k] = v 
		end
	end

	if debug_show_requests then
		for k, v in pairs(params.headers) do
			print(k .. ' => ' ..v)
		end
		print(params.body)
	end

	-- make request - go to callback
	network.request(url, method, callback, params)
end

function goto_github(event)
	if event.action == 'clicked' then
		local i = event.index
		if i == 2 then -- second button (More Info) was clicked
			system.openURL(_github_url)
		end
	end
end
