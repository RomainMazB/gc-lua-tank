return function (gui, x, y, w, h, text, font, hAlign, vAlign, color)
  local element = gui.newElement(x, y)
  element.w = w
  element.h = h
  element.text = text
  element.font = font
  element.textW = font:getWidth(text)
  element.textH = font:getHeight(text)
  element.hAlign = hAlign
  element.vAlign = vAlign

  function element:drawText()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(self.font)
    local x = self.x
    local y = self.y

    -- Handle horizontal alignment
    if self.hAlign == "center" then
        x = x + (self.w - self.textW) / 2
    elseif self.hAlign == "right" then
        x = x + self.w - self.textW
    end

    -- Handle vertical alignment
    if self.vAlign == "center" then
        y = y + (self.h - self.textH) / 2
    elseif self.vAlign == "bottom" then
        y = y + self.h - self.textH
    end

    love.graphics.print(self.text, x, y)
  end

  function element:draw()
    if self.visible then
        self:drawText()
    end
  end

  return element
end