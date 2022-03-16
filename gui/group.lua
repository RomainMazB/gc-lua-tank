return function (gui, x, y)
    local group = {
        elements = {}
    }
    group.x = x ~= nil and x or 0
    group.y = y ~= nil and y or 0

    -- Add one or more element, and return the last inserted element
    function group:add(...)
        for _,element in ipairs({...}) do
            table.insert(self.elements, element)
        end

        return self.elements[#self.elements]
    end

    -- Loop through all the group's elements to change their visibility individually
    function group:setVisible(visible)
        for _,element in pairs(group.elements) do
            if 'function' == type(element.setVisible) then
                element:setVisible(visible)
            end
        end
    end

    -- Loop through all the group's elements to toggle their visibility individually
    -- Be warned that some elements may become visible when some may disappear using this method
    function group:toggleVisibility()
        for _,element in pairs(group.elements) do
            element:setVisible(not element.visible)
        end
    end

    --
    -- These methods just proxy the natives elements' methods
    -- and add the group x and y to make the position of each element dependant of the group position
    --
    function group:panel(x, y, ...)
        return self:add(gui.panel(x+self.x, y+self.y, ...))
    end

    function group:button(x, y, ...)
        return self:add(gui.button(x+self.x, y+self.y, ...))
    end

    function group:text(x, y, ...)
        return self:add(gui.panelButtons(x+self.x, y+self.y, ...))
    end


    -- Update all the elements of the group
    function group:update(dt)
        for _,element in pairs(group.elements) do
            element:update(dt)
        end
    end

    -- Draw all the elements of the group
    function group:draw()
        for _,element in pairs(group.elements) do
            if 'function' == type(element.draw) then
                element:draw(self.x, self.y)
            end
        end
    end

    return group
end