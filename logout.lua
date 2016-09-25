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
local font 		= 'HelveticaNeue' or system.nativeFont
local func 		= require('functions')
local scene 	= composer.newScene()

---------------------
-- Open the database
---------------------
local path = system.pathForFile('juber.db', system.DocumentDirectory)
local db = sqlite3.open(path)

-------------------------
-- Delete all the things
-------------------------
local stmt = "DELETE FROM auth; VACUUM"
db:exec(stmt)
if db:errcode() ~= 0 then
	print(db:errcode(), db:errmsg())
	generic_error_fatal()
end

-----------------
-- Redirect away
-----------------
db:close()
composer.gotoScene('login')

return scene
