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

local co = coroutine

local dataqueue_service = {installed_flag = false, waited_dataqueue = {}}

function dataqueue_service:install(scheduler)
    if not self.installed_flag then
        local keepalive_thread = coroutine.create(
                                     function(self)
                while true do
                    co.yield()
                    local process_queue = {}
                    table.move(self.waited_dataqueue, 1, #self.waited_dataqueue,
                               1, process_queue)
                    for i,dataqueue in ipairs(process_queue) do
                        if dataqueue:need_wake_back() then
                            self:perform_wakeback(scheduler, dataqueue)
                            dataqueue.waiting_threads = {}
                            table.remove(self.waited_dataqueue, i)
                        end
                    end
                end
            end)
        co.resume(keepalive_thread, self)
        scheduler:set_auto_signal(function()
            return {target_thread = keepalive_thread}
        end)
        self.installed_flag = true
    end
end

function dataqueue_service:add_waited_queue(dq)
    table.insert(self.waited_dataqueue, dq)
end

function dataqueue_service:perform_wakeback(scheduler, dq)
    for _,thread in ipairs(dq.waiting_threads) do
        if co.status(thread) ~= 'dead' then
            scheduler:push_signal{
                target_thread = thread,
                kind = 'dataqueue_wake_back',
                queue = dq
            }
        end
    end
end

return dataqueue_service
