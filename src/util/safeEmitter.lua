local Emitter = require('core').Emitter
local SafeEmitter = Emitter:extend()

local function pcallWrapper(handler, ...)
    local status, err = xpcall(handler, debug.traceback, ...)
    if status == false then
        log.err(0, err)
    end
end

-- Emit a named event to all listeners with optional data argument(s).
function SafeEmitter:emit(name, ...)
    local handlers = rawget(self, "handlers")
    if not handlers then
        self:missingHandlerType(name, ...)
        return
    end
    local handlers_for_type = rawget(handlers, name)
    if not handlers_for_type then
        self:missingHandlerType(name, ...)
        return
    end
    for i = 1, #handlers_for_type do
        local handler = handlers_for_type[i]
        if handler then
            pcallWrapper(handler, ...)
        end
    end
    for i = #handlers_for_type, 1, -1 do
        if not handlers_for_type[i] then
            table.remove(handlers_for_type, i)
        end
    end
    return self
end

return SafeEmitter