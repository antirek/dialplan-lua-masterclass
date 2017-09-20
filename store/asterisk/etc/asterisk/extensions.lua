--[[
-- Sample using extensions.lua
-- copy extensions.lua in /etc/asterisk or create symlink
]]
local config = require('/etc/asterisk/dialplan/config')
local Dialplan = require(config.basepath .. 'main');
extensions = Dialplan.getExtensions();