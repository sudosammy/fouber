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
local widget 	= require('widget')
local font 		= 'HelveticaNeue' or system.nativeFont
local func 		= require('functions')
local scene 	= composer.newScene()
local ui_group 	= display.newGroup()

-----------------
-- Logout
-----------------
local function do_logout(event)
	if event.action == 'clicked' then
		local i = event.index
		if i == 2 then -- second button (Logout) was clicked
			composer.removeScene('menu')
			composer.gotoScene('logout')
		end
	end
end

local function logout(event)
	if event.phase == 'ended' then
		native.showAlert('Logout?',
			'Are you sure you want to logout of ' .._app_name.. '? This won\'t log you out of the Uber app.', { "No", "Logout" }, do_logout)
	end
end

-----------------
-- Go back
-----------------
local function go_back(event)
	if event.phase == 'ended' then
		composer.removeScene('menu')
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

-- Back button
local back_button = widget.newButton {
	left = 20,
	top = 20,
	labelColor = { default={ 0, 0, 0, 1 }, over={ 1, 1, 1, 1 } },
	id = 'back_button',
	onEvent = go_back,
	shape = 'roundedRect',
	width = 120,
	height = 40,
	cornerRadius = 2,
	fillColor = { default={ 1, 1, 1, 1 }, over={ 0, 0, 0, 1 } },
	strokeColor = { default={ 0, 0, 0, 1 }, over={ 0, 0, 0, 1 } },
	strokeWidth = 2
}
back_button:setEnabled(true)
back_button:setLabel('Back')
ui_group:insert(back_button)

-- Help button
local help_button = widget.newButton {
	left = 20,
	top = 80,
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
help_button:setLabel('Help')
ui_group:insert(help_button)

-- Logout button
local logout_button = widget.newButton {
	left = 20,
	top = 140,
	labelColor = { default={ 0, 0, 0, 1 }, over={ 1, 1, 1, 1 } },
	id = 'logout_button',
	onEvent = logout,
	shape = 'roundedRect',
	width = 120,
	height = 40,
	cornerRadius = 2,
	fillColor = { default={ 1, 1, 1, 1 }, over={ 0, 0, 0, 1 } },
	strokeColor = { default={ 0, 0, 0, 1 }, over={ 0, 0, 0, 1 } },
	strokeWidth = 2
}
logout_button:setEnabled(true)
logout_button:setLabel('Logout')
ui_group:insert(logout_button)

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