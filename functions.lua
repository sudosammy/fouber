-----------------------------------------------------------------------------------------
--
-- Whole lot of functions likely only used once
-- Convenient
-- 
-----------------------------------------------------------------------------------------

function show_help(event)
	if event.phase == 'ended' then
		native.showAlert('It\'s all pretty simple',
			'Here\'s the low-down: ' ..app_name.. ' will calculate the star rating your most recent Uber driver gave you. You need to open ' ..app_name.. ' after each Uber ride to keep the ratings accurate. Have fun!', { "Got It", "More Info" }, goto_github)
	end
end

function generic_error_fatal()
	native.showAlert('It\'s Broke :(', 'There was an unrecoverable error. I am so sorry.')
	native.requestExit()
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
			system.openURL(github_url)
		end
	end
end
