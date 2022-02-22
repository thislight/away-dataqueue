-- Copyright (C) 2020 thisLight
-- 
-- This file is part of away-dataqueue.
-- 
-- away-luv is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
-- 
-- away-luv is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
-- 
-- You should have received a copy of the GNU General Public License
-- along with away-luv.  If not, see <http://www.gnu.org/licenses/>.
local away = require "away"

local queue_methods = {}

function queue_methods.create(options)
    return setmetatable({{
        options.hwm or -1,
        options.hwm_action or 'block',
        nil, -- error
    }}, {__index = queue_methods})
end

function queue_methods:put(value)
    local hwm = self[1][1]
    local hwm_action = self[1][2]
    if hwm ~= -1 and self:length() >= hwm then
        if hwm_action == 'block' then
            while self:length() >= hwm do
                away.wakeback_later()
            end
        elseif hwm_action == 'drop' then
            return
        end
    end
    self[#self+1] = value
end

function queue_methods:length()
    return #self - 1
end

function queue_methods:try_get()
    if #self > 1 then
        return table.remove(self, 2)
    end
end

function queue_methods:get()
    while #self <= 1 and (not self:endp()) do
        away.wakeback_later()
    end
    return self:try_get()
end

function queue_methods:endp()
    return self[1][3]
end

function queue_methods:mark_end(err)
    self[1][3] = err or 'ended'
end

return queue_methods
