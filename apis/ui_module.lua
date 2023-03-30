local utility = {utility = {signature = "bungie"; drawings = {}; signal = {}}};

do
   -- check if the module has already been executed
   if not shared.module then shared.module = {} end;
   if not shared.module.utility then
      shared.module.utility = utility.utility;
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

-- // Vozoid's modified Signal handler
do
   -- vars
   local signal = module.signal;
   signal.__index = signal;
   signal.ClassName = "signal";

   -- signal check
   function signal.check(_signal)
      return type(signal) == "table" and getmetatable(_signal) == signal
   end;
   -- new signal
   function signal.new()
      local self = setmetatable({}, signal)
      self._bindableEvent = Instance.new("BindableEvent")
      self._argMap = {}
      self._source = ""
      self._bindableEvent.Event:Connect(function(key)
         self._argMap[key] = nil
         if (not self._bindableEvent) and (not next(self._argMap)) then
            self._argMap = nil
         end;
      end)
      return self
   end;
   -- fire signal
   function signal:fire(...)
      if not self._bindableEvent then
         warn(("Signal is already destroyed. %s"):format(self._source))
         return;
      end;
      local args = table.pack(...)
      local key = game:GetService("HttpService"):GenerateGUID(false)
      self._argMap[key] = args
      self._bindableEvent:Fire(key)
   end;
   -- connect signal (mousebutton1down:Connect(etc))
   function signal:connect(handler)
      if not type(handler) == "function" then
         error(("connect(%s)"):format(typeof(handler)), 2)
      end;
      return self._bindableEvent.Event:Connect(function(key)
         local args = self._argMap[key]
         if args then
            handler(table.unpack(args, 1, args.n))
         else
            error("missing arg data, probably due to reentrance.")
         end;
      end)
   end;
   -- wait for signal
   function signal:wait()
      local key = self._bindableEvent.Event:Wait()
      local args = self._argMap[key]
      if args then
         return table.unpack(args, 1, args.n)
      else
         error("Missing arg data, probably due to reentrance.")
         return nil
      end;
   end;
   -- destroy signal
   function signal:destroy()
      if self._bindableEvent then
         self._bindableEvent:destroy()
         self._bindableEvent = nil
      end;
      setmetatable(self, nil)
   end;
end;

-- // Instances
do
   -- check if class is a valid drawing class
   local check = function(class: string)
      local classes = {"Line", "Text", "Image", "Circle", "Square", "Triangle", "Quad"};
      for i,v in next, classes do
         if class == v then
            return true
         end;
      end;
   end;

   -- clear all drawings in the drawing table
   function module.clear()
      for i,v in next, module.drawings do
         v:Remove();
      end;
   end;

   -- create drawing class
   function module.create(class: string, properties: table)
      if not class then return end;
      if not properties then return end;

      local object;
      local handler = {}
      if check(class) then
         object = Drawing.new(class)
         for i,v in next, properties do
            object[i] = v;
         end;

         table.insert(module.drawings, object);
      end;

      -- functions
      function handler:get()
         return object
      end;
      function handler:color(color: Color3)
         if not color then object.Color = object.Color return end;
         object.Color = color
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

return utility
