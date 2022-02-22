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
local away = require 'away'
local Debugger = require 'away.debugger'
local Queue = require 'away.dataqueue'
local Scheduler = away.scheduler

local global_queue = Queue.create({})

Scheduler:add_watcher('push_signal', function(_, signal) if not signal.is_auto_signal then print('push_signal', Debugger.topstring(Debugger:pretty_signal(signal))) end end)

Scheduler:add_watcher('run_thread', function(_, thread, signal) if not signal.is_auto_signal then print('run_thread', Debugger:remap_thread(thread),'signal', Debugger.topstring(Debugger:pretty_signal(signal))) end end)

Scheduler:run_task(function()
    while true do
        print('call next()')
        local val = global_queue:get()
        if val then
            print(string.format("Hello %s!",val))
        elseif global_queue:endp() then
            print(global_queue:endp())
            break
        end
    end
    Scheduler:stop()
end)

Scheduler:run_task(function()
    global_queue:put('J. Cooper')
    away.wakeback_later()
    print('wakeback!')
    global_queue:put('BT')
    away.wakeback_later()
    print('wakeback!')
    global_queue:put('Anderson')
    away.wakeback_later()
    print('wakeback!')
    global_queue:mark_end()
end)

Scheduler:run()
