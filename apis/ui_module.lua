local utility = {utility = {signature = "bungie", drawings = {}}};

-- just for visual preference
local module = utility.utility
local global = shared

-- check if the module has already been executed
if not global.module then global.module = {} end
if not global.module.utility then
   global.module.utility = module
end

-- fixes gc
module = global.module.utility

-- check if class is a valid drawing class
local check = function(class: string)
   local classes = {"Line", "Text", "Image", "Circle", "Square", "Triangle", "Quad"};
   for i,v in next, classes do
      if class == v then
         return true
      end
   end
end

-- clear all drawings in the drawing table
function module.clear()
   for i,v in next, module.drawings do
      v:Remove();
   end
end

-- create drawing class
function module.create(class: string, properties: table)
   if not class then return end;
   if not properties then return end;

   local object = nil;
   if check(class) then
      object = Drawing.new(class)
      for i,v in next, properties do
         object[i] = v;
      end

      table.insert(module.drawings, object);
   end
   return object
end

-- ignore, just diff variations for peoples coding styles
module._clear, module.Clear, module.wipe, module._wipe, module.Wipe, module.reset, module._reset, module.Reset = module.clear, module.clear, module.clear, module.clear, module.clear, module.clear, module.clear, module.clear;
module._create, module.Ceate, module._Create, module.add, module.Add, module._add, module._Add, module.new, module.New, module._new, module._New, module.instance, module._instance, module._Instance, module.Instance, module.draw, module.Draw, module._draw, module._Draw = module.create, module.create, module.create, module.create, module.create, module.create, module.create, module.create, module.create, module.create, module.create, module.create, module.create, module.create, module.create, module.create, module.create, module.create, module.create;
module._drawing, module._drawings, module.Drawing, module.Drawings = module.drawings, module.drawings, module.drawings, module.drawings;
module._signature, module.sig, module.Signature, module._siggy, module.sig, module.siggy, module.Sig, module.Siggy = module.signature, module.signature, module.signature, module.signature, module.signature, module.signature, module.signature, module.signature;
utility.Utility, utility._utility, utility.Util, utility._util, utility._utils, utility.utils, utility.Utils = utility.utility, utility.utility, utility.utility, utility.utility, utility.utility, utility.utility, utility.utility;

return utility
