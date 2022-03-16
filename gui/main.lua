local gui = {}
local guiNamespace = (...):match("(.-)[^%.]+$")

local text = require (guiNamespace..'text')
local button = require (guiNamespace..'button')
local group = require (guiNamespace..'group')
local panel = require (guiNamespace..'panel')

-- Create a new element
gui.newElement = function (x, y)
    local element = {}
    element.x = x
    element.y = y
    element.w = 0
    element.h = 0
    element.visible = true
    element.eventsLst = {}
    element.isHover = false

    -- Bind an callback to the element's event
    function element:setEvent(type, cb)
        self.eventsLst[type] = cb
    end

    -- Set the visibility of the element
    function element:setVisible(visible)
      self.visible = visible
    end

    -- Toggle the visibility of the element, regardless it's actually visible or not
    function element:toggleVisibility()
        self:setVisible(not self.visible)
    end

    -- Update the state of the **element**
    -- Here we created a specific updateElement to allow "children" to override the update method
    -- updateElement manage stuff that are global to all kind of elements and should probably not be overriden
    function element:updateElement(dt)
        local mx,my = love.mouse.getPosition()
        -- Does the mouse position collides with the element?
        if mx > self.x and mx < self.x + self.w and my > self.y and my < self.y + self.h then
            if not self.isHover then
                self.isHover = true
            end
        elseif self.isHover then
            self.isHover = false
        end
    end

    function element:update(dt)
        self:updateElement(dt)
    end

    function element:draw()
      print("element / draw / Not implemented")
    end

    return element
end

-- Create a group
gui.group = function (...)
    return group(gui, ...)
end

-- Create a panel
gui.panel = function (...)
    return panel(gui, ...)
end

-- Create a text
gui.text = function (...)
    return text(gui, ...)
end

-- Create a button
gui.button = function (...)
    return button(gui, ...)
end

return gui