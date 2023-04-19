local module = {utility = {signature = nil; drawings = {}; elements = {}; signals = {}}};
if module.utility.signature ~= "bungie" then return end

-- // Services
local services = {
   uis = game:GetService("UserInputService")
}

-- // Shared set (fixes v3)
do
   -- check if the module has already been executed
   if not shared.module then shared.module = {} end;
   if not shared.module.utility then
      shared.module.utility = module.utility;
   end;

   -- fixes gc
   module = shared.module.utility;
end;

-- // Random misc
do
   -- returns screen size
   function module.screen_size()
      return workspace.CurrentCamera.ViewportSize;
   end;
end;

-- // Object misc
do
   -- convert color to black & white
   function module.to_bw(color: Color3, amount: number)
      if not color then return end;
      if not amount then amount = 40 end;
      local r = math.clamp(math.floor(color.R * 255) + amount, 0, 255)
      local g = math.clamp(math.floor(color.G * 255) + amount, 0, 255)
      local b = math.clamp(math.floor(color.B * 255) + amount, 0, 255)
      return Color3.fromRGB(r, g, b)
   end;
   -- get rgb values of color
   function module.get_rgb(color: Color3)
      if not color then color = Color3.fromRGB(255, 255, 255) end;
      local r = math.floor(color.R * 255)
      local g = math.floor(color.G * 255)
      local b = math.floor(color.B * 255)
      return r, g, b
   end;
   -- inspo from splix / gamesneeze
   function module.pos(xs: number, xo: number, ys: number, yo: number)
      local vpx = module.screen_size().X
      local vpy = module.screen_size().Y
      local x = xs * vpx + xo
      local y = ys * vpy + yo
      return Vector2.new(x, y)
   end;
   function module.size(xs: number, xo: number, ys: number, yo: number)
      local vpx = module.screen_size().X
      local vpy = module.screen_size().Y
      local x = xs * vpx + xo
      local y = ys * vpy + yo
      return Vector2.new(x, y)
   end;
   -- center specific object into the middle of the screen
   function module.center(object: Instance)
      if not object then return end;
      object.Position = module.pos(0.5, -(object.Size.X / 2), 0.5, -(object.Size.Y / 2))
   end;
end;

-- // Function misc
do
   -- return mouse location
   function module.mouse()
      return game:GetService("UserInputService"):GetMouseLocation()
   end;
end;

-- // Signal system
do
   local signals = module.signals
   
   -- over drawing signal
   signals.is_over = function(object: any)
      local mouse = module.mouse()
      local pos = {offset = object.Position, absolute = object.Position + object.Size}
      if mouse.X >= pos.offset.X and mouse.Y >= pos.offset.Y and mouse.X <= pos.absolute.X and mouse.Y <= pos.absolute.Y then
         return true
      end
      return false
   end

   -- click function
   signals.click = function(object: any, call)
      services.uis.InputBegan:Connect(function(input)
         if input.UserInputType == Enum.UserInputType.MouseButton1 and signals.is_over(object) == true then
            call()
         end
      end)
   end
end;

-- // Instances
do
   -- check if class is a valid drawing class
   local check = function(class: string)
      local drawings = {"Line", "Text", "Image", "Circle", "Square", "Triangle", "Quad"};
      local elements = {"Frame", "TextLabel", "TextBox", "TextButton", "ImageButton", "ImageLabel", "UIListLayout", "UICorner"}
      for i,v in next, drawings do
         if drawings[i] == v then
            return "drawing"
         end;
      end;
      for i,v in next, elements do
         if elements[i] == v then
            return "element"
         end
      end
      return nil
   end;

   -- clear all drawings in the drawing table
   function module.clear()
      for i,v in next, module.drawings do
         v:Remove();
      end;
   end;

   -- create drawing class
   function module.create(class: string, properties: table)
      print(check(class))
      if not class then return end;

      local object;
      local handler = {}
      if check(class) then
         object = Drawing.new(class)

         if properties ~= nil or typeof(properties) == "table" and #properties ~= 0 then
            for i,v in next, properties do
               object[i] = v;
            end;
         end

         table.insert(module.drawings, object);
      end;

      local function new(mode: string)
         local area;
         if mode == "drawing" or mode == "Drawing" then
            object = Drawing.new(class)
            area = module.drawings
         elseif mode == "element" or mode == "Element" then
            object = Instance.new(class)
            area = module.elements
         end

         if properties ~= nil or typeof(properties) == "table" and #properties ~= 0 then
            for i,v in next, properties do
               object[i] = v;
            end;
         end

         table.insert(area, object);
      end

      new(check(class))

      -- functions
      function handler:get()
         return object
      end;
      function handler:color(color: Color3, property: string)
         if check(class) == "drawing" then
            if not color then object.Color = object.Color return end;
            object.Color = color
         elseif check(class) == "element" then
            if not object[property] then return end
            if not color then object[property] = object[property] return end;
            object[property] = color
         end
      end;
      function handler:size(xs: number, xo: number, ys: number, yo: number)
         local x = xs * object.Size.X + xo
         local y = ys * object.Size.Y + yo
         return Vector2.new(x, y)
      end;
      function handler:pos(xs: number, xo: number, ys: number, yo: number)
         local x = object.Position.X + xs * object.Size.X + xo
         local y = object.Position.Y + ys * object.Size.Y + yo
         return Vector2.new(x, y)
      end;

      return handler
   end;
end;

return module
