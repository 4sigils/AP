local RunService    = game:GetService("RunService")
local Players       = game:GetService("Players")
local LocalPlayer   = Players.LocalPlayer
local Mouse         = LocalPlayer:GetMouse()
local Camera        = workspace.CurrentCamera

local Fonts         = Drawing.Fonts

local FontMetrics = {
    [Fonts.System] = 0.48,
    [Fonts.SystemBold]   = 0.52,
    [Fonts.UI]     = 0.50,
    [Fonts.Monospace]   = 0.60,
    [Fonts.Pixel]  = 0.50,
}

Fonts.ResolveOverlay = function(value, fallback)
    if value == nil then return fallback or Fonts.SystemBold end
    if type(value) ~= "string" then return value end
    local key = string.lower(value)
    key = string.gsub(key, "[%s_%-]", "")
    if key == "system" then return Fonts.System end
    if key == "systembold" or key == "bold" then return Fonts.SystemBold end
    if key == "ui" then return Fonts.UI end
    if key == "monospace" or key == "mono" then return Fonts.Monospace end
    if key == "pixel" then return Fonts.Pixel end
    return fallback or Fonts.SystemBold
end

local rgb
do
    local memo = {}
    rgb = function(r, g, b)
        local key = r * 65536 + g * 256 + b
        local c = memo[key]
        if not c then
            c = Color3.fromRGB(r, g, b)
            memo[key] = c
        end
        return c
    end
end
local function mix(a, b, t)
    if t == 0 then return a end
    if t == 1 then return b end
    return Color3.new(
        a.R + (b.R - a.R) * t,
        a.G + (b.G - a.G) * t,
        a.B + (b.B - a.B) * t
    )
end

local Themes = {
    {

        Name="Midnight",
        Base=rgb(18,14,28), Panel=rgb(27,21,40), PanelHi=rgb(38,29,54),
        Stroke=rgb(70,55,94), Divider=rgb(57,44,79),
        Text=rgb(249,245,255), TextDim=rgb(205,190,229), TextMuted=rgb(139,119,168),
        AccentA=rgb(176,112,255), AccentB=rgb(129,91,246), Accent=rgb(163,103,250),
        AccentDim=rgb(96,61,148), Track=rgb(48,37,65), TrackFill=rgb(176,112,255),
        Danger=rgb(248,82,111), Warning=rgb(244,188,87), Success=rgb(88,216,151),
    },
    {

        Name="Obsidian",
        Base=rgb(14,15,17), Panel=rgb(22,23,26), PanelHi=rgb(32,33,37),
        Stroke=rgb(61,63,69), Divider=rgb(49,51,56),
        Text=rgb(245,246,248), TextDim=rgb(194,197,202), TextMuted=rgb(126,130,138),
        AccentA=rgb(225,229,235), AccentB=rgb(158,164,174), Accent=rgb(211,215,222),
        AccentDim=rgb(111,115,122), Track=rgb(41,43,47), TrackFill=rgb(225,229,235),
        Danger=rgb(244,83,104), Warning=rgb(238,183,82), Success=rgb(83,211,145),
    },
    {

        Name="Burgundy",
        Base=rgb(29,12,22), Panel=rgb(42,17,31), PanelHi=rgb(56,23,41),
        Stroke=rgb(93,42,68), Divider=rgb(76,34,56),
        Text=rgb(255,241,248), TextDim=rgb(225,178,202), TextMuted=rgb(157,102,130),
        AccentA=rgb(222,67,133), AccentB=rgb(174,51,106), Accent=rgb(211,61,126),
        AccentDim=rgb(125,38,77), Track=rgb(62,28,46), TrackFill=rgb(222,67,133),
        Danger=rgb(248,75,99), Warning=rgb(241,177,81), Success=rgb(83,207,143),
    },
    {

        Name="Cyber",
        Base=rgb(7,17,20), Panel=rgb(10,27,31), PanelHi=rgb(14,39,44),
        Stroke=rgb(28,78,84), Divider=rgb(22,63,69),
        Text=rgb(235,255,255), TextDim=rgb(159,220,222), TextMuted=rgb(87,151,155),
        AccentA=rgb(29,229,224), AccentB=rgb(31,190,205), Accent=rgb(25,215,212),
        AccentDim=rgb(17,124,125), Track=rgb(20,52,56), TrackFill=rgb(29,229,224),
        Danger=rgb(250,79,108), Warning=rgb(244,190,79), Success=rgb(60,222,151),
    },
    {

        Name="Bubblegum",
        Base=rgb(30,15,27), Panel=rgb(44,21,39), PanelHi=rgb(59,28,52),
        Stroke=rgb(100,48,85), Divider=rgb(82,39,70),
        Text=rgb(255,242,251), TextDim=rgb(233,183,219), TextMuted=rgb(164,104,148),
        AccentA=rgb(255,94,184), AccentB=rgb(239,121,205), Accent=rgb(250,99,183),
        AccentDim=rgb(149,58,111), Track=rgb(67,31,58), TrackFill=rgb(255,94,184),
        Danger=rgb(255,75,110), Warning=rgb(246,184,91), Success=rgb(87,214,155),
    },
    {

        Name="Emerald",
        Base=rgb(8,20,14), Panel=rgb(12,31,21), PanelHi=rgb(17,43,29),
        Stroke=rgb(35,82,55), Divider=rgb(28,67,45),
        Text=rgb(237,255,245), TextDim=rgb(165,219,187), TextMuted=rgb(93,153,117),
        AccentA=rgb(55,226,126), AccentB=rgb(39,190,103), Accent=rgb(49,213,119),
        AccentDim=rgb(30,125,72), Track=rgb(23,55,37), TrackFill=rgb(55,226,126),
        Danger=rgb(246,82,102), Warning=rgb(239,187,78), Success=rgb(55,226,126),
    },
    {

        Name="Crimson",
        Base=rgb(27,10,12), Panel=rgb(40,14,18), PanelHi=rgb(54,19,24),
        Stroke=rgb(96,34,42), Divider=rgb(79,27,34),
        Text=rgb(255,240,242), TextDim=rgb(229,171,178), TextMuted=rgb(160,96,105),
        AccentA=rgb(255,65,78), AccentB=rgb(219,43,60), Accent=rgb(244,58,73),
        AccentDim=rgb(145,34,44), Track=rgb(64,22,28), TrackFill=rgb(255,65,78),
        Danger=rgb(255,65,78), Warning=rgb(242,173,74), Success=rgb(78,209,139),
    },
    {

        Name="Arctic",
        Base=rgb(9,16,29), Panel=rgb(13,24,42), PanelHi=rgb(18,34,57),
        Stroke=rgb(39,70,105), Divider=rgb(32,58,87),
        Text=rgb(240,247,255), TextDim=rgb(175,204,235), TextMuted=rgb(102,139,180),
        AccentA=rgb(79,153,255), AccentB=rgb(106,178,255), Accent=rgb(75,145,244),
        AccentDim=rgb(46,88,148), Track=rgb(27,47,72), TrackFill=rgb(79,153,255),
        Danger=rgb(248,88,113), Warning=rgb(244,190,88), Success=rgb(80,214,157),
    },
    {

        Name="Sunset",
        Base=rgb(30,16,10), Panel=rgb(44,23,14), PanelHi=rgb(58,31,18),
        Stroke=rgb(98,55,31), Divider=rgb(80,45,26),
        Text=rgb(255,246,237), TextDim=rgb(234,199,168), TextMuted=rgb(166,126,96),
        AccentA=rgb(255,137,61), AccentB=rgb(239,94,43), Accent=rgb(250,122,54),
        AccentDim=rgb(149,72,34), Track=rgb(66,37,23), TrackFill=rgb(255,137,61),
        Danger=rgb(247,76,89), Warning=rgb(255,177,66), Success=rgb(87,208,137),
    },
    {

        Name="Royal",
        Base=rgb(24,20,10), Panel=rgb(36,30,14), PanelHi=rgb(49,41,19),
        Stroke=rgb(86,72,35), Divider=rgb(70,59,29),
        Text=rgb(255,250,232), TextDim=rgb(228,210,158), TextMuted=rgb(156,137,87),
        AccentA=rgb(247,199,72), AccentB=rgb(224,164,43), Accent=rgb(241,188,62),
        AccentDim=rgb(139,108,38), Track=rgb(57,48,24), TrackFill=rgb(247,199,72),
        Danger=rgb(244,79,96), Warning=rgb(247,199,72), Success=rgb(85,207,139),
    },

}

local BackgroundNames = {
    none = true,
    dots = true,
    particles = true,
    aurora = true,
    snow = true,
    rainfall = true,
}

local function NormalizeBackground(value)
    if type(value) == "table" then
        local kind = string.lower(tostring(value.Type or value.type or value.Name or value.name or "none"))
        local out = {}
        for k, v in pairs(value) do out[k] = v end
        if kind == "scanlines" then kind = "none" end
        out.Type = BackgroundNames[kind] and kind or "none"
        return out
    end
    local kind = string.lower(tostring(value or "none"))
    if kind == "scanlines" then kind = "none" end
    if not BackgroundNames[kind] then kind = "none" end
    return kind
end

local Layout = {

    WindowW         = 700,
    WindowH         = 500,
    WindowMinW      = 500,
    WindowMinH      = 340,
    Corner          = 12,
    TopbarH         = 0,
    TabRailW        = 172,
    TabRailMinW     = 94,
    TabRailNarrow   = 94,

    TabRowH         = 39,
    TabGap          = 7,
    TabIcon         = 20,
    SectionH        = 22,
    SectionGap      = 12,
    SectionColumnGap = 12,
    SectionPadX     = 16,
    SectionPadY     = 12,
    SectionBottomPad = 6,
    SectionCorner   = 12,
    SectionTitleH   = 18,
    SectionDescH    = 16,

    ContentPadX     = 18,
    ContentPadY     = 14,
    ContentGapY     = 10,

    RowHeight       = 28,
    RowColumnGap    = 8,
    RowGapY         = 7,

    ToggleW         = 38,
    ToggleH         = 20,
    ToggleKnob      = 14,

    SliderH         = 6,
    SliderKnob      = 6,

    ButtonH         = 28,
    FieldH          = 26,
    DropdownH       = 28,
    DividerH        = 1,

    TitleSize       = 14,
    TextSize        = 13,
    SmallSize       = 12,
    TinySize        = 11,

    ScrollSpeed     = 30,
    ScrollbarW      = 4,

    AnimFast        = 18,
    AnimMed         = 12,
    AnimSlow        = 8,

    ResizeGrab      = 12,
}

local Pool = {
    Square   = {},
    Text     = {},
    Line     = {},
    Circle   = {},
    Triangle = {},
    Image    = {},
}

local PoolCache = {
    Square   = {},
    Text     = {},
    Line     = {},
    Circle   = {},
    Triangle = {},
    Image    = {},
}

local PoolUsed  = { Square = 0, Text = 0, Line = 0, Circle = 0, Triangle = 0, Image = 0 }
local PoolMade  = { Square = 0, Text = 0, Line = 0, Circle = 0, Triangle = 0, Image = 0 }
local DrawOrder = 0

local function Layer(z)
    DrawOrder = DrawOrder + 1
    return z * 100000 + DrawOrder
end

local function Take(kind)
    local idx = PoolUsed[kind] + 1
    PoolUsed[kind] = idx

    local obj = Pool[kind][idx]
    local last = PoolCache[kind][idx]

    if not obj then
        obj = PoolMade.Lib.New(kind)
        last = {}
        Pool[kind][idx] = obj
        PoolCache[kind][idx] = last
    end

    if idx > PoolMade[kind] then PoolMade[kind] = idx end
    if not last.Visible then last.Visible = true; obj.Visible = true end

    return obj, last
end

-- library-wide drawing registry (hosted on PoolMade to stay under Lua's 200-locals limit)
PoolMade.Lib = { All = {}, Dead = false, Wrap = {}, WrapN = 0 }
PoolMade.Lib.New = function(kind)
    local obj = Drawing.new(kind)
    PoolMade.Lib.All[obj] = true
    return obj
end

PoolMade.Lib.Kill = function(obj)
    if not obj then return end
    PoolMade.Lib.All[obj] = nil
    pcall(function() obj.Visible = false end)
    if not pcall(function() obj:Remove() end) then
        pcall(function() obj:Destroy() end)
    end
end

PoolMade.Lib.KillAll = function()
    local n = 0
    for obj in pairs(PoolMade.Lib.All) do
        n = n + 1
        PoolMade.Lib.Kill(obj)
    end
    return n
end

local function ResetPool()
    for k in pairs(PoolUsed) do PoolUsed[k] = 0 end
    DrawOrder = 0
end

local function HideUnused()
    for kind, list in pairs(Pool) do
        local cache = PoolCache[kind]
        for i = PoolUsed[kind] + 1, PoolMade[kind] do
            if cache[i] and cache[i].Visible then
                cache[i].Visible = false
                list[i].Visible = false
            end
        end
    end
end

local function ClearPool()
    for kind, list in pairs(Pool) do
        for i = 1, #list do
            PoolMade.Lib.Kill(list[i])
        end
        Pool[kind] = {}
        PoolCache[kind] = {}
        PoolUsed[kind] = 0
        PoolMade[kind] = 0
    end
end

local function IsPictureBytes(bytes)
    if type(bytes) ~= "string" or #bytes < 24 then return false end
    local a, b = string.byte(bytes, 1, 2)
    return (a == 137 and b == 80)
        or (a == 255 and b == 216)
        or (a == 71 and b == 73)
end

local function PictureHash(text)
    local hash = 5381
    for i = 1, #text do
        hash = (hash * 33 + string.byte(text, i)) % 2147483648
    end
    return string.format("%08x", hash)
end

local function ReadPictureBytes(source, kind)
    local target = tostring(source or "")
    if target == "" then return nil end
    if IsPictureBytes(target) then return target end

    local remote = string.find(target, "://", 1, true) ~= nil
    local cache = "Nexa_" .. tostring(kind or "image") .. "_" .. PictureHash(target) .. ".dat"

    if not remote then
        local ok, exists = pcall(function() return isfile and isfile(target) end)
        if ok and exists then
            local readOk, bytes = pcall(function() return readfile(target) end)
            if readOk and IsPictureBytes(bytes) then return bytes end
        end
    end

    do
        local ok, exists = pcall(function() return isfile and isfile(cache) end)
        if ok and exists then
            local readOk, bytes = pcall(function() return readfile(cache) end)
            if readOk and IsPictureBytes(bytes) then return bytes end
        end
    end

    if not remote then return nil end

    local ok, bytes = pcall(function()
        if httpget then return httpget(target) end
        if game and game.HttpGet then return game:HttpGet(target) end
        return nil
    end)
    if not ok or not IsPictureBytes(bytes) then return nil end

    pcall(function()
        if writefile then writefile(cache, bytes) end
    end)

    return bytes
end

local function LoadPicture(source, kind)
    if source == nil or source == "" then return nil end
    local holder = { Image = nil, Source = source }

    if IsPictureBytes(source) then
        local image = PoolMade.Lib.New("Image")
        image.Data = source
        image.Visible = false
        holder.Image = image
        return holder
    end

    task.spawn(function()
        local bytes = ReadPictureBytes(source, kind)
        if bytes then
            if PoolMade.Lib.Dead then return end
            local image = PoolMade.Lib.New("Image")
            image.Data = bytes
            image.Visible = false
            holder.Image = image
        end
    end)

    return holder
end

local function DrawPicture(holder, x, y, width, height, z, transparency, corner)
    local image = holder and holder.Image
    if not image then return false end

    local c = holder._c
    if not c then c = {}; holder._c = c end
    if c.x ~= x or c.y ~= y then c.x, c.y = x, y; image.Position = Vector2.new(x, y) end
    if c.w ~= width or c.h ~= height then c.w, c.h = width, height; image.Size = Vector2.new(width, height) end
    corner = corner or 0
    if c.r ~= corner then c.r = corner; pcall(function() image.Rounding = corner end) end
    if c.z ~= z then c.z = z; image.ZIndex = z end
    local a = transparency or 1
    a = a < 0 and 0 or (a > 1 and 1 or a)
    if c.a ~= a then c.a = a; image.Transparency = a end
    local vis = a > 0.01
    if c.v ~= vis then c.v = vis; image.Visible = vis end
    return true
end

local function HidePicture(holder)
    if holder and holder.Image then
        local c = holder._c
        if c then c.v = false end
        holder.Image.Visible = false
    end
end

local FrameAlpha = 1

local GlassSurfaceAlpha = 0.85

local function GlassSurface(x, y, w, h, color, z, corner)
    if w <= 0 or h <= 0 then DrawOrder = DrawOrder + 1; return end
    local o, l = Take("Square")
    local depth = Layer(z)

    if l.X ~= x or l.Y ~= y then l.X, l.Y = x, y; o.Position = Vector2.new(x, y) end
    if l.W ~= w or l.H ~= h then l.W, l.H = w, h; o.Size = Vector2.new(w, h) end
    if l.Color ~= color and l.ColorWritable ~= false then
        local ok = pcall(function() o.Color = color end)
        if ok then
            l.Color = color
            l.ColorWritable = true
        else

            l.ColorWritable = false
        end
    end
    if not l.Filled then l.Filled = true; o.Filled = true end
    if l.Corner ~= corner then l.Corner = corner; o.Corner = corner end
    if l.Depth ~= depth then l.Depth = depth; o.ZIndex = depth end

    local a = GlassSurfaceAlpha * FrameAlpha
    if l.Alpha ~= a then l.Alpha = a; o.Transparency = a end
end

local function SolidSurface(x, y, w, h, color, z, corner)
    if w <= 0 or h <= 0 then DrawOrder = DrawOrder + 1; return end
    local o, l = Take("Square")
    local depth = Layer(z)

    if l.X ~= x or l.Y ~= y then l.X, l.Y = x, y; o.Position = Vector2.new(x, y) end
    if l.W ~= w or l.H ~= h then l.W, l.H = w, h; o.Size = Vector2.new(w, h) end
    if l.Color ~= color and l.ColorWritable ~= false then
        local ok = pcall(function() o.Color = color end)
        if ok then
            l.Color = color
            l.ColorWritable = true
        else

            l.ColorWritable = false
        end
    end
    if not l.Filled then l.Filled = true; o.Filled = true end
    if l.Corner ~= corner then l.Corner = corner; o.Corner = corner end
    if l.Depth ~= depth then l.Depth = depth; o.ZIndex = depth end

    local a = FrameAlpha
    if l.Alpha ~= a then l.Alpha = a; o.Transparency = a end
end

local FrostedSurfaceAlpha = 0.68

local function FrostedSurface(x, y, w, h, color, z, corner)
    if w <= 0 or h <= 0 then DrawOrder = DrawOrder + 1; return end
    local o, l = Take("Square")
    local depth = Layer(z)

    if l.X ~= x or l.Y ~= y then l.X, l.Y = x, y; o.Position = Vector2.new(x, y) end
    if l.W ~= w or l.H ~= h then l.W, l.H = w, h; o.Size = Vector2.new(w, h) end
    if l.Color ~= color and l.ColorWritable ~= false then
        local ok = pcall(function() o.Color = color end)
        if ok then
            l.Color = color
            l.ColorWritable = true
        else

            l.ColorWritable = false
        end
    end
    if not l.Filled then l.Filled = true; o.Filled = true end
    if l.Corner ~= corner then l.Corner = corner; o.Corner = corner end
    if l.Depth ~= depth then l.Depth = depth; o.ZIndex = depth end

    local a = FrostedSurfaceAlpha * FrameAlpha
    if l.Alpha ~= a then l.Alpha = a; o.Transparency = a end
end

local ActiveClipTop, ActiveClipBottom
local function ClipVertical(y, h)
    if not ActiveClipTop then return y, h end
    local top, bottom = math.max(y, ActiveClipTop), math.min(y + h, ActiveClipBottom)
    return top, math.max(0, bottom - top)
end

local function Rect(x, y, w, h, color, z, corner, alpha)
    if ActiveClipTop and z >= 40 and z < 59 then
        local cy, ch = ClipVertical(y, h)
        if ch <= 0 then DrawOrder = DrawOrder + 1; return end
        y, h = cy, ch
        if cy ~= y or ch ~= h then corner = 0 end
    end
    if w <= 0 or h <= 0 then DrawOrder = DrawOrder + 1; return end
    local o, l = Take("Square")
    local depth = Layer(z)

    if l.X ~= x or l.Y ~= y then l.X, l.Y = x, y; o.Position = Vector2.new(x, y) end
    if l.W ~= w or l.H ~= h then l.W, l.H = w, h; o.Size = Vector2.new(w, h) end
    if l.Color ~= color and l.ColorWritable ~= false then
        local ok = pcall(function() o.Color = color end)
        if ok then
            l.Color = color
            l.ColorWritable = true
        else

            l.ColorWritable = false
        end
    end
    if not l.Filled then l.Filled = true; o.Filled = true end
    if l.Corner ~= corner then l.Corner = corner; o.Corner = corner end
    if l.Depth ~= depth then l.Depth = depth; o.ZIndex = depth end

    local a = (alpha or 1) * FrameAlpha
    if l.Alpha ~= a then l.Alpha = a; o.Transparency = a end
end

local function Stroke(x, y, w, h, color, z, corner, alpha)
    if ActiveClipTop and z >= 40 and z < 59 then
        if y + h <= ActiveClipTop or y >= ActiveClipBottom then DrawOrder = DrawOrder + 1; return end
        if y < ActiveClipTop or y + h > ActiveClipBottom then
            local o, l = Take("Square")
            local depth = Layer(z)
            if l.X ~= x or l.Y ~= y then l.X, l.Y = x, y; o.Position = Vector2.new(x, y) end
            if l.W ~= w or l.H ~= h then l.W, l.H = w, h; o.Size = Vector2.new(w, h) end
            if l.Filled ~= false then l.Filled = false; o.Filled = false end
            if l.Color ~= color then l.Color = color; o.Color = color end
            if l.Corner ~= corner then l.Corner = corner; o.Corner = corner end
            if l.Depth ~= depth then l.Depth = depth; o.ZIndex = depth end
            local a = 0
            if l.Alpha ~= a then l.Alpha = a; o.Transparency = a end
            return
        end
    end
    if w <= 0 or h <= 0 then DrawOrder = DrawOrder + 1; return end
    local o, l = Take("Square")
    local depth = Layer(z)

    if l.X ~= x or l.Y ~= y then l.X, l.Y = x, y; o.Position = Vector2.new(x, y) end
    if l.W ~= w or l.H ~= h then l.W, l.H = w, h; o.Size = Vector2.new(w, h) end
    if l.Color ~= color and l.ColorWritable ~= false then
        local ok = pcall(function() o.Color = color end)
        if ok then
            l.Color = color
            l.ColorWritable = true
        else

            l.ColorWritable = false
        end
    end
    if l.Filled ~= false then l.Filled = false; o.Filled = false end
    if l.Corner ~= corner then l.Corner = corner; o.Corner = corner end
    if l.Depth ~= depth then l.Depth = depth; o.ZIndex = depth end

    local a = (alpha or 1) * FrameAlpha
    if l.Alpha ~= a then l.Alpha = a; o.Transparency = a end
end

local function Line(x1, y1, x2, y2, color, z, thickness, alpha)
    if ActiveClipTop and z >= 40 and z < 59 then
        local lo, hi = ActiveClipTop, ActiveClipBottom
        local dy = y2 - y1
        if dy == 0 then
            if y1 < lo or y1 > hi then DrawOrder = DrawOrder + 1; return end
        else
            local t0, t1 = math.max(0, math.min((lo-y1)/dy, (hi-y1)/dy)), math.min(1, math.max((lo-y1)/dy, (hi-y1)/dy))
            if t0 > t1 then DrawOrder = DrawOrder + 1; return end
            local ax, ay = x1, y1
            local dx = x2 - x1
            x1, y1, x2, y2 = ax + dx*t0, ay + dy*t0, ax + dx*t1, ay + dy*t1
        end
    end
    local o, l = Take("Line")
    local depth = Layer(z)

    if l.X1 ~= x1 or l.Y1 ~= y1 then l.X1, l.Y1 = x1, y1; o.From = Vector2.new(x1, y1) end
    if l.X2 ~= x2 or l.Y2 ~= y2 then l.X2, l.Y2 = x2, y2; o.To = Vector2.new(x2, y2) end
    if l.Color ~= color then l.Color = color; o.Color = color end
    if l.Thickness ~= thickness then l.Thickness = thickness; o.Thickness = thickness end
    if l.Depth ~= depth then l.Depth = depth; o.ZIndex = depth end

    local a = (alpha or 1) * FrameAlpha
    if l.Alpha ~= a then l.Alpha = a; o.Transparency = a end
end

local function TriangleClipEmit(a, b, c, color, z, alpha)
    local o, l = Take("Triangle")
    o.PointA, o.PointB, o.PointC = Vector2.new(a[1], a[2]), Vector2.new(b[1], b[2]), Vector2.new(c[1], c[2])
    l.AX, l.AY, l.BX, l.BY, l.CX, l.CY = a[1], a[2], b[1], b[2], c[1], c[2]
    if l.Color ~= color then l.Color = color; o.Color = color end
    if not l.Filled then l.Filled = true; o.Filled = true end
    local depth = Layer(z)
    if l.Depth ~= depth then l.Depth = depth; o.ZIndex = depth end
    local opacity = (alpha or 1) * FrameAlpha
    if l.Alpha ~= opacity then l.Alpha = opacity; o.Transparency = opacity end
end

local function Circle(x, y, radius, color, z, filled, thickness, sides, alpha)
    if ActiveClipTop and z >= 40 and z < 59 then

        local fadeDistance = math.max(radius * 2, 10)
        local fade = math.max(0, math.min(1,
            (y - ActiveClipTop) / fadeDistance,
            (ActiveClipBottom - y) / fadeDistance))
        alpha = (alpha or 1) * fade
        if fade <= 0.001 then DrawOrder = DrawOrder + 1; return end
        if y + radius <= ActiveClipTop or y - radius >= ActiveClipBottom then DrawOrder = DrawOrder + 1; return end
        if y - radius < ActiveClipTop or y + radius > ActiveClipBottom then
            if filled then
                local segments = math.max(32, sides or 24)
                local start = DrawOrder
                for i = 0, segments - 1 do
                    local a1, a2 = 2 * math.pi * i / segments, 2 * math.pi * (i + 1) / segments
                    local p = {{x, y}, {x + math.cos(a1)*radius, y + math.sin(a1)*radius}, {x + math.cos(a2)*radius, y + math.sin(a2)*radius}}
                    for _, edge in ipairs({{ActiveClipTop, true}, {ActiveClipBottom, false}}) do
                        local result = {}
                        for j = 1, #p do
                            local u, v = p[j], p[j % #p + 1]
                            local ui = edge[2] and u[2] >= edge[1] or u[2] <= edge[1]
                            local vi = edge[2] and v[2] >= edge[1] or v[2] <= edge[1]
                            if ui then result[#result+1] = u end
                            if ui ~= vi then
                                local t = (edge[1]-u[2])/(v[2]-u[2])
                                result[#result+1] = {u[1]+t*(v[1]-u[1]), edge[1]}
                            end
                        end
                        p = result
                    end
                    if #p >= 3 then
                        for j = 2, #p-1 do TriangleClipEmit(p[1], p[j], p[j+1], color, z, alpha) end
                    end
                end
                return
            end

            local segments = math.max(40, sides or 24)
            for i = 0, segments - 1 do
                local a1, a2 = 2 * math.pi * i / segments, 2 * math.pi * (i + 1) / segments
                Line(x + math.cos(a1) * radius, y + math.sin(a1) * radius,
                     x + math.cos(a2) * radius, y + math.sin(a2) * radius,
                     color, z, thickness or 1, alpha)
            end
            return
        end
    end
    local o, l = Take("Circle")
    local depth = Layer(z)

    if l.X ~= x or l.Y ~= y then l.X, l.Y = x, y; o.Position = Vector2.new(x, y) end
    if l.Radius ~= radius then l.Radius = radius; o.Radius = radius end
    if l.Color ~= color then l.Color = color; o.Color = color end
    if l.Filled ~= filled then l.Filled = filled; o.Filled = filled end
    if l.Thickness ~= thickness then l.Thickness = thickness; o.Thickness = thickness end
    if l.Sides ~= sides then l.Sides = sides; o.NumSides = sides end
    if l.Depth ~= depth then l.Depth = depth; o.ZIndex = depth end

    local a = (alpha or 1) * FrameAlpha
    if l.Alpha ~= a then l.Alpha = a; o.Transparency = a end
end

local function Triangle(ax, ay, bx, by, cx, cy, color, z, alpha)
    if ActiveClipTop and z >= 40 and z < 59 then
        local poly = {{ax, ay}, {bx, by}, {cx, cy}}
        for _, edge in ipairs({{ActiveClipTop, true}, {ActiveClipBottom, false}}) do
            local result = {}
            for j = 1, #poly do
                local u, v = poly[j], poly[j % #poly + 1]
                local ui = edge[2] and u[2] >= edge[1] or u[2] <= edge[1]
                local vi = edge[2] and v[2] >= edge[1] or v[2] <= edge[1]
                if ui then result[#result+1] = u end
                if ui ~= vi then
                    local t = (edge[1]-u[2])/(v[2]-u[2])
                    result[#result+1] = {u[1]+t*(v[1]-u[1]), edge[1]}
                end
            end
            poly = result
            if #poly == 0 then break end
        end
        if #poly < 3 then DrawOrder = DrawOrder + 1; return end
        for j = 2, #poly-1 do TriangleClipEmit(poly[1], poly[j], poly[j+1], color, z, alpha) end
        return
    end
    local o, l = Take("Triangle")
    local depth = Layer(z)

    if l.AX ~= ax or l.AY ~= ay then l.AX, l.AY = ax, ay; o.PointA = Vector2.new(ax, ay) end
    if l.BX ~= bx or l.BY ~= by then l.BX, l.BY = bx, by; o.PointB = Vector2.new(bx, by) end
    if l.CX ~= cx or l.CY ~= cy then l.CX, l.CY = cx, cy; o.PointC = Vector2.new(cx, cy) end
    if l.Color ~= color then l.Color = color; o.Color = color end
    if not l.Filled then l.Filled = true; o.Filled = true end
    if l.Depth ~= depth then l.Depth = depth; o.ZIndex = depth end

    local a = (alpha or 1) * FrameAlpha
    if l.Alpha ~= a then l.Alpha = a; o.Transparency = a end
end

local function Bar(x1, y1, x2, y2, thickness, color, z, alpha)
    local dx, dy = x2 - x1, y2 - y1
    local len = math.sqrt(dx * dx + dy * dy)
    if len < 0.001 then return end
    local px, py = -dy / len * thickness / 2, dx / len * thickness / 2
    Triangle(x1 + px, y1 + py, x1 - px, y1 - py, x2 - px, y2 - py, color, z, alpha)
    Triangle(x1 + px, y1 + py, x2 - px, y2 - py, x2 + px, y2 + py, color, z, alpha)
end

local function TextWidth(text, size, font)
    return #text * size * (FontMetrics[font] or 0.5)
end

local function TrimText(text, room, size, font)
    local fit = math.floor(room / (size * (FontMetrics[font] or 0.5)))
    if #text <= fit then return text end
    if fit <= 2 then return "" end
    return string.sub(text, 1, fit - 2) .. ".."
end

local function TextMidY(y, h, size)
    return math.floor(y + (h - size) / 2 + 0.5)
end

local function Text(text, x, y, color, size, font, z, alpha, room, center)
    if ActiveClipTop and z >= 40 and z < 59 and (y < ActiveClipTop or y + size > ActiveClipBottom) then
        DrawOrder = DrawOrder + 1; return
    end
    if room then text = TrimText(text, room, size, font) end
    if text == "" then DrawOrder = DrawOrder + 1; return end

    x, y = math.floor(x + 0.5), math.floor(y + 0.5)
    local o, l = Take("Text")
    local depth = Layer(z + 0.5)

    if l.Text ~= text then l.Text = text; o.Text = text end
    if l.Color ~= color then l.Color = color; o.Color = color end
    if l.Font ~= font then l.Font = font; o.Font = font end
    if l.Size ~= size then l.Size = size; o.Size = size end
    if l.Outline ~= false then l.Outline = false; o.Outline = false end
    local ctr = center and true or false
    if l.Center ~= ctr then l.Center = ctr; o.Center = ctr end
    if l.X ~= x or l.Y ~= y then l.X, l.Y = x, y; o.Position = Vector2.new(x, y) end
    if l.Depth ~= depth then l.Depth = depth; o.ZIndex = depth end

    local a = (alpha or 1) * FrameAlpha
    if l.Alpha ~= a then l.Alpha = a; o.Transparency = a end
    return o
end

local function TextCenter(text, cx, y, color, size, font, z, alpha, room)
    if room then text = TrimText(text, room, size, font) end
    if text == "" then return end
    Text(text, cx, y, color, size, font, z, alpha, nil, true)
end

local function GradientRect(x, y, w, h, first, second, z, alpha, steps)
    steps = steps or 18
    local prev = math.floor(x + 0.5)
    for i = 1, steps do
        local nxt = math.floor(x + w * i / steps + 0.5)
        local slice = math.max(1, nxt - prev)
        Rect(prev, y, slice, h, mix(first, second, (i - 0.5) / steps), z, 0, alpha)
        prev = nxt
    end
end

local IconImage = {
    Masks = {
        ["minus"] = "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002020202020202020202020202020100000000000000000000000000000000000000000000000000000000000001000cafbbbabbbbbbbbbbbbbbbbbbbabb30000200000000010013ffffffffffffffffffffffffffff470003000000000000043a3e3e3e3e3e3e3e3e3e3e3e3e3e1000010000000000000000000000000000000000000000000000000000000000000003030303030303030303030303030100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
        ["plus"] = "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c1104000000000000000000000000000000000000000200afee3a000300000000000000000000000000000000000200beff3f000300000000000000000000000000000000000200bafe3e000300000000000000000000000000000000000200bbff3e000300000000000000000000000000020202020402bcff40020502020201000000000000000000000000000000b8ff3500000000000000000000000001000cafbbbabbbcbbedffccbbbcbbbabb30000200000000010013ffffffffffffffffffffffffffff470003000000000000043a3e3e3e403eccff6d3e413e3e3e10000100000000000000000000000000b7ff34000000000000000000000000000000030303030503bcff40030603030301000000000000000000000000000200bbff3e000300000000000000000000000000000000000200b9fd3d000300000000000000000000000000000000000200c3ff4100030000000000000000000000000000000000010030411000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000002030100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
        ["close"] = "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020100000000000000000003010000000000000000000001000001000000000000000100000000000000000000000200301a000200000000010100781a0001000000000000020133fecd110002000001030096ffba0403000000000000010120cbffc711000201030098ffe93d010200000000000000010010c7ffc71100040098ffea350002000000000000000000020011c7ffc70f0099ffea3500040000000000000000000000020011c7ffbd98ffec35000400000000000000000000000000020012baffffdd320004000000000000000000000000000001040098ffffc90a00020000000000000000000000000001030099ffe3cbffca110002000000000000000000000001030098ffeb2f09c8ffc711000200000000000000000001000098ffea35000011c7ffc71100010000000000000001020c97ffea350004020011c7ffc615010100000000000003003fffee3500040000020011c6ffba04030000000000000002006440000400000000020010b2430102000000000000000000000002000000000000010000000000000000000000000000030200000000000000000101020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
        ["check"] = "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010300000000000000000000000000000000000000000000000002000000000000000000000000000000000000000102053f000000000000000000000000000000000000000005008eff63000300000000000000000000000000000000040063feeb430102000000000000000201000000000000040064ffff520003000000000000000100000100000000030038fafe640004000000000000000200301a00020000030035e9ff6e000400000000000000020133fecd110002030021ebff9800040100000000000000010120cbffc711000011c7ff97000201000000000000000000010010c7ffc70b0ac8ffc30102010000000000000000000000020011c7ffb9a7ffc612020200000000000000000000000000020011c8ffffdc120002000000000000000000000000000000020011c3e333000300000000000000000000000000000000000200030b00010000000000000000000000000000000000000001000002000000000000000000000000000000000000000000010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
        ["chevron-down"] = "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020100000000000000000103000000000000000000000001000001000000000000000000020000000000000000000200301a0002000000000101023f000000000000000000020133fecd110002000001030099ff640003000000000000010120cbffc711000201030098ffec43010200000000000000010010c7ffc71100040098ffeb340002000000000000000000020011c7ffc70f0099ffea3500040000000000000000000000020011c7ffbb96ffeb35000400000000000000000000000000020011c8ffffeb350004000000000000000000000000000000020011c3e234000400000000000000000000000000000000000200030b0002000000000000000000000000000000000000000100000200000000000000000000000000000000000000000001010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
        ["chevron-up"] = "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030301000000000000000000000000000000000000000001000000010000000000000000000000000000000000010200809f10000200000000000000000000000000000001030099ffffc71100020000000000000000000000000001030098ffe0c7ffc8110002000000000000000000000001030098ffeb2f09c8ffc711000200000000000000000001010098ffea35000011c7ffc71100010000000000000000020496ffea350004020011c7ffc615010100000000000003007affe93500040000020011c6ffba040300000000000001001db23a000400000000020010b2430102000000000000000000000002000000000000010000000000000000000000000001010200000000000000000101020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
        ["chevron-right"] = "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020100000000000000000000000000000000000000000001000001000000000000000000000000000000000000000200301a00020000000000000000000000000000000000020133fecd11000200000000000000000000000000000000010120cbffc711000200000000000000000000000000000000010010c7ffc711000200000000000000000000000000000000020011c7ffc711000200000000000000000000000000000000020011c7ffc911000100000000000000000000000000000000020012b9ffc509010100000000000000000000000000000001040096ffe90e0101000000000000000000000000000001030099ffed340002000000000000000000000000000001030098ffeb350002000000000000000000000000000001000098ffea350004000000000000000000000000000001020c97ffea35000400000000000000000000000000000003003fffee35000400000000000000000000000000000000000200644000040000000000000000000000000000000000000000000002000000000000000000000000000000000000000000030200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
        ["chevron-left"] = "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030100000000000000000000000000000000000000000001000000000000000000000000000000000000000000010100781a00010000000000000000000000000000000001030096ffba040300000000000000000000000000000001030098ffe93d0102000000000000000000000000000001030098ffea350002000000000000000000000000000001020098ffea350004000000000000000000000000000000020099ffec350004000000000000000000000000000000030081ffdb320004000000000000000000000000000000000300a3ffc609000200000000000000000000000000000000010213c9ffc911000200000000000000000000000000000000010011c7ffc711000200000000000000000000000000000000020011c7ffc711000100000000000000000000000000000000020011c7ffc615010100000000000000000000000000000000020011c6ffba04030000000000000000000000000000000000020010b2430102000000000000000000000000000000000000010000000000000000000000000000000000000000000000000101020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
        ["arrow-right"] = "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003010000000000000000000000000000000000000000000000000100000000000000000000000000000000000000010378170002000000000000000000000000000000000003007affc61100020000000000000000000000000000000001021fc6ffc711000200000000000000000002020202020202040014c9ffc911000200000000000000000000000000000000000006bbffc91200010000000001000cafbbbabbbbbbbbbbbbbdb8cbfbffbc050200000000010013fffffffffffffffffffffffffcffeb0d01010000000000043a3e3e3e3e3e3e3e3f403cc9ffed35000200000000000000000000000000000000008affed350002000000000000000003030303030304050f9affed35000400000000000000000000000000000003003fffee3500040000000000000000000000000000000000020064400004000000000000000000000000000000000000000000000200000000000000000000000000000000000000000003020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
        ["arrow-left"] = "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010300000000000000000000000000000000000000000000000002000000000000000000000000000000000000000101023f0000000000000000000000000000000000000001030099ff64000300000000000000000000000000000001030098ffed440203010101010101000000000000000001020099ffe6300000000000000000000000000000000001020099ffeb4408130f0f0f0f0f0f0f0f04000000000000020092fffafbecf5f3f3f3f3f3f3f3f1f33e0003000000000300a7fffaf1f2f4f3f3f3f3f3f3f3f1f33e000300000000010212c9ffcf210d120f0f0f0f0f0f0f0f0400000000000000010011c9ffc20d000000000000000000000000000000000000020011c8ffc716020201010101010100000000000000000000020011c6ffba04030000000000000000000000000000000000020010b24301020000000000000000000000000000000000000100000000000000000000000000000000000000000000000001010200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
        ["menu"] = "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002020202020202020202020202020100000000000000000000000000000000000000000000000000000000000001000cafbbbabbbbbbbbbbbbbbbbbbbabb30000200000000010013ffffffffffffffffffffffffffff470003000000000000043a3e3e3e3e3e3e3e3e3e3e3e3e3e1000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000cafbbbabbbbbbbbbbbbbbbbbbbabb30000200000000010013ffffffffffffffffffffffffffff470003000000000000043a3e3e3e3e3e3e3e3e3e3e3e3e3e1000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000cafbbbabbbbbbbbbbbbbbbbbbbabb30000200000000010013ffffffffffffffffffffffffffff470003000000000000043a3e3e3e3e3e3e3e3e3e3e3e3e3e1000010000000000000000000000000000000000000000000000000000000000000003030303030303030303030303030100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
        ["window"] = "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010101010101010101010101010000000000000000000200000000000000000000000000000300000000000000010001100f0d0d0d0d0d0d0d0d0d0e0800010000000000020034d5eef2fcfcfcfcfcfcfcfcfbfae9620002000000010108ddf9fcf2c6c7c6c6c6c6c6c6c7c5e6fe270002000001000fffbacb99000000000000000000006bff400003000001000ff4dca79e86878686868686868886c0fe3e00030000010011eefff9fcfffffffffffffffffffffeff410003000001000dfbc50e0f0c0c0c0c0c0c0c0c100c83ff3d0003000001000dfcc10000000000000000000000007bff3d0003000001000dfcc20103010101010101010105017eff3d0003000001000dfcc20002000000000000000004007dff3d0003000001000dfcc20002000000000000000004007dff3d0003000001000dfbc30406040404040404040408047fff3c0003000001000efdbd00000000000000000000000073fd3f0003000001010bf3e27c7e7d7d7d7d7d7d7d7d7f7dbdff330003000000020060feffffffffffffffffffffffffff96030200000000000100263d3c3d3d3d3d3d3d3d3d3d3d330000000000000000000200000000000000000000000000000100000000000000000002030303030303030303030303030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
        ["home"] = "0000000000000000000000000000000000000000000000000000000000000000000000030301000000000000000000000000000000000000000101000000020000000000000000000000000000000000020000818f0e0003000000000000000000000000000000030012a7ffffcb31000400000000000000000000000000030012c7ffcfb6ffeb3500040000000000000000000000040035d7ffc7100098fff161000300000000000000000004003aebffa7130004007fffff65000301000000000000010064fcff930000000000005fffff960000010000000002046dfffc6e0b100f0d0d0e11054de2ff9a110201000003007bfff474acf9fbfcfcfcfcfbfdcb67d9ffba0402000001001db5306cffcfc2c3c3c3c3c2c3ffb610b44301020000000000000080fd3300000000000001fac50000000000000000000105027dff3f02021110060010fcc10103020000000000000004007dff3e01a8f9fdcf1609fdc20002000000000000000004007dff3902ffbf97ff3f00ffc20002000000000000000004007dff3c04fe6d1efd3e04ffc20002000000000000000004007bfe2a00ff6e1eff2c00fec000020000000000000000040086ff977dfdb893fd9b7bffca00020000000000000000020135ecffffffffffffffffff6300020000000000000000000100213e3c413f3e413d3d3300000000000000000000000000020000000000000000000002000000000000000000000000000203030303030303030200000000000000000000000000000000000000000000000000000000000000",
        ["gear"] = "0000000000000000000000000000000000000000000000000000000000000000000000010100000000000000000000000000000000000000000000000000000000000000000000000000000000000102000004110f0100000201000000000000000000000001000005003ceedd0f000300000100000000000000000001001832000040ffef1000003218000100000000000000010120d3f4360048fff1160135f4d3200101000000000000020134f4fff113024a4b000ef1fff434010200000000000000030032e5641898e3f1b23561e53200030000000000000000000000140edeffc4b3fffc381200000000000000000000010f1015009bff544c682ef0dd011311100400000000010010dcecec46eac345ffff747fff43d2ecec3c00030000010012fdffff53f3b364ffffa16eff50f0ffff45000300000000043c40450ab7fb2d799f19d3f30d3d41401000010000000000000000102afdf88172dbff610e0000000000000000000000050034e56141d7ffffeb6564e334000501000000000000020134f4fff10c03424e0f08f0fff4340102000000000000010120d3f4340111d1e13b0236f4d32001010000000000000001001832000011f0ff41000032180001000000000000000000010000030011f6ff430005000001000000000000000000000001020000043c411000010201000000000000000000000000000000000000000000000000000000000000000000000000000000000003030100000000000000000000000000000000000000000000000000000000000000000000",
        ["folder"] = "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000010f1110111010000201010101010101010000000000010012dfeeeeeeebef7d000000000000000000030000000001000af1fffffffffffa3f10110f0f0f0f1009000100000002003af5fcfffffffffffff3f3f3f3f3f2ede162000200010109d8ffffefefeeefeeeff3f3f3f3f3f3fffffe280002010011f1fc581013111011100f0f0f0f111030e2ff45000301000ff2f20500000000000000000000000000b8fe3e000301000ff3f31101020101010101010101010302bcff3f000301000ff3f30f00010000000000000000000200bbff3f000301000ff3f30f00010000000000000000000200bbff3f000301000ff3f31000010000000000000000000201bcff3f000301000ff3f20a02030202020202020202020500b7ff3e0003010010f0f82d00000000000000000000000009d4fd43000301010debffe6bbbcbbbbbbbbbbbbbbbbbcbbd6ffff36000300020061f9ffffffffffffffffffffffffffffff960202000000010027403d3e3e3e3e3e3e3e3e3e3e3e3f3500000000000000020000000000000000000000000000000001000000000000000203030303030303030303030303030300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
        ["file"] = "000000000001020303030303030303040000000000000000000000000000000000000000000000000100000000000000000000010018b3c2c2c3c3c3c3c1c07d00020100000000000000000200b4fffafcfcfcfcfdfcffff98000301000000000000000200c4fa190d0e0d0d110d85fcff980002010000000000000200c1fc0900000000000083f6a5ff9900020100000000000200c2fc0e01020101050184fc007cff8e010300000000000200c2fc0d00010000040089ff877fedf70f0001000000000200c2fc0d00010000030053ebfffffded110001000000000200c2fc0d0005040404040013100cc6fb0d0001000000000200c2fc0d00000000000000000000c1fc0d0001000000000200c2fd0b067d8483848483852501c4fc0d0001000000000200c2fd090cf3ffffffffffff4500c5fc0d0001000000000200c2fc0d01101110111110110600c2fc0d0001000000000200c2fc0d00000000000000000000c2fc0d0001000000000200c2fd0b067e8584858584852400c4fc0d0001000000000200c2fd090cf3ffffffffffff4500c5fc0d0001000000000200c2fc0d010d0c0c0c0c0c0c0500c2fc0d0001000000000200c2fc0f02000000000000000302c3fc0d0001000000000200c0fb0100000000000000000000befa0d0001000000000200c9ffc3c2c2c2c2c2c2c2c2c2c1f4fc11000100000000020063ecfafdfdfdfdfdfdfdfdfdfbf378050200000000000000000e0e0d0d0d0d0d0d0d0d0d0d100000000000000000000002000000000000000000000000000100000000",
        ["user"] = "0000000000000000000000000000000000000000000000000000000000000000000000010100000000000000000000000000000000000000000103000003020000000000000000000000000000000000010000091000000100000000000000000000000000000001001a98e3efad37000200000000000000000000000000010119e1fffff7fffb440003000000000000000000000000030098ffb52a188affd60601000000000000000000000001000ce8f721000000d3fe3400030000000000000000000001000ff2f510010600c3ff3e000300000000000000000000000301b3ff8b040057fcea0e01010000000000000000000000020034fdffd4c4ffff6b00030000000000000000000000000003004ad5ffffe7700404000000000000000000000000000200000000232d000000000200000000000000000000000300153e447884817a503e270003000000000000000000030035e3fffffffffffffffff965000300000000000000020036ecffa87d4f3d3d427990ffff650002000000000002011fe7ff97000000000000000064ffff49000300000000030073f8a5000305030303030406006dfbad0202000000000200b3fe3d010400000000000001020af6f00a00010000010108e2ff290002000000000000000109e1ff2a0002000000000542490700000000000000000001013b4214000100000000000000000000000000000000000000000000000000000000000303000000000000000000000000030301000000000000000000000000000000000000000000000000000000",
        ["shield"] = "000000000000000000000204040301000000000000000000000000000000000103010000000000030200000000000000000000000103030000002b828f4301000001040100000000000000020000001962caffffffffde7d260000000200000000000100074ba2fefff39f3d258be0ffffbd5e160000000000020161d8ffffbd5e1400000000054ba2feffed72020200000200c5ff7c26000000030302040000001960f0f50e000100040082fd2200040401000000000200000000eac801020000040077ff4002030000000000020019330011ffbc00020000030043ff6d000403010000020209cffa0d2dfe8400040000030039ff7e00050000000103009cff67023eff7700040000010010fdb100003e0201050094ff8b00006dff430003000001000bf8c60240ff98000095ff950008027ffe3800030000000201cdec030f98ff895cff9700020500adff11000100000003006cff5e000098ffffc4010204002af6ae020300000000010205c9f92b00008ca11101030309d1f1210002000000000002001ff0d109010000000203009cff50000300000000000000030050ff9c02000704000063ff8c0004000000000000000000040089ffc42300000c99ffbc02030100000000000000000000040060fbf44a28d0ff8c05020100000000000000000000000002002fd1fffff553000001000000000000000000000000000004000c92a62200040100000000000000000000000000000000020000000003000000000000000000000000000000000000000103030200000000000000000000",
        ["bell"] = "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001030302000000000000000000000000000000000000010400000000030100000000000000000000000000000000000014839f27000001000000000000000000000000000102107ef2ffffff9e1c00010000000000000000000000000200b8ffd85940bbffbd1302010000000000000000000003003dffb9030000007fff7b0004000000000000000000000300a3ff450007040112f8df0601010000000000000000020026f9d309020100030099ff5b00030000000000000000030040ff800004000003003efe8100040000000000000000030041ff6d00040000020031ff8200040000000000000000040079ff3b0003000001000bfcbe0002000000000000000004007fff3d0003000001000dfbc400020000000000000000040078ff4102050202030210ffbe0002000000000000000003009efc0d00000000000000cfe004010000000000000001000decffc2c2c2c3c3c2c3c1efff360003000000000000010011e0effbfcfefbf9fffcfcf1ee3f00030000000000000000010f100d0e041019000e0d10100400000000000000000000000000000038d1e06400000000000000000000000000000000010104015bffff9601040101000000000000000000000000000000010028370000000000000000000000000000000000000000000100000100000000000000000000000000000000000000000002030000000000000000000000",
        ["eye"] = "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000202000000000000000000000000000000000000000103030000010401000000000000000000000000000002040000001b27000000030300000000000000000000000200000b4ba3ffffbf5e190000010000000000000000000300368aeeffffac98f9ffffa34c000101000000000000040063ffffcb711500000659b4ffff9700030100000000030061ffc734000073edfb9803002498ff950001010000020063ffc71000007dffdccbffbd04000095ff9705020003003bfeba1100040cf0d7bbcdbcff3402050089ff730004030047ff950005010ffccbcdedaeff4000080059ff87000400020a97ff96000105a2ffbeaeffde0e020061ffc71b02010001000096ff940a0008b6ffffd72c000161ffc710000100000001030097ffee8a33002430001e72d8ffc910000200000000000101006fccffffdc624dbeffffe08a1200020000000000000000010000368ae1fffff69f4b0500000100000000000000000000040100000448541300000004010000000000000000000000000003040000000003030100000000000000000000000000000000000103040100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
        ["search"] = "0000000000000000000000000000000000000000000000000000000000000000000101000000000000000000000000000000000000000104010000020300000000000000000000000000000000020000000f0e000001010000000000000000000000000002000e7dc6f1ecb9600000010000000000000000000000020029ccfffff3faffffa80b020100000000000000000001020fd1ffc44c121c62e2ff9d000200000000000000000004007dffc5080000000029e9ff41000300000000000000000104ccfd4500070101070084fe90000400000000000000010010f4f30f0101000003023dffbd00020000000000000001000eeef61602010000040248feb6000200000000000000000201befe600007030306009fff810004000000000000000003005fffe1290000000054fbf12702020000000000000000000302abffee88404d9effff9f10000200000000000000000001020e9afffffffffff49df8cd110002000000000000000000010000448bbab57d2610ccffc711000200000000000000000001010000000000000011c7ffc711000200000000000000000000030402030402020011c7ffc711000100000000000000000000000000000000020011c7ffc615010100000000000000000000000000000000020011c6ffba04030000000000000000000000000000000000020010b243010200000000000000000000000000000000000001000000000000000000000000000000000000000000000000010102000000000000000000000000000000000000000000000000000000",
        ["crosshair"] = "0000000000000000000000040500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100617f07000100000000000000000000000000000000000200d1ff0e000100000000000000000000000000000000000502bef80e040200000000000000000000000000000001010000c0f8050000020000000000000000000000000001000060c8ffffd8810d00020000000000000000000000010112bbffd28680bbffe1340002000000000000000000000200bcfd530000000032d7ed140102000000000000010206025fff500005000005001cf8a4020502020000000000000000ced200060056740006008cff050000000000040061c2bfc1fb84010157ffff8f000143feccc0c391000205007ffcf8f9ff7b020075ffffb600013dfdfef9fcbc00030000070e0f10debb0005038fb213040072ff240d0f0a000000000000000081ff2b00050000010007e1c80000000000000000010102030ce1da20000000000ba3ff2f0103010100000000000000020032ecfe8e474376e4ff6200020000000000000000000000020018a1feffffffc2350003000000000000000000000000000200000ecbfa23000003000000000000000000000000000000010500bdf907010300000000000000000000000000000000000201cdff0f00010000000000000000000000000000000000010091bc0a00010000000000000000000000000000000000000000000000000000000000000000000000000000000000000002030000000000000000000000",
        ["play"] = "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020200000000000000000000000000000000000000000003000003000000000000000000000000000000000000010015ab280000020000000000000000000000000000000001000ffdf26c050004010000000000000000000000000000010011eaffffc83700000300000000000000000000000000010011eefefbfffa830f0004010000000000000000000000010011eefffefdffffd94700000300000000000000000000010011eefffefffffbffff9e190000000000000000000000010011eefffefffffffdfeffe56608020000000000000000010011eefffefffffffefbffff9a0d020100000000000000010011eefffefffffcffffd4460000000000000000000000010011eefffefefcfffb8006000300000000000000000000010011eefffbffffbc370000030000000000000000000000010011ecfdfff06d0000040100000000000000000000000001000ff4ffa6260002020000000000000000000000000000010014da5b0000040000000000000000000000000000000000000810000202000000000000000000000000000000000000000000030000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
        ["pause"] = "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101000000000001010000000000000000000000000000010000010000000100000100000000000000000000000000001102000000000011020000000000000000000000000204a5eecc19010304a5eecc1901010000000000000000010012f8ffff44000012f8ffff4400030000000000000000010011ecfefd40000011ecfefd4000030000000000000000010011eeffff41000011eeffff4100030000000000000000010011eeffff41000011eeffff4100030000000000000000010011eeffff41000011eeffff4100030000000000000000010011eeffff41000011eeffff4100030000000000000000010011eeffff41000011eeffff4100030000000000000000010011eeffff41000011eeffff4100030000000000000000010011eeffff41000011eeffff4100030000000000000000010011eeffff41000011eeffff4100030000000000000000010011edfffe40000011edfffe4000030000000000000000010012f3fdff45000012f3fdff4500030000000000000000010109d0fff428000209d0fff428000200000000000000000001001441260001010014412600010000000000000000000000000000000100000000000001000000000000000000000000000103020000000001030200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
        ["stop"] = "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010101010101010101010000000000000000000000000002000000000000000000000300000000000000000000000100021110111111111011090001000000000000000000020035d2ededeeeeeeeeeeece262000200000000000000010108d9fffffffffffffffffffffe280002000000000000010012f1fdfdfefefefefefefefbff450003000000000000010011edfffefffffffffffffffdfe400003000000000000010011eefffefffffffffffffffdff410003000000000000010011eefffefffffffffffffffdff410003000000000000010011eefffefffffffffffffffdff410003000000000000010011eefffefffffffffffffffdff410003000000000000010011edfffefffffffffffffffdff400003000000000000010012eefefefffffffffffffffdfd43000300000000000001010decfffbfdfdfdfdfdfdfcfdff35000300000000000000020061f9ffffffffffffffffff96020200000000000000000001002742404141414141413500000000000000000000000000020000000000000000000001000000000000000000000000000203030303030303030300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
        ["refresh"] = "000000000000000000000000000000000000000000000000000000000000000000010303030303030303020000000000000000000000000103000000000000000000000100000000000000000000030000143d3c3d3d3e41414033000000000000000000000200035eecffffffffffffffffff530003000000000000020043cbffdd817e7f7db8ffffd0ff8800040000000000030051fffa7d0e000000000045ceedfe7e000400000000010205dafc34000004040404030024fafc7d000400000000030077ff90000601000000000006009bff810004000000010017eee90f020100000000000002011a48200001000000030040ff8a0004000000000000000000000000000000000003003cfe7b0104000000000000000000010301000000000003003cff7e00040000000000000000000000000000000000030041ff7d00040000000000000000000000000000000000020025fbd3030201000000000000000000000000000000000003009dff6700060000000000000000000000000000000000020116eef01200030303040401000000000000000000000000030074ffcf410000000000000000000000000000000000000003006cfaffa542447d8b2d00020000000000000000000000000200249dffffffffff4100030000000000000000000000000003000043523f190c04000000000000000000000000000000000203000000000000000000000000000000000000000000000000030303020100000000000000000000000000000000000000000000000000000000000000000000",
        ["download"] = "00000000000000000000000000000000000000000000000000000000000000000000000101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c1104000000000000000000000000000000000000000200afee3a000300000000000000000000000000000000000200beff3f000300000000000000000000000000000000000200bafe3e000300000000000000000000000000000000000200bbff3e000300000000000000000000000000000001030200bbff3e000501000000000000000000000000000000000400bbff3d020000010000000000000000000000010001400002bbff430035180001000000000000000000000203a0ff6400beff2d29f5d912010100000000000000000002026fffff59b2ff72e1ffa00b020100000000000000000000020064fffceffffeff99000001000000000000000000000000040065fffff8ff990003010000000000000000000000000000050065ffff9900030100000000000000000000000002020203060058760003030202020100000000000000000000000000000000000000000000000000000000000001000cafbbbabbbbbbbebfbcbbbbbbbabb30000200000000010013ffffffffffffffffffffffffffff470003000000000000043a3e3e3e3e3e3e3e3e3e3e3e3e3e1000010000000000000000000000000000000000000000000000000000000000000003030303030303030303030303030100000000000000000000000000000000000000000000000000000000",
        ["upload"] = "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002020202020202020202020202020100000000000000000000000000000000000000000000000000000000000001000cafbbbabbbbbbbbbbbbbbbbbbbabb30000200000000010013ffffffffffffffffffffffffffff470003000000000000043a3e3e3e3e403935413e3e3e3e3e100001000000000000000000000000000c1d00000000000000000000000000000000030303070038ebff670008030303010000000000000000000000040035ebfffeff65000400000000000000000000000000020035ecfffefbffff6500030000000000000000000000020034eaffa6eeea73ffff620002000000000000000000010117efff9303f2f60060ffff4000030000000000000000000203739f000ff4f31400719f0b0201000000000000000000000000000110f3f30f02000000000000000000000000000000000203000ff3f30f00030200000000000000000000000000000001000ff3f30f00010000000000000000000000000000000001000ff3f30f00010000000000000000000000000000000001000ff1f10f000100000000000000000000000000000000010010fefe100001000000000000000000000000000000000000043e3e0400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003030000000000000000000000000000000000000000000000000000000000000000000000",
        ["trash"] = "00000000000000000000000000000000000000000000000000000000000000000002020202020201000000000000000000000000000000000000000000000000000000000000000000000000000001000db5c2c1c2c1c2320002000000000000000000000102030213eefffefffdff4302050202000000000000000000000000000102020202020000000000000000000000030061c2bbbdbab7b6b6b6b6b6b9bcbbc19100020000000004007ffeffffffffffffffffffffffffffbc0002000000000001071cefecbab9b6babbb8b7bbd9fc490a03000000000000010009fcc0000005000000090077ff3a000300000000000001010efcc60280f112027ff1027aff3e010300000000000001000dfcc60088ff110087ff0079ff3d000300000000000001000dfcc60085fe110084fe0079ff3d000300000000000001000dfcc60086ff110085ff0079ff3d000300000000000001000dfcc60086ff110085ff0079ff3d000300000000000001000dfcc60085fd110084fd0079ff3d000300000000000001000dfcc70490ff16048fff047bff3d000300000000000001000dfbbe00112e00000f310072fd3c0003000000000000010010ffde7d776f7c7d76727dbbff42000300000000000000020598ffffffffffffffffffffc9150201000000000000000100003d3d3d3d3d3d3d3d3c3f0d000100000000000000000000000000000000000000000000010000000000000000000000000303030303030303030301000000000000000000000000000000000000000000000000000000000000",
        ["edit"] = "00000000000000000000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000002000100000000000000000000000000000000000000000200260001010000000000000000000000000000000000040062ff95000301000000000000000000000000000000040063ffebff9a00000100000000000000000000000000040061ffdc0e94ff950802000000000000000000000000040062ffdaf36600bbff36000300000000000000000000040061ffc90d69ffa1fac80f0201000000000000000000040061ffc71002009effca110001000000000000000000040061ffc710020063fdc4100002000000000000000000040061ffc710020060ffca100002000000000000000000030062ffc710020060ffc710000200000000000000000003005cffc610020060ffc7100002000000000000000000000104e5f016010060ffc710000200000000000000000000020022ffa9000061ffc7100002000000000000000000000004005ffc7c4a94ffc9100002000000000000000000000000030099ffffffffc212000200000000000000000000000000000019b6a45d260100020000000000000000000000000000000000000000000001000000000000000000000000000000000001010304020100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
        ["info"] = "00000000000000000000000101010000000000000000000000000000000000000303010000000303010000000000000000000000000001010000000d0d01000000020000000000000000000000020000429dd0fbfbdeae5b050003000000000000000000020019b5ffffedc3c3dfffffd53a000300000000000000020035e5ffa941090000022a8afffe6300030000000000020116e6ff63000000000500000038edff430003000000000200b7ff6200040406b0d81b03070033f1e6120101000003003effad0005010109deff29000205006cff7b0004000003009fff3a0203000100142400010001020feee0050100000104d5ed0601010000000607050000000300adff1b000201000efcc0010200000200b0f13a00030004017cfe3e000301000fffbe000200000200beff3f000300040079fe400003000107e2df030100000200bafe3e00030003009bff260002000300afff260102000200bbff3e0003010207e2ef07000100040058ff8d0005000200b9fd3d000304004aff9900030000010107daf93500050300c3ff4101080010d7fb250002000000020036fdeb33000003344613000011c5ff6e00030000000000030063fff66c1500000000054edaff97000300000000000000030046e8fff1b08081a1deffff6e00020100000000000000000300157ddaffffffffea992a00020100000000000000000000030000011a3d3d2508000003000000000000000000000000000103000000000000030200000000000000000000000000000000010203030201000000000000000000",
        ["warning"] = "0000000000000000000000020201000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000181905000000000000000000000000000000000000020127ebf25f0003000000000000000000000000000000000300a1ffffd80702010000000000000000000000000000020124fac89fff5b0003000000000000000000000000000003009eff5214fed805020100000000000000000000000003003bfdcb050090ff7700030000000000000000000000000200beff3a0a1212ebee1201010000000000000000000003013cffc000b2ef296eff7b0004000000000000000000000300bdff4001c2ff3b08f0ec0f01010000000000000000030051ffb80000bafe43007bff90000300000000000000010206dafa240000b9fd3e0107d8fc24010200000000000003005aff9d000600c3ff4100005aff9d00030000000000010203d8fa24010300334510000206d8f922000200000000030067ff9d000300000000000003005affa70003000000010112efec160102010045620301010303bfff3d0003000003007cff7e000603030df9ff34020505023fffbe00020001000fece30500000000006c90000000000000b1ff3c000304008dffecc0c3c2c2c2c2b5b3c0c2c2c2c3c2daffc40303030069eaf0fdfcfcfcfcfcfffffdfcfcfcfcfcf4ee7502030000000f100d0e0e0e0e0e0e0e0e0e0e0e0e0e0f11000000000002000000000000000000000000000000000000010000000000010101010101010101010101010101010101000000",
        ["error"] = "00000000000000000000000101010000000000000000000000000000000000000303010000000303010000000000000000000000000001010000000d0d01000000020000000000000000000000020000429dd0fbfbdeae5b050003000000000000000000020019b5ffffedc2c3dfffffd53a000300000000000000020035e5ffab43080000012b8efffe6300030000000000020116e6ff64000000020200000033edff430003000000000200b7ff6400341d00030102007e0f30f2e6120101000003003effb00039fecd1100040096ffc0006eff7b0004000003009fff3b0122cbffc70f0099ffe93f0412eee0050100000104d5ed06010010c7ffbd98ffec35000500adff1b000201000efcc00102020012baffffdd32000404017cfe3e000301000fffbe000201040098ffffc90a0002040179fe400003000107e2df0301000099ffe3cbffca110005009bff260002000300afff27010d97ffeb2f09c8ffc6150409e2ef07000100040058ff900046ffee35000012c6ffbf004dff9900030000010107daf9370069410004020010b73e0ed9fb250002000000020036fdea34000005040405000007c4ff6e00030000000000030063fff66f1700000000074fdcff97000300000000000000030046e8fff1b07e7ea0deffff6e00020100000000000000000300157ddaffffffffea992a00020100000000000000000000030000011a3d3d2508000003000000000000000000000000000103000000000000030200000000000000000000000000000000010203030201000000000000000000",
        ["success"] = "00000000000000000000000101010000000000000000000000000000000000000303010000000303010000000000000000000000000001010000000d0d01000000020000000000000000000000020000429dd0fbfbdeae5b050003000000000000000000020019b5ffffedc2c3dfffffd53a000300000000000000020035e5ffa941080000012a8afffe6300030000000000020116e6ff63000000020200000039eeff430003000000000200b7ff62000403010000000300002ef2e6120101000003003effad0005010000000003003ab70d67ff7b0004000003009fff3a020501000000030021eaff7604f1e0050100000104d5ed060200000100030011c7ff960500aeff1b000201000efcc00100301a00040011c6ffc30103017cfe3e000301000fffc00035fecd130013c7ffc71202060079fe400003000107e2e00522ccffca1ba5ffc611000203009bff260002000300afff280011c8ffe4ffdc110003000207e2ef07000100040058ff8d000211c6ffeb3400030004004aff9900030000010107daf9350002117e31000300040010d7fb250002000000020036fdeb33000000000603000011c5ff6e00030000000000030063fff66c1600000000054edaff97000300000000000000030046e8fff1b07e7ea0deffff6e00020100000000000000000300157ddaffffffffea992a00020100000000000000000000030000011a3d3d2508000003000000000000000000000000000103000000000000030200000000000000000000000000000000010203030201000000000000000000",
        ["star"] = "0000000000000000000000010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000111303000000000000000000000000000000000000010114d9e842000300000000000000000000000000000000030080ffffa70003000000000000000000000000000000010108f4b599fc130002000000000000000000010404040306005aff491eff7d000603040404010000000000000000000000dddf0601d4e400000000000000000001001a7f7e8ab1d0dbff5d00005effdbd0b18a7e7f1a0001020128ffffdbac8f8b6b030101026c8b8facdbffff2801020002002bcac4000000000000000000000000c4ca2b000200000002000fd8de27000500000000050027ded80f0002000000000003000eb1ee3701020000020137eeb10e000300000000000000020000dfc8000303040400c8df000002000000000000000001010ff78503020000000385f70f0101000000000000000003003fff4100057993190041ff3f00030000000000000000040085f60142daffffef5b05f586000400000000000000000200c6d8abffee5742d9ffb6e0c4000200000000000000010018f2ffff821400000579fdfff2180001000000000000020021e3b92800000303000023b8e32100020000000000000000000b000003010000010400000b000000000000000000000001000102000000000000020100010000000000000000000000010000000000000000000001000000000000000000000000000000000000000000000000000000000000",
        ["heart"] = "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101000000000000010100000000000000000000000003020000010300000302000001030000000000000000000200000f110000010300000f1100000100000000000000020043b1eaedc662000044b1eaedc66100010100000000020065ffffffffffff8f60ffffffffffff9a0203000000030040fffcfbfefefcfcfffffefbfefefcf9ff7b000300000301b7fefbfffffffffffdfdfffffffffffdfdea100101010010ecfffefffffffffffffffffffffffffffdff3f0003010012f0fffefffffffffffffffffffffffffffdff450003000204cbfdfcfffffffffffffffffffffffffefcf41c000100030060fff9fdfffffffffffffffffffffef8ffa1000300000002029afffffcfefffffffffffffffcffffca1302010000000101007ce4fffffffffffffffffdfff29e12000100000000000001000d52f4fdfefffffffcff751b000001000000000000000003000062fffbfffffcff9e00000301000000000000000000000106009efffcfdffd10b04030000000000000000000000000001030bddfffbfc310003000000000000000000000000000000020037faff6f0004000000000000000000000000000000000004007db600040000000000000000000000000000000000000002030b0001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010000000000000000000000",
        ["lock"] = "0000000000000000000000020200000000000000000000000000000000000000000203000003030000000000000000000000000000000000000000172700000000000000000000000000000000000002003a9bf9ffb34c010200000000000000000000000000030077ffffb99cffffa200010000000000000000000000020124f0ff49000020eaff5500030000000000000000000003009bffa60004070068ffcc0502000000000000000000000201c3fd230204020404dbf50e00010000000000000000000400c0fc060000000000bdfd0b03010000000000000000010001c3f91b0d0e0d0f0ec4f914000200000000000000020035d5fffffdfcfcfcfcfcffffea6200020000000000010107ddf9bdbec2c2c2c3c2c2c0bde4fe2700020000000001000effbd0000000000000000000076ff4100030000000001000dfbc3020403010006000306027efe3c00030000000001000dfcc200030205b0d81b0106007dff3d00030000000001000dfcc200040209ddff290006007dff3d00030000000001000dfcc2000201001829000104007dff3d00030000000001000dfbc3040604050000050408047fff3c00030000000001000efdbd0000000000000000000073fd3f00030000000001010bf3e27c7e7d7d7d7d7d7d7f7dbdff3300030000000000020060feffffffffffffffffffffff960302000000000000000100263e3c3d3d3d3d3d3d3d3d33000000000000000000000002000000000000000000000000010000000000000000000000020303030303030303030303000000000000",
        ["unlock"] = "0000000000000000000000020200000000000000000000000000000000000000000203000001040100000000000000000000000000000000000000172800000000000000000000000000000000000002003a9bf7ffca72250101000000000000000000000000030077ffffba9ceeff5500030000000000000000000000020124f0ff4900000b430a0001000000000000000000000003009bffa6000404000000000000000000000000000000000201c3fd23020401020402010100000000000000000000000400c0fc06000000000000000003000000000000000000010001c3f91b0d0e0d0d0d0d0e08000100000000000000020035d5fffffdfcfcfcfcfcfbfae96200020000000000010107ddf9bdbec2c2c2c3c2c2c3c1e4fe2700020000000001000effbd0000000000000000000075ff4100030000000001000dfbc3020403010006000306027efe3c00030000000001000dfcc200030205b0d81b0106007dff3d00030000000001000dfcc200040209ddff290006007dff3d00030000000001000dfcc2000201001829000104007dff3d00030000000001000dfbc3040604050000050408047fff3c00030000000001000efdbd0000000000000000000073fd3f00030000000001010bf3e27c7e7d7d7d7d7d7d7f7dbdff3300030000000000020060feffffffffffffffffffffff960302000000000000000100263e3c3d3d3d3d3d3d3d3d33000000000000000000000002000000000000000000000000010000000000000000000000020303030303030303030303000000000000",
        ["power"] = "00000000000000000000000101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c1104000000000000000000000000000000010000000200afee3a000300000100000000000000000001000100000200beff3f000300020001000000000000000100130000000200bafe3e000300001200010000000000020014e37402020200bbff3e0004038bd8140101000000010209c3ffa303030300bbff3e00050299ff96000300000003004bffd50901010200bbff3e00040008e9f243000300000300acfe6c0004000200bbff3e000303029dffad000300000201c1fe380103000200b9fd3d0003030032ffe30a000101000eeff4130001000200c3ff410003010109defe31000201000ef0f30d00010001003041100001000105d3fe2d0002000201c2fe2f01020000000000000000020126fde50b0001000300acfe6e0004000000020301000004006efeaa0003000003004bffd60a020300000000000003020ad5ff4b00030000010209c4ff9a000003030101030400009bffb5070201000000020016e6ffb72a0000000000001ea5ffe71700020000000000020026a5fffbac4e191a4e9ef6ffd73600020000000000000001000074f3fffffffdffffeb891100020000000000000000000202001b6d8cd0da9b5e160000020000000000000000000000000200000000030000000301000000000000000000000000000001040400000304010000000000000000000000000000000000000000010000000000000000000000",
        ["layers"] = "000000000000000000000000000000000000000000000000000000000000000000000103030200000000000000000000000000000000000001040000000004010000000000000000000000000000000300000d768725000003010000000000000000000000020200045edefffff97d1500000300000000000000000103000041c9fff16341d8ffea5e05000202000000000003000029b5ffff80140000055eeaffd64600000200000001001a9fffff9c29000003030000157df9ffbe37000100030167e8ffac3b00000301000001040000238df8f976010303006bfff77508000103000000000203000051e1ff91000400010048d9ffed5e050002020103000041cbfff26d070201000001000056eeffd6460000000029b5ffff7d050000000000000005781a047afcffbb30139dffff9e1a00711e01010000020024fffe7800169cfffff3ffbd340056e0ff5c0003000000010949d8ffe2570028bed74c0036c0fff26d110201000000000000006df3ffcc3800001ca7ffff930f0000000000000000037a2c000b83ffff9f7cffffa924000f781c00010000020024ffff9f240020a9ffffcc3d000c7ff1ff5c0003000000010943baffff9f2000394f00077ef3ffd85e1101000000000000000042bbffff9e19037cf4ffd85e050000000000000000000302000042bbfffff7ffd85e05000003010000000000000000000302000042bcd45d05000003010000000000000000000000000003010000000000030100000000000000000000000000000000000301000401000000000000000000",
        ["globe"] = "00000000000000000000000101010000000000000000000000000000000000000303010000000303010000000000000000000000000001010000000e0d02000000020000000000000000000000020000429ec8f8fbd5ad5b050003000000000000000000020019b5ffffffd0c3ffffffd63a000300000000000000020035e9ffa4e6dc0200a1f999ffff6400030000000000020117e5f35010fb68040629ff4b24dbfe430003000000000200b6ffdc287dfd00000000d3c41eaeffe4140101000003003fffbeaef8f9ffa4929397f3fbf9c9a1ff7d0004000003009fff3c0022ddce8e9fa495aafc3c000ef1e0050100000103d6e8000000f9750000000025fe230000a3ff1b0002010010f5e084848bffc5888a8988a4ffa58485befe410003010012f1fcfffffffefffffffffffffffffffffbfe450003000107e1e2111019ff83000000003eff49100ca1ff260002000300afff200000dbaf4254594876fb160000dfef07000100040059ff9a73dbfdffd5cbcccdfbffe5926fff9a00030000010108d8ffeb6ea4fb07000000ced863cdfff9280002000000020036fbdc171cff49050714fc6600b6ff6d00030000000000030063fff969e7c500007ffc69d6ff98000300000000000000030046e8ffffff927ef3ffffff6e00020100000000000000000300157dd6f4fffffde1992a00020100000000000000000000030000031d3d3d280a000003000000000000000000000000000103000000000000030200000000000000000000000000000000010203030201000000000000000000",
        ["zap"] = "00000000000000000000000000010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100192500010000000000000000000000000000000000000402aa3b00020000000000000000000000000000000000050084ff0900010000000000000000000000000000000004005dffd3080101000000000000000000000000000000020034f3ffbd0002000000000000000000000000000000010213deffff9f00030000000000000000000000000000010400bbfff7ff830409040402000000000000000000000004008ffffbfcff53000000000000000000000000000000030065fffcfefeff9b7f817d8350000200000000000000020037fcfbfcfdffffffffffffff340102000000000000020123f4fffffffffffffcfaf8f934000200000000000000010020444043415bf7fffefcff67000400000000000000000000000000000034fffdfbff980004000000000000000000000001030307036ffff7ffbb0004010000000000000000000000000000040093ffffde1302020000000000000000000000000000000202c1ffed34000200000000000000000000000000000001000be7ff52000400000000000000000000000000000000020023ff810005000000000000000000000000000000000003005dac000400000000000000000000000000000000000002004a1600010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020100000000000000000000000000",
        ["settings-sliders"] = "0000000000000000000000000000000000000000000000000000000000000000010100000000000000000000000000000000000000000002000003000000000000000000000000000000000002020300010800020202020202020202010000000000000000000035dff761000000000000000000000000000001000db5c3bff0c6a1ffc3c2c2c2c2c2c2c0c23100020000010011ebfcf8ff9a64fffbfcfcfcfcfcfcfafc40000300000000010d100e66ffff9711100e0e0e0d0d0d0d030000000000000000000000283600000000000000000000000000000000000003040305000004030400020900030303010000000000000000000000000000000035dff761000000000000000001000db5c2c1c2c2c2c2c3c0f0c6a1ffc3c0c23100020000010011ebfcfbfcfcfcfcfcf9ff9a64fffbfafc40000300000000010d0d0e0e0d0d0d100e66ffff97110f0e03000000000000000000000000000000000028360000000000000000000000000400020900030303030500000404030401000000000000010035dff7610000000000000000000000000000000001000eb3f0c5a1ffc3c2c2c2c2c2c2c2c2c0c23100020000010011e8ff9964fffbfcfcfcfcfcfcfcfcfafc40000300000000030d66ffff9711100e0d0d0d0d0d0d0d0d03000000000000000000283600000000000000000000000000000000000000000102000001010101010101010101010100000000000000000000020300000000000000000000000000000000000000000000000000000000000000000000000000000000",
        ["keyboard"] = "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010101010101010101010101010101010000000000000002000000000000000000000000000000000300000000000100010e0d0d0e0e0d0e0e0d0e0e0d0d0e080001000000020034d6fdfefefffffefffffefffffefefdea62000200010107ddf7b3b6bbb6b5bbb6b5bbb6b5bbb7b4dffe270002010010fec396b62096b52096b52096b5209ab19cff43000301000ff8cedcff46dcff46dcff46dcff46e0feb6fe3f000301000efdbe000300000100000100000100000076ff3d000301000ffac99fbe2ea0be2ea0be2ea0be2ea4baa4ff3f000301000ff9cdd8fe45daff45daff45daff45dcfab4ff40000301000efdbf070f00000100000100000100090b7aff3d000301000efbc4020fbbc3c1c7c3c2c7c3c0c7380182ff3c000301000ffdbe0001d9eae9e9eaeae9eae8e9330076fd3f000301010bf3e27c7f8a8b8a8b8b8b8b8b8a8b837dbdff34000300020060feffffffffffffffffffffffffffffff9603020000000100263d3c3e3e3e3e3e3e3e3e3e3e3d3d3300000000000000020000000000000000000000000000000001000000000000000203030303030303030303030303030300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
        ["sparkles"] = "00000000000000000101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000911010000000000000000000000000000000000000004007bee0b00010000000000000000000000000000000000040086ff0c00010000000000000000000000000000000404080486fe100405040100000000000000000000000000000000007aff0000000000000000000000000000000100097b848584c4ff8a8483842200020000000000000000010011f0ffffffffffffffffff42000300000000000000000000010b0c100c8aff180c0d0c03000204000000000000000000000000000082ff0800000000000000000000000000000000000101050183fd0d0102010200428006000100000000000000000209008aff0d000102090490ff1104040000000000000000000000224103000000000078fb0000000000000000000404447f0a0000000200428682c4ff888463000100000000000084ff00000400040081fffeffffffffc00002000002004484bff989620001000006100c88fc170c0a00000000040081fffbf9ffc00002000000000089ff0900000000000000000a0c91ff18090100000001040163be0a0102000000000000010060be0500010000000000000000000000000000000000000100000101000000000000000102000000000000000000000001020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
},
    Alias = { settings = "gear" },
    Raw = {},
    Cache = {},
}

function IconImage.hex(hex)
    local out = {}
    for i = 1, #hex, 2 do
        out[#out + 1] = string.char(tonumber(string.sub(hex, i, i + 1), 16) or 0)
    end
    return table.concat(out)
end

function IconImage.u32(n)
    return string.char(
        math.floor(n / 16777216) % 256, math.floor(n / 65536) % 256,
        math.floor(n / 256) % 256, n % 256
    )
end

function IconImage.u16(n)
    return string.char(n % 256, math.floor(n / 256) % 256)
end

function IconImage.crc(data)
    local crc = 0xFFFFFFFF
    for i = 1, #data do
        crc = bit32.bxor(crc, string.byte(data, i))
        for _ = 1, 8 do
            local low = bit32.band(crc, 1)
            crc = bit32.rshift(crc, 1)
            if low ~= 0 then crc = bit32.bxor(crc, 0xEDB88320) end
        end
    end
    return bit32.bxor(crc, 0xFFFFFFFF)
end

function IconImage.chunk(kind, data)
    local body = kind .. data
    return IconImage.u32(#data) .. body .. IconImage.u32(IconImage.crc(body))
end

function IconImage.png(mask, r, g, b)
    local rows, at = {}, 1
    local rgbBytes = string.char(r, g, b)
    for _ = 1, 24 do
        local row = { string.char(0) }
        for _ = 1, 24 do
            row[#row + 1] = rgbBytes .. string.char(string.byte(mask, at) or 0)
            at = at + 1
        end
        rows[#rows + 1] = table.concat(row)
    end

    local raw, adlerA, adlerB = table.concat(rows), 1, 0
    for i = 1, #raw do
        adlerA = (adlerA + string.byte(raw, i)) % 65521
        adlerB = (adlerB + adlerA) % 65521
    end

    local z, pos = { string.char(120, 1) }, 1
    while pos <= #raw do
        local count = math.min(65535, #raw - pos + 1)
        local final = (pos + count - 1 >= #raw) and 1 or 0
        z[#z + 1] = string.char(final) .. IconImage.u16(count)
            .. IconImage.u16(65535 - count) .. string.sub(raw, pos, pos + count - 1)
        pos = pos + count
    end
    z[#z + 1] = IconImage.u32(adlerB * 65536 + adlerA)

    local header = IconImage.u32(24) .. IconImage.u32(24) .. string.char(8, 6, 0, 0, 0)
    return string.char(137,80,78,71,13,10,26,10)
        .. IconImage.chunk("IHDR", header)
        .. IconImage.chunk("IDAT", table.concat(z))
        .. IconImage.chunk("IEND", "")
end

function IconImage.bytes(name, color)
    local key = string.lower(tostring(name or ""))
    key = IconImage.Alias[key] or key
    local encoded = IconImage.Masks[key]
    if not encoded then return nil end

    local r = math.floor(math.max(0, math.min(1, color.R)) * 255 + 0.5)
    local g = math.floor(math.max(0, math.min(1, color.G)) * 255 + 0.5)
    local b = math.floor(math.max(0, math.min(1, color.B)) * 255 + 0.5)
    local cacheKey = key .. ":" .. r .. ":" .. g .. ":" .. b
    if IconImage.Cache[cacheKey] then return IconImage.Cache[cacheKey] end

    local raw = IconImage.Raw[key]
    if not raw then
        raw = IconImage.hex(encoded)
        IconImage.Raw[key] = raw
    end
    local ready = IconImage.png(raw, r, g, b)
    IconImage.Cache[cacheKey] = ready
    return ready
end

local function DrawIconByName(name, x, y, size, color, z, alpha, thickness)
    if not name then return false end
    local bytes = IconImage.bytes(name, color)
    if not bytes then return false end

    local image, last = Take("Image")
    if last.Data ~= bytes then last.Data = bytes; image.Data = bytes end

    local px, py = math.floor(x + 0.5), math.floor(y + 0.5)
    local sz = math.max(1, math.floor(size + 0.5))
    if last.X ~= px or last.Y ~= py then
        last.X, last.Y = px, py
        image.Position = Vector2.new(px, py)
    end
    if last.Size ~= sz then last.Size = sz; image.Size = Vector2.new(sz, sz) end

    local depth = Layer(z)
    if last.Z ~= depth then last.Z = depth; image.ZIndex = depth end
    local shade = math.max(0, math.min(1, alpha or 1))
    if last.Alpha ~= shade then last.Alpha = shade; image.Transparency = shade end
    pcall(function() image.Rounding = 0 end)
    return true
end

local NoAnim = false

local function Approach(current, target, speed, dt)
    if NoAnim then return target end
    return current + (target - current) * (1 - math.exp(-speed * (dt or (1 / 60))))
end

local function Snap(current, target, speed, epsilon, dt)
    local v = Approach(current, target, speed, dt)
    if math.abs(v - target) < epsilon then return target end
    return v
end

local Input = {
    X = 0, Y = 0,
    PrevX = 0, PrevY = 0,
    DX = 0, DY = 0,

    Down = false,
    RightDown = false,
    MidDown = false,

    Click = false,
    RightClick = false,
    MidClick = false,

    Up = false,
    Wheel = 0,
}

local PrevMouseState = { L = false, R = false, M = false }
local PrevWheel = 0

local function ReadInput()
    Input.PrevX, Input.PrevY = Input.X, Input.Y

    local mx = tonumber(Mouse.X) or Input.PrevX or 0
    local my = tonumber(Mouse.Y) or Input.PrevY or 0
    Input.X, Input.Y = mx, my
    Input.DX = Input.X - Input.PrevX
    Input.DY = Input.Y - Input.PrevY

    local l = ismouse1pressed()
    local r = ismouse2pressed()
    local m = iskeypressed(0x04)

    Input.Down      = l
    Input.RightDown = r
    Input.MidDown   = m

    Input.Click      = l and not PrevMouseState.L
    Input.RightClick = r and not PrevMouseState.R
    Input.MidClick   = m and not PrevMouseState.M

    Input.Up = (not l) and PrevMouseState.L

    PrevMouseState.L = l
    PrevMouseState.R = r
    PrevMouseState.M = m

    local wheel = 0
    local gotWheel = false

    local function acceptWheel(value)
        value = tonumber(value)
        if value ~= nil and value ~= 0 then
            wheel = value
            gotWheel = true
        end
    end

    pcall(function()
        if mousewheel then acceptWheel(mousewheel()) end
    end)
    if not gotWheel then
        pcall(function()
            if getwheel then acceptWheel(getwheel()) end
        end)
    end
    if not gotWheel then
        pcall(function()
            if Mouse and Mouse.WheelDelta ~= nil then acceptWheel(Mouse.WheelDelta) end
        end)
    end

    if wheel > 0 then
        Input.Wheel = math.min(wheel, 3)
    elseif wheel < 0 then
        Input.Wheel = math.max(wheel, -3)
    else
        Input.Wheel = 0
    end

end

local function MouseIn(x, y, w, h)
    local mx = tonumber(Input.X) or 0
    local my = tonumber(Input.Y) or 0
    x = tonumber(x) or 0
    y = tonumber(y) or 0
    w = tonumber(w) or 0
    h = tonumber(h) or 0
    return (mx >= x) and (mx <= x + w)
       and (my >= y) and (my <= y + h)
end

local function MouseInCircle(cx, cy, radius)
    local mx = tonumber(Input.X) or 0
    local my = tonumber(Input.Y) or 0
    local dx = mx - cx
    local dy = my - cy
    return (dx * dx + dy * dy) <= (radius * radius)
end

local Keys = {}
local KeyList = {}

local function AddKey(name, code, char, shifted)
    local entry = {
        Name    = name,
        Code    = code,
        Char    = char,
        Shifted = shifted,
        Held    = false,
        Click   = false,
    }
    Keys[name] = entry
    KeyList[#KeyList + 1] = entry
end

AddKey("MB1", 0x01)
AddKey("MB2", 0x02)
AddKey("MB3", 0x04)
AddKey("MB4", 0x05)
AddKey("MB5", 0x06)

AddKey("Backspace",  0x08)
AddKey("Tab",        0x09)
AddKey("Enter",      0x0D)
AddKey("Shift",      0x10)
AddKey("Ctrl",       0x11)
AddKey("Alt",        0x12)
AddKey("Pause",      0x13)
AddKey("Caps",       0x14)
AddKey("Escape",     0x1B)
AddKey("Space",      0x20, " ", " ")

AddKey("PageUp",     0x21)
AddKey("PageDown",   0x22)
AddKey("End",        0x23)
AddKey("Home",       0x24)
AddKey("Left",       0x25)
AddKey("Up",         0x26)
AddKey("Right",      0x27)
AddKey("Down",       0x28)
AddKey("Insert",     0x2D)
AddKey("Delete",     0x2E)
AddKey("PrintScreen",0x2C)
AddKey("Select",     0x29)
AddKey("Execute",    0x2B)
AddKey("Help",       0x2F)

AddKey("LeftWin",    0x5B)
AddKey("RightWin",   0x5C)
AddKey("Apps",       0x5D)
AddKey("Sleep",      0x5F)

AddKey("LeftShift",  0xA0)
AddKey("RightShift", 0xA1)
AddKey("LeftCtrl",   0xA2)
AddKey("RightCtrl",  0xA3)

AddKey("Num0", 0x60)
AddKey("Num1", 0x61)
AddKey("Num2", 0x62)
AddKey("Num3", 0x63)
AddKey("Num4", 0x64)
AddKey("Num5", 0x65)
AddKey("Num6", 0x66)
AddKey("Num7", 0x67)
AddKey("Num8", 0x68)
AddKey("Num9", 0x69)
AddKey("NumMultiply", 0x6A, "*")
AddKey("NumAdd",      0x6B, "+")
AddKey("NumSeparator",0x6C)
AddKey("NumSubtract", 0x6D, "-")
AddKey("NumDecimal",  0x6E, ".")
AddKey("NumDivide",   0x6F, "/")

for i = 0, 25 do
    local lower = string.char(97 + i)
    local upper = string.upper(lower)
    AddKey(upper, 0x41 + i, lower, upper)
end

local shiftedNums = { ")", "!", "@", "#", "$", "%", "^", "&", "*", "(" }
for i = 0, 9 do
    AddKey("N" .. i, 0x30 + i, tostring(i), shiftedNums[i + 1])
end

for i = 1, 24 do
    AddKey("F" .. i, 0x6F + i)
end

AddKey("Minus",    0xBD, "-", "_")
AddKey("Equals",   0xBB, "=", "+")
AddKey("LBracket", 0xDB, "[", "{")
AddKey("RBracket", 0xDD, "]", "}")
AddKey("Semicolon",0xBA, ";", ":")
AddKey("Quote",    0xDE, "'", "\"")
AddKey("Comma",    0xBC, ",", "<")
AddKey("Period",   0xBE, ".", ">")
AddKey("Slash",    0xBF, "/", "?")
AddKey("Backslash",0xDC, "\\", "|")
AddKey("Grave",    0xC0, "`", "~")
AddKey("NumLock",  0x90)
AddKey("ScrollLock",0x91)
AddKey("BrowserBack",    0xA6)
AddKey("BrowserForward", 0xA7)
AddKey("BrowserRefresh", 0xA8)
AddKey("BrowserStop",    0xA9)
AddKey("BrowserSearch",  0xAA)
AddKey("BrowserFavorites",0xAB)
AddKey("BrowserHome",    0xAC)
AddKey("VolumeMute",     0xAD)
AddKey("VolumeDown",     0xAE)
AddKey("VolumeUp",       0xAF)
AddKey("MediaNext",      0xB0)
AddKey("MediaPrev",      0xB1)
AddKey("MediaStop",      0xB2)
AddKey("MediaPlayPause", 0xB3)

Keys._ActiveNames = Keys._ActiveNames or {}
Keys._ActiveSet = Keys._ActiveSet or {}

function Keys.Track(name)
    if not name then return end
    for segment in string.gmatch(tostring(name), "[^+]+") do
        local keyName = string.upper(segment)
        if Keys[keyName] and not Keys._ActiveSet[keyName] then
            Keys._ActiveSet[keyName] = true
            Keys._ActiveNames[#Keys._ActiveNames + 1] = keyName
        end
    end
end

local function ReadKeys(runtimeState, focusState, captureState)

    if (focusState and focusState.Field ~= nil) or runtimeState.Focus ~= nil or (captureState and captureState.Active ~= nil) then
        for i = 1, #KeyList do
            local k = KeyList[i]
            local held = iskeypressed(k.Code)
            k.Click = held and not k.Held
            k.Held = held
        end
        return
    end

    for i = 1, #KeyList do KeyList[i].Click = false end
    Keys.Track(runtimeState.MenuKey)

    for i = 1, #Keys._ActiveNames do
        local k = Keys[Keys._ActiveNames[i]]
        if k then
            local held = iskeypressed(k.Code)
            k.Click = held and not k.Held
            k.Held = held
        end
    end
end

local function AnyKeyClicked()
    for i = 1, #KeyList do
        local k = KeyList[i]
        if k.Click and k.Name ~= "Shift" and k.Name ~= "Ctrl"
           and k.Name ~= "Alt" and k.Name ~= "LeftShift"
           and k.Name ~= "RightShift" and k.Name ~= "LeftCtrl"
           and k.Name ~= "RightCtrl" then
            return k
        end
    end
    return nil
end

local KeyLabel = {}
local KeyAlias = {
    mb1 = "MB1", mb2 = "MB2", mb3 = "MB3", mb4 = "MB4", mb5 = "MB5",
    mouse1 = "MB1", mousebutton1 = "MB1", lmb = "MB1",
    mouse2 = "MB2", mousebutton2 = "MB2", rmb = "MB2",
    escape = "Esc", ["return"] = "Enter", control = "Ctrl",
    pgup = "PgUp", pgdn = "PgDn", space = "Space",
    leftshift = "LShift", rightshift = "RShift",
    leftctrl = "LCtrl", rightctrl = "RCtrl",
    printscreen = "PrtSc", scrolllock = "ScrLk", numlock = "NumLk",
    leftwin = "LWin", rightwin = "RWin", mediaplaypause = "Play",
    medianext = "Next", mediaprev = "Prev", volumemute = "Mute",
    volumeup = "Vol+", volumedown = "Vol-",
}

function KeyLabel.Format(value)
    if not value or value == "" then return "none" end
    local parts = {}
    for segment in string.gmatch(value, "[^+]+") do
        parts[#parts + 1] = segment
    end
    for i = 1, #parts do
        local lower = string.lower(parts[i])
        parts[i] = KeyAlias[lower] or string.upper(parts[i])
    end
    return table.concat(parts, "+")
end

local TextEditor = {}
local RepeatDelay = 0.4
local RepeatRate  = 0.03

local CurrentRepeatKey = nil
local NextRepeatAt = 0

local function RepeatHeld(key)
    local now = os.clock()
    if key.Click then
        CurrentRepeatKey = key
        NextRepeatAt = now + RepeatDelay
        return true
    end
    if not key.Held then return false end
    if CurrentRepeatKey ~= key then return false end
    if now < NextRepeatAt then return false end
    NextRepeatAt = now + RepeatRate
    return true
end

local function ShiftHeld()
    return Keys.Shift.Held or Keys.LeftShift.Held or Keys.RightShift.Held
end

local function CtrlHeld()
    return Keys.Ctrl.Held or Keys.LeftCtrl.Held or Keys.RightCtrl.Held
end

local function TypedChar()
    local shifted = ShiftHeld()
    for i = 1, #KeyList do
        local k = KeyList[i]
        if k.Char and RepeatHeld(k) then
            return shifted and k.Shifted or k.Char
        end
    end
    return nil
end

local function ProcessText(row, allowed, onCommit)
    local value  = row.Value  or ""
    local caret  = math.min(math.max(row.Caret or #value, 0), #value)
    local anchor = row.Anchor and math.min(math.max(row.Anchor, 0), #value) or nil
    local selected = anchor ~= nil and anchor ~= caret
    local low  = selected and math.min(anchor, caret) or caret
    local high = selected and math.max(anchor, caret) or caret

    local function Commit(text, newCaret)
        row.Value  = text
        row.Caret  = newCaret
        row.Anchor = nil
    end

    if CtrlHeld() then
        if Keys.A.Click then row.Anchor, row.Caret = 0, #value; Keys.A.Click = false end
        if Keys.C.Click and selected then
            pcall(setclipboard, string.sub(value, low + 1, high))
            Keys.C.Click = false
        end
        if Keys.X.Click and selected then
            pcall(setclipboard, string.sub(value, low + 1, high))
            Commit(string.sub(value, 1, low) .. string.sub(value, high + 1), low)
            Keys.X.Click = false
        end
        if Keys.V.Click then
            local clip = nil
            pcall(function() clip = getclipboard() end)
            if clip and clip ~= "" then
                if allowed then
                    local filtered = ""
                    for i = 1, #clip do
                        local c = string.sub(clip, i, i)
                        if string.match(c, allowed) then filtered = filtered .. c end
                    end
                    clip = filtered
                end
                Commit(
                    string.sub(value, 1, low) .. clip .. string.sub(value, high + 1),
                    low + #clip
                )
            end
            Keys.V.Click = false
        end
    end

    local step = Keys.Left.Click and -1 or (Keys.Right.Click and 1) or nil
    local jump = Keys.Home.Click and 0 or (Keys.End.Click and #value) or nil

    if step or jump then
        local moved = jump
        if step then
            if selected and not ShiftHeld() then
                moved = step < 0 and low or high
            else
                moved = math.min(math.max(caret + step, 0), #value)
            end
        end
        row.Anchor = ShiftHeld() and (anchor or caret) or nil
        row.Caret  = moved

        Keys.Left.Click  = false
        Keys.Right.Click = false
        Keys.Home.Click  = false
        Keys.End.Click   = false
    end

    if Keys.Enter.Click or Keys.Escape.Click then
        if onCommit then onCommit(value) end
        return "done"
    end

    if RepeatHeld(Keys.Backspace) then
        if selected then
            Commit(string.sub(value, 1, low) .. string.sub(value, high + 1), low)
        elseif caret > 0 then
            Commit(string.sub(value, 1, caret - 1) .. string.sub(value, caret + 1), caret - 1)
        end
        return "edit"
    end

    if RepeatHeld(Keys.Delete) then
        if selected then
            Commit(string.sub(value, 1, low) .. string.sub(value, high + 1), low)
        elseif caret < #value then
            Commit(string.sub(value, 1, caret) .. string.sub(value, caret + 2), caret)
        end
        return "edit"
    end

    local c = TypedChar()
    if not c then return nil end
    if allowed and not string.match(c, allowed) then return nil end
    Commit(
        string.sub(value, 1, low) .. c .. string.sub(value, high + 1),
        low + 1
    )
    return "edit"
end

local Capture = {
    Active = nil,
}

local function BeginCapture(bind, onSet)
    Capture.Active = { Target = bind, OnSet = onSet }
end

local function CancelCapture()
    Capture.Active = nil
end

local function UpdateCapture()
    if not Capture.Active then return end

    if Keys.Escape.Click then
        Capture.Active = nil
        return
    end

    local hit = AnyKeyClicked()
    if not hit then return end

    local name = string.lower(hit.Name)
    local target = Capture.Active
    Capture.Active = nil

    if target.OnSet then
        target.OnSet(name)
    end
end

local Focus = {
    Field = nil,
}

local function SetFocus(field)
    if Focus.Field == field then return end
    if Focus.Field and Focus.Field.OnBlur then Focus.Field.OnBlur() end
    Focus.Field = field
    if field then
        field.Caret  = field.Caret or #(field.Value or "")
        field.Anchor = nil
    end
end

local function ClearFocus()
    if Focus.Field and Focus.Field.OnBlur then Focus.Field.OnBlur() end
    Focus.Field = nil
end

local function TickFocus()
    if not Focus.Field then return end
    local result = ProcessText(Focus.Field, Focus.Field.Allowed, Focus.Field.OnCommit)
    if result == "done" then ClearFocus() end
end

local State = {

    X = 100, Y = 100,
    W = Layout.WindowW,
    H = Layout.WindowH,
    Visible = 0,
    Open = false,

    Drag        = nil,
    Resize      = nil,
    DragSpeed   = 20,

    Tabs        = {},
    ActiveIndex = 1,
    RailOpen    = 1,
    RailPinned  = true,

    Scroll      = {},

    Popup       = nil,

    Alive       = true,
    Frame       = 0,
    GameInput   = true,
    InputSent   = true,
    DestroyCallbacks = {},
    Delta       = 1 / 60,
    LastTick    = os.clock(),

    Entrance = { Time = 0, Duration = 0.72, Active = false },

    NoAnim      = false,
    Settings = {
        KeybindOverlay = true,
        PerformanceOverlay = true,
        BackgroundEffects = true,
        BorderComet = true,
        WindowOpacity = 82,
        CompactOverlay = false,
        ToggleStyle = "Switch",
        ConfigName = "default",
    },

    OverlayRevealTime = 0,
    OverlayNextRevealAt = 1.0,

    WindowTitle    = "Window",
    WindowSubtitle = "",
    GameName       = "",
    ShowGameName   = true,
    ShowLogo       = false,
    Logo           = nil,
    LogoSource     = nil,
    LogoSize       = 28,
    ProfileAvatar  = nil,
    ProfileAvatarSource = nil,
    ProfileAvatarLoading = false,
    ProfileDisplayName = nil,
    ProfileUsername = nil,
    ProfileNamesVisible = true,
    ProfileAvatarRect = nil,
    BackgroundImage = nil,
    BackgroundImageSource = nil,
    OpenDropdownWheelRect = nil,
    ActiveDropdown = nil,
    Background     = "none",
    BackgroundOptions = {},

    MenuKey     = "p",

    Theme       = Themes[1],
    ThemeIndex  = 1,
    ThemeTween  = {},

    Notifications = {},
    NotificationPosition = "top_left",
}

do
    local function GameCaptures()

        if State.Entrance.Active then return true end
        if not State.Open then return false end
        if State.GameInput == "always" then return false end
        if State.GameInput ~= true then return true end
        if State.Popup then return true end

        return MouseIn(State.X, State.Y, State.W, State.H)
    end

    function State.ApplyInputState(force)
        if type(setrobloxinput) ~= "function" then return end

        local ToGame = not GameCaptures()

        if not force and State.InputSent == ToGame then return end

        State.InputSent = ToGame

        setrobloxinput(ToGame)
    end
end

local function ApplyThemeOptions(themeOption)
    if type(themeOption) == "string" then
        for i, th in ipairs(Themes) do
            if string.lower(th.Name) == string.lower(themeOption) then
                State.Theme = th
                State.ThemeIndex = i
                return
            end
        end
        return
    end
    if type(themeOption) ~= "table" then return end
    local source = State.Theme or Themes[1]
    local merged = {}
    for k, v in pairs(source) do merged[k] = v end
    local aliases = {
        accent = "Accent", accenta = "AccentA", accentb = "AccentB",
        based = "Base", base = "Base", panel = "Panel", panelhi = "PanelHi",
        stroke = "Stroke", divider = "Divider", text = "Text", textdim = "TextDim",
        textmuted = "TextMuted", accentdim = "AccentDim", track = "Track",
        trackfill = "TrackFill", danger = "Danger", warning = "Warning", success = "Success",
    }
    for k, v in pairs(themeOption) do
        local key = aliases[string.lower(tostring(k))]
        if key and typeof(v) == "Color3" then merged[key] = v end
    end
    State.Theme = merged
    State.ThemeIndex = 0
end

local function Clamp(v, lo, hi)
    v = tonumber(v) or 0
    lo = tonumber(lo) or 0
    hi = tonumber(hi) or 0
    if v < lo then return lo end
    if v > hi then return hi end
    return v
end

local function PointInRect(px, py, x, y, w, h)
    px, py = tonumber(px) or 0, tonumber(py) or 0
    x, y = tonumber(x) or 0, tonumber(y) or 0
    w, h = tonumber(w) or 0, tonumber(h) or 0
    return (px >= x) and (px <= x + w)
       and (py >= y) and (py <= y + h)
end

local function Distance2(x1, y1, x2, y2)
    local dx, dy = x2 - x1, y2 - y1
    return dx * dx + dy * dy
end

local Geometry = { FooterH = 20 }

function Geometry.Recalculate()
    Geometry.X = State.X
    Geometry.Y = State.Y
    Geometry.W = State.W
    Geometry.H = State.H

    Geometry.TopY  = State.Y
    Geometry.TopH  = Layout.TopbarH

    Geometry.RailX = State.X
    Geometry.RailY = State.Y

    Geometry.FooterH = 0
    Geometry.RailH = State.H

    local wide = math.max(Layout.TabRailW, math.floor(State.W * 0.22))
    Geometry.RailW = wide

    Geometry.ContentX = Geometry.RailX + Geometry.RailW
    Geometry.ContentY = State.Y
    Geometry.ContentW = State.W - Geometry.RailW
    Geometry.ContentH = State.H

    Geometry.InnerX = Geometry.ContentX + Layout.ContentPadX
    Geometry.InnerY = Geometry.ContentY + Layout.ContentPadY
    Geometry.InnerW = Geometry.ContentW - Layout.ContentPadX * 2 - Layout.ScrollbarW
    Geometry.InnerH = Geometry.ContentH - Layout.ContentPadY * 2
end

local Tab = {}
Tab.__index = Tab

function Tab.new(parent, opts)
    opts = opts or {}
    local self = setmetatable({
        Parent   = parent,
        Name     = opts.Title or "Tab",
        Icon     = opts.Icon,
        Hidden   = opts.Hidden or false,
        IsSettings = opts.IsSettings or false,

        RowY     = 0,
        RowH     = Layout.TabRowH,

        Glow     = 0,
        Hover    = 0,

        Rows     = {},
        Scroll   = 0,
        ScrollTo = 0,
        MaxScroll = 0,

        Dirty    = true,
    }, Tab)
    State.Tabs[#State.Tabs + 1] = self

    parent.Tabs = parent.Tabs or {}
    parent.Tabs[#parent.Tabs + 1] = self

    return self
end

function Tab:AddRow(builder)
    self.Rows[#self.Rows + 1] = builder
    return builder
end

local Section = {}
Section.__index = Section

function Section.new(tab, title, description, opts)
    opts = opts or {}
    local self = setmetatable({
        Parent      = tab,
        Title       = title or "Section",
        Description = description or "",
        Collapsed   = opts.Collapsed and true or false,
        Column      = (function()
            local c = string.lower(tostring(opts.Column or opts.column or "auto"))
            return (c == "left" or c == "right") and c or "auto"
        end)(),
        Rows        = {},
        HeaderH     = Layout.SectionH,
        _layoutX    = 0,
        _layoutY    = 0,
        _layoutW    = 0,
        _layoutH    = 0,
    }, Section)
    tab.Rows = tab.Rows or {}
    tab.Rows[#tab.Rows + 1] = self
    return self
end

function Section:AddRow(builder)
    self.Rows[#self.Rows + 1] = builder
    return builder
end

local InlineRow = {}
InlineRow.__index = InlineRow

function InlineRow.new(parent, weights)
    weights = weights or {}
    local self = setmetatable({
        Parent  = parent,
        Cells   = {},
        Weights = weights,
        Gap     = math.max(0, tonumber(weights.Gap or weights.gap) or Layout.RowColumnGap),
        Height  = Layout.RowHeight,
    }, InlineRow)
    parent.Rows[#parent.Rows + 1] = self
    return self
end

local function IsInline(parent)
    return getmetatable(parent) == InlineRow
end

local ContentScrollbarDrag = {
    Active = false,
    OffsetY = 0,
    Tab = nil,
}

local function GetContentScrollbarGeometry(tab)
    if not tab or (tab.MaxScroll or 0) <= 0 then return nil end
    local trackW = math.max(6, Layout.ScrollbarW)
    local trackX = Geometry.ContentX + Geometry.ContentW - trackW - 3
    local inset = 24
    local trackY = Geometry.ContentY + inset
    local trackH = math.max(20, Geometry.ContentH - inset * 2)
    local viewFrac = Geometry.InnerH / math.max(1, Geometry.InnerH + tab.MaxScroll)
    local thumbH = math.max(24, trackH * viewFrac)
    local travel = math.max(1, trackH - thumbH)
    local scrollFrac = (tab.ScrollTo or 0) / math.max(1, tab.MaxScroll)
    local thumbY = trackY + travel * scrollFrac
    return trackX, trackY, trackW, trackH, thumbY, thumbH, travel
end

local function UpdateContentScrollbarInput(tab)
    if not tab then
        ContentScrollbarDrag.Active = false
        ContentScrollbarDrag.Tab = nil
        return
    end

    local trackX, trackY, trackW, trackH, thumbY, thumbH, travel =
        GetContentScrollbarGeometry(tab)
    if not trackX then
        ContentScrollbarDrag.Active = false
        ContentScrollbarDrag.Tab = nil
        return
    end

    if ContentScrollbarDrag.Active and ContentScrollbarDrag.Tab == tab then
        if Input.Down then
            local newThumbY = Clamp(Input.Y - ContentScrollbarDrag.OffsetY,
                                    trackY, trackY + travel)
            local frac = (newThumbY - trackY) / math.max(1, travel)
            tab.ScrollTo = Clamp(frac * tab.MaxScroll, 0, tab.MaxScroll)
            tab.Scroll = tab.ScrollTo
            Input.Click = false
        else
            ContentScrollbarDrag.Active = false
            ContentScrollbarDrag.Tab = nil
        end
        return
    end

    if Input.Click and MouseIn(trackX - 3, thumbY - 2, trackW + 6, thumbH + 4) then
        ContentScrollbarDrag.Active = true
        ContentScrollbarDrag.Tab = tab
        ContentScrollbarDrag.OffsetY = Input.Y - thumbY
        Input.Click = false
        return
    end

    if Input.Click and MouseIn(trackX - 3, trackY, trackW + 6, trackH) then
        local centered = Clamp(Input.Y - thumbH / 2, trackY, trackY + travel)
        local frac = (centered - trackY) / math.max(1, travel)
        tab.ScrollTo = Clamp(frac * tab.MaxScroll, 0, tab.MaxScroll)
        tab.Scroll = tab.ScrollTo
        ContentScrollbarDrag.Active = true
        ContentScrollbarDrag.Tab = tab
        ContentScrollbarDrag.OffsetY = thumbH / 2
        Input.Click = false
    end
end

local function TickScroll(tab, dt)
    tab.ScrollTo = Clamp(tab.ScrollTo, 0, tab.MaxScroll or 0)

    if State.NoAnim then
        tab.Scroll = tab.ScrollTo
    else
        tab.Scroll = Approach(tab.Scroll, tab.ScrollTo, 22, dt)
        if math.abs(tab.Scroll - tab.ScrollTo) < 0.4 then
            tab.Scroll = tab.ScrollTo
        end
    end
end

local function HandleWheel(tab)
    if not tab then return end
    if not MouseIn(Geometry.ContentX, Geometry.ContentY,
                   Geometry.ContentW, Geometry.ContentH) then return end

    local dropdown = State.ActiveDropdown
    local popup = dropdown and dropdown._popupGeom
    if dropdown and dropdown._open and popup
       and MouseIn(popup.X, popup.Y, popup.W, popup.H) then
        local wheel = Input.Wheel or 0
        if wheel ~= 0 then
            dropdown._listScrollTo = Clamp(
                (dropdown._listScrollTo or 0) - wheel * 2,
                0, popup.MaxScroll or 0
            )
            Input.Wheel = 0
        end
        return
    end

    local delta = Input.Wheel or 0
    local pgUp = Keys.PageUp and Keys.PageUp.Click
    local pgDn = Keys.PageDown and Keys.PageDown.Click

    if delta ~= 0 then
        tab.ScrollTo = tab.ScrollTo - delta * Layout.ScrollSpeed
        Input.Wheel = 0
    elseif pgUp then
        tab.ScrollTo = tab.ScrollTo - math.max(80, Geometry.ContentH * 0.65)
    elseif pgDn then
        tab.ScrollTo = tab.ScrollTo + math.max(80, Geometry.ContentH * 0.65)
    else
        return
    end

    tab.ScrollTo = Clamp(tab.ScrollTo, 0, tab.MaxScroll or 0)
end

local function DrawScrollbar(tab)
    local trackX, trackY, trackW, trackH, thumbY, thumbH =
        GetContentScrollbarGeometry(tab)
    if not trackX then return end

    Rect(trackX, trackY, trackW, trackH,
         State.Theme.Track, 20, trackW / 2, 0.38)

    local active = ContentScrollbarDrag.Active and ContentScrollbarDrag.Tab == tab
    Rect(trackX, thumbY, trackW, thumbH,
         State.Theme.Accent, 21, trackW / 2, active and 1 or 0.82)
end

local function GetVisibleTabCount()
    local count = 0
    for _, tab in ipairs(State.Tabs) do
        if not tab.Hidden then
            count = count + 1
        end
    end
    return count
end

local WrapHeaderLines
local function GetRequiredWindowHeight()

    local count = 0
    for _, tab in ipairs(State.Tabs) do
        if not tab.Hidden and not tab.IsSettings then count = count + 1 end
    end
    local railW = math.max(Layout.TabRailW, math.floor(State.W * 0.22))
    local brandWidth = math.max(40, railW - 20) - 20
    local titleLines = #WrapHeaderLines(State.WindowTitle or "Nexa", brandWidth, 18, Fonts.SystemBold)
    local subtitleLines = State.WindowSubtitle ~= "" and #WrapHeaderLines(State.WindowSubtitle, brandWidth, 12, Fonts.System) or 0
    local brandH = math.max(57, 18 + titleLines * 24 + (subtitleLines > 0 and (subtitleLines * 16 + 8) or 0) + 8)
    local tabH = Layout.TabRowH * 0.96
    local tabsHeight = count > 0 and (count * tabH + (count - 1) * Layout.TabGap) or 0

    local needed = 8 + brandH + 7 + tabsHeight + 12 + Layout.TabRowH + 31

    local viewportH = Camera and Camera.ViewportSize and Camera.ViewportSize.Y or 900
    return math.min(math.max(Layout.WindowMinH, math.ceil(needed)), math.max(340, viewportH - 36))
end

local function EnsureWindowFitsTabs()
    local required = GetRequiredWindowHeight()
    if State.H < required then
        local oldH = State.H
        State.H = required

        State.Y = State.Y - math.floor((required - oldH) / 2)
    end
    local vp = Camera.ViewportSize
    State.X = math.max(0, math.min(State.X, math.max(0, vp.X - 80)))
    State.Y = math.max(0, math.min(State.Y, math.max(0, vp.Y - 80)))
end

local function BeginResize()
    State.Resize = {
        StartX = State.X,
        StartY = State.Y,
        StartW = State.W,
        StartH = State.H,
        GrabX  = Input.X,
        GrabY  = Input.Y,
    }
end

local function TickResize()
    local r = State.Resize
    if not r then return end

    if not Input.Down then
        State.Resize = nil
        return
    end

    State.W = Clamp(r.StartW + (Input.X - r.GrabX),
                    Layout.WindowMinW, 2400)
    local minWindowH = GetRequiredWindowHeight()
    State.H = Clamp(r.StartH + (Input.Y - r.GrabY),
                    minWindowH, 1600)

    local vp = Camera.ViewportSize
    State.X = math.min(math.max(State.X, -State.W + 120), vp.X - 120)
    State.Y = math.min(math.max(State.Y, 0), vp.Y - 40)
end

local function DrawResizeHandle()
    local hx = State.X + State.W - Layout.ResizeGrab
    local hy = State.Y + State.H - Layout.ResizeGrab

    local hovered = MouseIn(hx, hy, Layout.ResizeGrab, Layout.ResizeGrab)
    if not hovered and not State.Resize then return end

    local a = State.Resize and 1 or (hovered and 1 or 0.82)
    for i = 0, 3 do
        local off = i * 3.5
        Bar(
            hx + Layout.ResizeGrab - 2 - off,
            hy + Layout.ResizeGrab - 2,
            hx + Layout.ResizeGrab - 2,
            hy + Layout.ResizeGrab - 2 - off,
            2, State.Theme.Accent, 200, a - i * 0.12
        )
    end

    if hovered and Input.Click then
        BeginResize()
        Input.Click = false
    end
end

local function BeginDrag()
    State.Drag = {
        GrabX = Input.X - State.X,
        GrabY = Input.Y - State.Y,
        WantX = State.X,
        WantY = State.Y,
    }
end

local function TickDrag(dt)
    local d = State.Drag
    if not d then return end

    if Input.Down then
        d.WantX = Input.X - d.GrabX
        d.WantY = Input.Y - d.GrabY
    end

    State.X, State.Y = d.WantX, d.WantY

    if not Input.Down
       and math.abs(State.X - d.WantX) < 0.5
       and math.abs(State.Y - d.WantY) < 0.5 then
        State.X, State.Y = d.WantX, d.WantY
        State.Drag = nil
    end

    local vp = Camera.ViewportSize
    State.X = math.min(math.max(State.X, -State.W + 120), vp.X - 120)
    State.Y = math.min(math.max(State.Y, 0), vp.Y - 40)
end

local function GlassBorderPoint(distance, x, y, w, h, cut)
    local points = {{x+cut,y},{x+w,y},{x+w,y+h-cut},{x+w-cut,y+h},{x,y+h},{x,y+cut},{x+cut,y}}
    local total = 0
    for i = 1, #points-1 do
        local a,b = points[i],points[i+1]
        total = total + math.sqrt((b[1]-a[1])^2+(b[2]-a[2])^2)
    end
    local d = distance % total
    for i = 1, #points-1 do
        local a,b = points[i],points[i+1]
        local len = math.sqrt((b[1]-a[1])^2+(b[2]-a[2])^2)
        if d <= len then
            local t = len > 0 and d/len or 0
            return a[1]+(b[1]-a[1])*t,a[2]+(b[2]-a[2])*t
        end
        d = d-len
    end
    return x+cut,y
end

local function CutPanel(x,y,w,h,cut,color,z,alpha)
    cut = math.min(cut, w*0.25, h*0.25)
    Rect(x+cut,y,w-cut,cut,color,z,0,alpha)
    Rect(x,y+cut,w,h-2*cut,color,z,0,alpha)
    Rect(x,y+h-cut,w-cut,cut,color,z,0,alpha)
    Triangle(x,y+cut,x+cut,y,x+cut,y+cut,color,z,alpha)
    Triangle(x+w-cut,y+h-cut,x+w,y+h-cut,x+w-cut,y+h,color,z,alpha)
end

local function CutOutline(x,y,w,h,cut,color,z,alpha,thickness)
    local pts={{x+cut,y},{x+w,y},{x+w,y+h-cut},{x+w-cut,y+h},{x,y+h},{x,y+cut},{x+cut,y}}
    for i=1,#pts-1 do
        Line(pts[i][1],pts[i][2],pts[i+1][1],pts[i+1][2],color,z,thickness or 1,alpha)
    end
end

local function DrawGlassBorder(th)
    local x, y = State.X, State.Y
    local w, h = State.W, State.H
    local radius = math.min(19, math.max(2, math.min(w, h) / 2 - 1))

    CutOutline(x, y, w, h, radius, th.Accent, 20, 0.88, 1.5)

    if State.NoAnim then
        return
    end

    local straightW = math.max(0, w - radius * 2)
    local straightH = math.max(0, h - radius * 2)
    local perimeter = 2 * (w + h - 2 * radius) + 2 * math.sqrt(2) * radius
    local distance = (os.clock() * 96) % perimeter

    if State.Settings and State.Settings.BorderComet == false then
        return
    end

    local function DrawComet(headDistance, direction, accent, zBase)
        local trailCount = 12
        local trailLength = 48

        for i = trailCount, 1, -1 do
            local t = i / trailCount
            local trailDistance = headDistance - direction * trailLength * t
            local tx, ty = GlassBorderPoint(trailDistance, x, y, w, h, radius)
            local strength = 1 - t
            local trailAlpha = 0.07 + strength * 0.54
            local trailSize = 1.15 + strength * 1.75
            Circle(tx, ty, trailSize, accent,
                   zBase + i, true, 1, 14, trailAlpha)
        end

        local hx, hy = GlassBorderPoint(headDistance, x, y, w, h, radius)
        Circle(hx, hy, 6.0, accent, zBase + 20, true, 1, 20, 0.13)
        Circle(hx, hy, 3.5, accent, zBase + 21, true, 1, 18, 1)
        Circle(hx, hy, 1.6, Color3.new(1, 1, 1),
               zBase + 22, true, 1, 14, 0.88)
    end

    DrawComet(distance, 1, th.AccentA, 21)
    DrawComet((-distance) % perimeter, -1, th.AccentB or th.AccentA, 55)
end

local function DrawBackgroundEffect()
    if State.Settings and State.Settings.BackgroundEffects == false then return end
    local effect = State.Background
    local kind = type(effect) == "table" and effect.Type or effect
    if kind == "none" then return end

    local th = State.Theme
    local x, y, w, h = State.X, State.Y, State.W, State.H
    local inset = 8
    local left, right = x + inset, x + w - inset
    local top, bottom = y + 5, y + h - inset
    local areaW = math.max(1, right - left)
    local areaH = math.max(1, bottom - top)
    local now = os.clock()
    local intensity = type(effect) == "table" and tonumber(effect.Intensity) or nil
    intensity = Clamp(intensity or 1, 0, 1)

    local function Hash(n)
        local v = math.sin(n * 12.9898 + 78.233) * 43758.5453
        return v - math.floor(v)
    end
    local function Wrap01(v) return v - math.floor(v) end
    local function EdgeFade(u, v, margin)
        margin = margin or 0.075
        local fx = math.min(1, math.min(u, 1 - u) / margin)
        local fy = math.min(1, math.min(v, 1 - v) / margin)
        return Clamp(math.min(fx, fy), 0, 1)
    end
    local function Point(u, v)
        return left + Clamp(u, 0, 1) * areaW,
               top + Clamp(v, 0, 1) * areaH
    end

    if kind == "dots" then

        local cols = Clamp(math.floor(areaW / 38), 8, 18)
        local rows = Clamp(math.floor(areaH / 38), 6, 13)
        for row = 1, rows do
            for col = 1, cols do
                local id = row * 31 + col * 17
                local baseU = (col - 0.5) / cols
                local baseV = (row - 0.5) / rows
                local u = baseU + math.sin(now * 0.22 + id * 0.61) * (0.08 / cols)
                local v = baseV + math.cos(now * 0.18 + id * 0.47) * (0.08 / rows)
                local px, py = Point(u, v)
                local pulse = 0.5 + 0.5 * math.sin(now * 0.75 + id * 0.38)
                local colr = ((row + col) % 4 == 0) and th.AccentB or th.AccentA
                Circle(px, py, 0.75 + pulse * 0.45, colr, 11, true, 1, 8,
                       (0.13 + pulse * 0.16) * intensity)
            end
        end

    elseif kind == "particles" then

        local count = math.floor(type(effect) == "table" and tonumber(effect.Count) or 26)
        count = Clamp(count, 10, 48)
        for i = 1, count do
            local u0 = Hash(i * 2.17)
            local v0 = Hash(i * 7.31)
            local speed = 0.018 + Hash(i * 4.91) * 0.028
            local v = Wrap01(v0 - now * speed)
            local u = u0 + math.sin(now * (0.20 + Hash(i * 3.2) * 0.22) + i) * 0.018
            u = Clamp(u, 0.015, 0.985)
            local px, py = Point(u, v)
            local pulse = 0.5 + 0.5 * math.sin(now * 0.9 + i * 0.73)
            local radius = 0.9 + Hash(i * 9.1) * 1.15 + pulse * 0.25
            local colr = (i % 3 == 0) and th.AccentB or th.AccentA
            local fade = EdgeFade(u, v, 0.09)
            Circle(px, py, radius, colr, 11, true, 1, 10,
                   (0.16 + pulse * 0.22) * fade * intensity)
            if i % 6 == 0 then
                Circle(px, py, radius + 3.0, colr, 10, true, 1, 12,
                       0.035 * fade * intensity)
            end
        end

    elseif kind == "aurora" then

        local bands = type(effect) == "table" and math.floor(tonumber(effect.Bands) or 4) or 4
        bands = Clamp(bands, 3, 6)
        local points = 14
        for band = 1, bands do
            local colr = (band % 2 == 0) and th.AccentB or th.AccentA
            local baseV = 0.12 + (band - 1) * (0.62 / math.max(1, bands - 1))
            for point = 0, points do
                local u = point / points
                local phase = now * (0.18 + band * 0.012) + u * 5.2 + band * 1.31
                local v = baseV + math.sin(phase) * (0.028 + band * 0.004)
                                + math.sin(phase * 0.47 + 1.4) * 0.018
                local px, py = Point(u, v)
                local radius = math.max(20, areaW / points * 0.92)
                local fade = EdgeFade(u, Clamp(v,0,1), 0.08)
                Circle(px, py, radius, colr, 10 + band, true, 1, 24,
                       (0.018 + band * 0.0035) * fade * intensity)
            end
        end

    elseif kind == "snow" then
        local count = math.floor(type(effect) == "table" and tonumber(effect.Count) or 38)
        count = Clamp(count, 14, 64)
        for i = 1, count do
            local u0 = Hash(i * 2.71)
            local v0 = Hash(i * 8.13)
            local depth = 0.35 + Hash(i * 5.41) * 0.65
            local speed = 0.018 + depth * 0.030
            local v = Wrap01(v0 + now * speed)
            local u = u0 + math.sin(now * (0.24 + depth * 0.16) + i * 1.7) * (0.008 + depth * 0.012)
            u = Clamp(u, 0.012, 0.988)
            local px, py = Point(u, v)
            local radius = 0.75 + depth * 1.25
            local fade = EdgeFade(u, v, 0.08)
            local alpha = (0.22 + depth * 0.34) * fade * intensity
            Circle(px, py, radius + 2.2, th.Text, 10, true, 1, 10, 0.025 * alpha)
            Circle(px, py, radius, th.Text, 11, true, 1, 10, alpha)
        end

    elseif kind == "rainfall" then
        local count = math.floor(type(effect) == "table" and tonumber(effect.Count) or 34)
        count = Clamp(count, 14, 58)
        for i = 1, count do
            local u = 0.015 + Hash(i * 3.77) * 0.97
            local v0 = Hash(i * 9.21)
            local depth = 0.45 + Hash(i * 4.43) * 0.55
            local speed = 0.16 + depth * 0.18
            local v = Wrap01(v0 + now * speed)
            local px, py = Point(u, v)
            local length = 5 + depth * 7
            local slant = 1.8 + depth * 2.0
            local fade = EdgeFade(u, v, 0.07)
            local colr = (i % 6 == 0) and th.AccentA or th.TextDim

            local tailY = math.min(bottom, py + length)
            local actual = math.max(0, tailY - py)
            if actual > 0.5 then
                Line(px, py, px - slant * (actual / length), tailY,
                     colr, 11, 1, (0.13 + depth * 0.24) * fade * intensity)
            end
        end
    end
end

local function DrawFrame(hideBackgroundImage)
    local th = State.Theme

    CutPanel(State.X, State.Y, State.W, State.H, 19,
             rgb(0, 0, 0), 10, GlassSurfaceAlpha * FrameAlpha)

    if State.BackgroundImage and not hideBackgroundImage then

        local bx, by, bw, bh = State.X + 2, State.Y + 2, State.W - 4, State.H - 4
        DrawPicture(State.BackgroundImage, bx, by, bw, bh,
                    Layer(11), GlassSurfaceAlpha * FrameAlpha, 0)
        local cut = 19
        local mask = rgb(0, 0, 0)
        Triangle(State.X, State.Y, State.X + cut, State.Y,
                 State.X, State.Y + cut, mask, 13, FrameAlpha)
        Triangle(State.X + State.W, State.Y + State.H,
                 State.X + State.W - cut, State.Y + State.H,
                 State.X + State.W, State.Y + State.H - cut, mask, 13, FrameAlpha)
    end

    Rect(State.X + Layout.Corner, State.Y + 1,
         math.max(1, State.W - Layout.Corner * 2), 1,
         Color3.new(1, 1, 1), 12, 0, 0.12)

    DrawBackgroundEffect()

    local sidebarSectionPad = 10
    local sidebarSectionRight = Geometry.RailX + sidebarSectionPad
        + math.max(40, Geometry.RailW - sidebarSectionPad - sidebarSectionPad)
    local separatorX = Geometry.RailX + Geometry.RailW - 2

    Line(separatorX, Geometry.RailY + 1,
         separatorX, State.Y + State.H - 2,
         th.Accent, 14, 1, 0.50)

    DrawGlassBorder(th)
end

WrapHeaderLines = function(value, room, size, font)
    local mkey = tostring(value) .. "\0" .. tostring(room) .. "\0" .. tostring(size) .. "\0" .. tostring(font)
    local hit = PoolMade.Lib.Wrap[mkey]
    if hit then return hit end
    local lines, line = {}, ""
    local maxChars = math.max(1, math.floor(room / (size * (FontMetrics[font] or 0.5))))
    local function pushWord(word)
        while #word > maxChars do
            if line ~= "" then table.insert(lines, line); line = "" end
            table.insert(lines, string.sub(word, 1, maxChars))
            word = string.sub(word, maxChars + 1)
        end
        if word == "" then return end
        local joined = line == "" and word or (line .. " " .. word)
        if #joined > maxChars then table.insert(lines, line); line = word else line = joined end
    end
    for segment in (tostring(value or "") .. "\n"):gmatch("(.-)\n") do
        for word in segment:gmatch("%S+") do pushWord(word) end
        table.insert(lines, line); line = ""
    end
    if PoolMade.Lib.WrapN > 256 then PoolMade.Lib.Wrap, PoolMade.Lib.WrapN = {}, 0 end
    PoolMade.Lib.Wrap[mkey] = lines
    PoolMade.Lib.WrapN = PoolMade.Lib.WrapN + 1
    return lines
end

local function HeaderText(value, x, y, room, size, font, color, z, alpha, spacing)
    local lines = WrapHeaderLines(value, room, size, font)
    local step = size + (spacing or 4)
    for i, line in ipairs(lines) do
        if line ~= "" then Text(line, math.floor(x + 0.5), math.floor(y + (i - 1) * step + 0.5), color, size, font, z, alpha) end
    end
    return #lines * step
end

local function ContentHeaderHeight(tab)
    local width = Geometry.ContentW - Layout.ContentPadX * 2
    local titleLines = #WrapHeaderLines(tab.Name, width, 21, Fonts.SystemBold)
    local subtitleLines = (tab.Subtitle and tab.Subtitle ~= "") and #WrapHeaderLines(tab.Subtitle, width, 14, Fonts.System) or 0
    return math.max(60, 21 + titleLines * 25 + (subtitleLines > 0 and (subtitleLines * 18 + 10) or 0))
end

local function StartupRevealCount(total)
    return total
end

local TitleButtons = {
    Close  = { Size = 22, X = 0, Y = 0 },
    Menu   = { Size = 22, X = 0, Y = 0 },
}

local function TickRailOpen(dt)
    State.RailOpen = 1
    State.RailPinned = true
end

local function DrawTabRail()
    local th = State.Theme
    local openAmt = 1

    local railX = Geometry.RailX or State.X
    local railY = Geometry.RailY or State.Y
    local railW = Geometry.RailW or Layout.TabRailNarrow
    local railH = Geometry.RailH or State.H

    local sectionPadX = 10
    local sectionX = railX + sectionPadX
    local sectionY = railY + 8
    local sectionW = math.max(40, railW - sectionPadX * 2)
    local sectionH = math.max(44, railH - 16)

    local sx, sy, sw, sh = railX + 2, railY + 2, railW - 4, railH - 4
    local bg = rgb(17, 17, 20)
    local cut = 17
    Rect(sx + cut, sy, sw - cut, sh, bg, 36, 0, GlassSurfaceAlpha * FrameAlpha)
    Rect(sx, sy + cut, cut, sh - cut, bg, 36, 0, GlassSurfaceAlpha * FrameAlpha)
    Triangle(sx + cut, sy, sx + cut, sy + cut, sx, sy + cut, bg, 36, GlassSurfaceAlpha * FrameAlpha)
    Line(railX + railW - 2, railY + 12, railX + railW - 2, railY + railH - 12,
         th.Stroke, 37, 1, 0.45 * FrameAlpha)

    local brandWidth = sectionW - 20
    local logoSize = math.max(24, math.min(34, State.LogoSize or 28))
    local logoX = math.floor(sectionX + sectionW - 11 - logoSize + 0.5)
    local logoY = math.floor(sectionY + 12 + 0.5)
    local titleX = sectionX + 11
    local hasLogo = State.ShowLogo and State.Logo and State.Logo.Image
    local titleWidth = hasLogo and math.max(32, logoX - titleX - 6) or brandWidth
    local titleLines = #WrapHeaderLines(State.WindowTitle or "Nexa", titleWidth, 18, Fonts.SystemBold)
    local subtitleLines = State.WindowSubtitle ~= "" and #WrapHeaderLines(State.WindowSubtitle, brandWidth, 12, Fonts.System) or 0
    local brandH = math.max(57, 18 + titleLines * 24 + (subtitleLines > 0 and (subtitleLines * 16 + 8) or 0) + 8)
    if Input.Click and MouseIn(railX + 20, railY + 5, railW - 30, brandH + 8) and not State.Drag then
        BeginDrag()
        Input.Click = false
    end
    HeaderText(State.WindowTitle or "Nexa", titleX, sectionY + 13,
               titleWidth, 18, Fonts.SystemBold, th.Text, 42, 1, 4)
    if subtitleLines > 0 then
        HeaderText(State.WindowSubtitle, titleX, sectionY + 18 + titleLines * 24,
                   brandWidth, 12, Fonts.System, th.TextDim, 42, 1, 4)
    end
    if hasLogo then
        local logoCut = math.max(5, math.floor(logoSize * 0.23))
        local logoBackground = rgb(18, 18, 22)
        CutPanel(logoX, logoY, logoSize, logoSize, logoCut, logoBackground, 43, 1)
        DrawPicture(State.Logo, logoX, logoY, logoSize, logoSize, Layer(44), FrameAlpha, 0)
        Triangle(logoX, logoY, logoX + logoCut, logoY,
                 logoX, logoY + logoCut, logoBackground, 45, 1)
        Triangle(logoX + logoSize, logoY + logoSize,
                 logoX + logoSize - logoCut, logoY + logoSize,
                 logoX + logoSize, logoY + logoSize - logoCut, logoBackground, 45, 1)
        CutOutline(logoX, logoY, logoSize, logoSize, logoCut, th.Accent, 46, 0.9, 1.5)
    end
    Line(sectionX + 9, sectionY + brandH,
         sectionX + sectionW - 9, sectionY + brandH,
         th.Accent, 42, 1.5, FrameAlpha)

    local rowY = sectionY + brandH + 7
    local padX = 8
    local rowH = Layout.TabRowH
    local tabGap = Layout.TabGap
    local iconSize = Layout.TabIcon
    local visibleTabs = StartupRevealCount(#State.Tabs)
    local settingsIndex = nil
    for i, tab in ipairs(State.Tabs) do
        if tab.IsSettings then settingsIndex = i break end
    end

    for i, tab in ipairs(State.Tabs) do
        if i > visibleTabs then break end
        if not tab.Hidden then

            local collapsedTabW = math.min(50, math.max(44, sectionW - 18))
            local expandedTabPadX = 6
            local sectionTabW = math.max(1, sectionW - expandedTabPadX * 2)

            local collapsedScale = 1.00 - (0.04 * openAmt)
            local tabRowH = rowH * collapsedScale
            local narrowTabW = collapsedTabW
            local wideTabW = sectionTabW
            local w = narrowTabW + (wideTabW - narrowTabW) * openAmt

            local x = sectionX + (sectionW - w) * 0.5
            if tab.IsSettings then
                w = rowH - 2
                x = sectionX + sectionW - w - 6
            end
            local y = tab.IsSettings and (sectionY + sectionH - rowH - 11) or rowY
            local yOffset = (rowH - tabRowH) * 0.5
            y = y + yOffset

            local railClipTop = sectionY + 1
            local railClipBottom = sectionY + sectionH - 1
            local insideAnimatedRail = (y >= railClipTop and y + tabRowH <= railClipBottom)

            local hover = MouseIn(x, y, w, tabRowH)
            local active = (State.ActiveIndex == i)

            tab.Glow = Approach(tab.Glow or 0, active and 1 or 0, 16, State.Delta)
            tab.Hover = Approach(tab.Hover or 0, hover and 1 or 0, 18, State.Delta)

            if math.abs(tab.Glow - (active and 1 or 0)) < 0.01 then
                tab.Glow = active and 1 or 0
            end
            if math.abs(tab.Hover - (hover and 1 or 0)) < 0.01 then
                tab.Hover = hover and 1 or 0
            end

            local stateMix = tab.Hover * 0.55 + tab.Glow * 0.45
            local bgColor = mix(rgb(22, 22, 27), rgb(33, 30, 42), stateMix)
            local tabCut = 9
            CutPanel(x, y, w, tabRowH, tabCut, bgColor, 40, FrameAlpha)

            if tab.Glow > 0.01 then
                local activeColor = mix(bgColor, th.Accent, tab.Glow * 0.13)
                CutPanel(x, y, w, tabRowH, tabCut, activeColor, 41, FrameAlpha)
            end

            local borderAlpha = active and 0.65 or (hover and 0.30 or 0.16)
            CutOutline(x, y, w, tabRowH, tabCut, th.Accent, 42, borderAlpha * FrameAlpha, 1)
            local collapsedIconSize = math.min(iconSize, tabRowH - 10)
            local centeredIconX = x + math.max(0, (narrowTabW - collapsedIconSize) / 2)
            local expandedIconX = x + 12
            local drawIconSize = iconSize + (collapsedIconSize - iconSize) * (1 - openAmt)
            local iconX = tab.IsSettings and (x + (w - drawIconSize) / 2) or (centeredIconX + (expandedIconX - centeredIconX) * openAmt)
            local iconY = y + (tabRowH - drawIconSize) / 2
            local iconAlpha = 0.55 + 0.45 * math.max(tab.Glow, tab.Hover)
            local iconColor = tab.Glow > 0.5 and th.Accent or th.TextDim

            if not DrawIconByName(tab.Icon, iconX, iconY, drawIconSize,
                                  iconColor, 44, iconAlpha * FrameAlpha) then

                Rect(iconX + 3, iconY + 3, math.max(1, drawIconSize - 6), math.max(1, drawIconSize - 6),
                     iconColor, 44, 2, iconAlpha)
            end

            if openAmt > 0.02 and not tab.IsSettings then
                local labelX = x + 43
                local labelRoom = w - (labelX - x) - 8
                local labelY = TextMidY(y, tabRowH, Layout.TextSize + 2)
                local labelColor = th.Text
                local labelAlpha = openAmt * (0.7 + 0.3 * math.max(tab.Glow, tab.Hover))
                if tab.Glow > 0.5 then
                    labelColor = th.Text
                    labelAlpha = openAmt
                end
                Text(tab.Name, math.floor(labelX + 0.5), math.floor(labelY + 0.5),
                     labelColor, Layout.TextSize + 1, Fonts.SystemBold,
                     45, labelAlpha, labelRoom)
            end

            if tab.IsSettings then
                local footerSeparatorY = y - 12
                Line(sectionX + 9, footerSeparatorY, sectionX + sectionW - 9, footerSeparatorY,
                     th.Accent, 42, 1.5, FrameAlpha)
                local profileX = sectionX + 7
                local avatarSize = tabRowH - 2
                local profileY = y + (tabRowH - avatarSize) / 2
                local cx, cy = profileX + avatarSize / 2, profileY + avatarSize / 2
                local avatarHover = MouseInCircle(cx, cy, avatarSize / 2 + 2)
                if State.ProfileAvatar and State.ProfileAvatar.Image then
                    DrawPicture(State.ProfileAvatar, profileX, profileY, avatarSize, avatarSize, Layer(44), FrameAlpha, avatarSize / 2)
                else
                    Circle(cx, cy, avatarSize / 2, rgb(29, 26, 36), 44, true, 1, 32, FrameAlpha)
                    local initial = string.upper(string.sub(State.ProfileUsername or "P", 1, 1))
                    local initialSize = 19
                    Text(initial, cx - TextWidth(initial, initialSize, Fonts.SystemBold) / 2,
                         cy - initialSize / 2 - 2, rgb(255, 255, 255), initialSize, Fonts.SystemBold, 45, FrameAlpha)
                end
                Circle(cx, cy, avatarSize / 2 + 1, th.Accent,
                       46, false, avatarHover and 2.2 or 1.8, 40, FrameAlpha)
                if State.ProfileNamesVisible ~= false then
                    local nameX = profileX + avatarSize + 9
                    local nameWidth = math.max(0, x - nameX - 6)
                    if nameWidth > 12 then
                        Text(State.ProfileDisplayName or tostring(LocalPlayer.DisplayName), nameX, y + 2,
                             rgb(255, 255, 255), 14, Fonts.SystemBold, 45, FrameAlpha, nameWidth)
                        Text("@" .. (State.ProfileUsername or tostring(LocalPlayer.Name)), nameX, y + 21,
                             rgb(255, 255, 255), 12, Fonts.System, 45, FrameAlpha, nameWidth)
                    end
                end
                if avatarHover and Input.Click then
                    State.ProfileNamesVisible = not (State.ProfileNamesVisible ~= false)
                    Input.Click = false
                end
            end

            if hover and Input.Click then
                if State.ActiveIndex ~= i then
                    State.ActiveIndex = i
                end
                Input.Click = false
            end

            if not tab.IsSettings then
                rowY = rowY + tabRowH + tabGap
            end
        end
    end

end

local function IsVisible(x, y, w, h)
    return y + h >= Geometry.ContentY
       and y <= Geometry.ContentY + Geometry.ContentH
end

local Controls = {}

local Base = {}
Base.__index = Base

function Base.New(kind, parent, opts)
    opts = opts or {}
    local self = setmetatable({
        Kind        = kind,
        Parent      = parent,
        Title       = opts.Title or "",
        Description = opts.Description or "",
        Tooltip     = opts.Tooltip or "",
        Hidden      = false,
        Enabled     = true,
        ConfigKey   = opts.ConfigKey or opts.configKey or opts.Flag or opts.flag,
        DeclaredDefault = opts.Default ~= nil and opts.Default or opts.default,
        _listeners  = {},
        _hover      = 0,
        _press      = 0,
        Accessories = {},
        InlineGap   = math.max(0, tonumber(opts.InlineGap or opts.inlineGap or opts.AccessoryGap or opts.accessoryGap) or 8),
        InlineOrder = opts.InlineOrder or opts.inlineOrder or opts.AccessoryOrder or opts.accessoryOrder,
        _isAccessory = opts._Accessory == true,
    }, Base)

    if parent and not self._isAccessory then
        parent.Rows = parent.Rows or {}
        if parent.AddRow then
            parent:AddRow(self)
        else
            parent.Rows[#parent.Rows + 1] = self
        end
    end

    return self
end

function Base:OnChanged(cb)
    self._listeners[#self._listeners + 1] = cb
    return self
end

function Base:_Fire(value)
    for i = 1, #self._listeners do
        pcall(self._listeners[i], value)
    end
end

function Base:SetVisible(v)
    self.Hidden = not v
    return self
end

function Base:SetEnabled(v)
    self.Enabled = v and true or false
    return self
end

function Base:SetTitle(v)
    self.Title = tostring(v or "")
    return self
end

function Base:SetDescription(v)
    self.Description = tostring(v or "")
    return self
end

function Base:SetTooltip(v)
    self.Tooltip = tostring(v or "")
    return self
end

function Base:Reset(silent)
    if self.Kind == "RangeSlider" then
        if self.DeclaredDefaultLow ~= nil and self.DeclaredDefaultHigh ~= nil then
            self:SetValue(self.DeclaredDefaultLow, self.DeclaredDefaultHigh, silent)
        end
    elseif self.DeclaredDefault ~= nil and self.SetValue then
        self:SetValue(self.DeclaredDefault, silent)
    end
    return self
end

function Base:Destroy()
    self.Hidden = true
    self.Enabled = false
    local parent = self.Parent
    if parent then
        for _, listName in ipairs({"Rows", "Cells", "Accessories"}) do
            local list = parent[listName]
            if type(list) == "table" then
                for i = #list, 1, -1 do
                    if list[i] == self then table.remove(list, i) end
                end
            end
        end
    end
    if self.Host and type(self.Host.Accessories) == "table" then
        for i = #self.Host.Accessories, 1, -1 do
            if self.Host.Accessories[i] == self then table.remove(self.Host.Accessories, i) end
        end
    end
    if Focus.Field == self._focus then ClearFocus() end
    self.Parent = nil
    self.Host = nil
    self._listeners = {}
    return self
end

function Base:GetValue() return nil end
function Base:SetValue(v) end
function Base:Draw(x, y, w) end
function Base:Input(x, y, w) end

local function Register(name, constructor)
    Controls[name] = constructor
end

local function TickAnim(control, hovered, pressed, dt)
    if State.NoAnim then
        control._hover = hovered and 1 or 0
        control._press = pressed and 1 or 0
        return
    end
    control._hover = Approach(control._hover, hovered and 1 or 0, 18, dt)
    control._press = Approach(control._press, pressed and 1 or 0, 26, dt)
    if math.abs(control._hover - (hovered and 1 or 0)) < 0.01 then
        control._hover = hovered and 1 or 0
    end
    if math.abs(control._press - (pressed and 1 or 0)) < 0.01 then
        control._press = pressed and 1 or 0
    end
end

Register("Label", function(parent, opts)
    local self = Base.New("Label", parent, opts)
    self.Height = 22

    function self:Draw(x, y, w)
        local th = State.Theme
        local titleY = TextMidY(y, 18, Layout.TextSize)
        Text(self.Title, x, titleY,
             th.Text, Layout.TextSize, Fonts.System,
             50, self.Enabled and 0.92 or 0.4, w)

        if self.Description ~= "" then
            local descY = y + 16
            Text(self.Description, x, descY,
                 th.TextDim, Layout.SmallSize, Fonts.System,
                 51, self.Enabled and 0.7 or 0.3,
                 w)
            self.Height = 32
        else
            self.Height = 18
        end
    end

    function self:Input() return end

    return self
end)

Register("Divider", function(parent, opts)
    opts = opts or {}
    local self = Base.New("Divider", parent, opts)
    self.Height = 14

    function self:Draw(x, y, w)
        local th = State.Theme
        local cy = y + 7
        if self.Title and self.Title ~= "" then
            local textW = TextWidth(self.Title, Layout.TinySize, Fonts.SystemBold)
            local px = 6
            local gap = 8

            Line(x, cy, x + 6, cy, th.Divider, 50, 1, 0.5)

            Text(string.upper(self.Title),
                 x + gap, cy - 6,
                 th.TextMuted, Layout.TinySize, Fonts.SystemBold,
                 51, 0.7)

            Line(x + gap + textW + gap, cy,
                 x + w, cy,
                 th.Divider, 50, 1, 0.5)
        else
            Line(x, cy, x + w, cy, th.Divider, 50, 1, 0.5)
        end
    end

    function self:Input() end

    return self
end)

Register("Button", function(parent, opts)
    opts = opts or {}
    local self = Base.New("Button", parent, opts)
    self.ButtonText = opts.ButtonText or "Run"
    self.Callback   = opts.Callback
    self.Variant    = string.lower(tostring(opts.Variant or opts.variant or "default"))
    self.Expand     = opts.Expand == true or opts.expand == true or opts.Fill == true or opts.fill == true
    self.Height     = Layout.ButtonH + 6

    function self:Draw(x, y, w)
        local th = State.Theme
        local h = Layout.ButtonH

        local labelText = tostring(self.ButtonText)
        local measuredLabelW = TextWidth(labelText, Layout.TextSize, Fonts.SystemBold)
        local btnW = self.Expand and w or math.min(w, math.max(42, math.ceil(measuredLabelW + 24)))
        local btnX = self.Expand and x or (x + w - btnW)
        local btnY = y + 3

        local hover = MouseIn(btnX, btnY, btnW, h) and self.Enabled
        TickAnim(self, hover, hover and Input.Down, State.Delta)

        local glow = self._hover
        local accent = th.Accent
        local bgBase = th.PanelHi
        if self.Variant == "danger" then
            accent = Color3.fromRGB(245, 82, 96)
            bgBase = mix(th.PanelHi, accent, 0.16)
        elseif self.Variant == "primary" or self.Variant == "accent" then
            bgBase = mix(th.PanelHi, accent, 0.22)
        elseif self.Variant == "ghost" then
            bgBase = th.Panel
        end

        local bg = mix(bgBase, accent, glow * 0.5)
        local bgA = self.Variant == "ghost" and (0.38 + 0.22 * glow) or (0.7 + 0.25 * glow)

        Rect(btnX, btnY, btnW, h, bg, 52, 6, bgA)
        Stroke(btnX, btnY, btnW, h, accent, 53, 6, 0.35 + 0.45 * glow)

        local labelRoom = math.max(8, btnW - 14)
        local label = labelText
        if measuredLabelW > labelRoom then
            label = TrimText(labelText, labelRoom,
                             Layout.TextSize, Fonts.SystemBold)
        end
        local lc = mix(th.Text, accent, glow * 0.7)
        TextCenter(label, btnX + btnW * 0.5,
                   TextMidY(btnY, h, Layout.TextSize) + 6,
                   lc, Layout.TextSize, Fonts.SystemBold, 54,
                   self.Enabled and 1 or 0.5, labelRoom)

        if self.Title ~= "" then
            local titleY = TextMidY(y, Layout.ButtonH + 6, Layout.TextSize)
            Text(self.Title, x, titleY,
                 th.Text, Layout.TextSize, Fonts.System,
                 51, self.Enabled and 0.9 or 0.4,
                 btnX - x - 10)
        end
    end

    function self:Input(x, y, w)
        if not self.Enabled then return end
        local h = Layout.ButtonH
        local labelText = tostring(self.ButtonText)
        local measuredLabelW = TextWidth(labelText, Layout.TextSize, Fonts.SystemBold)
        local btnW = self.Expand and w or math.min(w, math.max(42, math.ceil(measuredLabelW + 24)))
        local btnX = self.Expand and x or (x + w - btnW)
        local btnY = y + 3

        if MouseIn(btnX, btnY, btnW, h) and Input.Click then
            Input.Click = false
            if self.Callback then
                task.spawn(self.Callback)
            end
        end
    end

    return self
end)

Register("Toggle", function(parent, opts)
    opts = opts or {}
    local self = Base.New("Toggle", parent, opts)
    self.Value   = opts.Default and true or false
    self.Callback = opts.Callback
    self.Height  = Layout.ToggleH

    self._knob = self.Value and 1 or 0

    function self:GetValue() return self.Value end

    function self:SetValue(v, silent)
        v = v and true or false
        if self.Value == v then return end
        self.Value = v
        if not silent then
            if self.Callback then pcall(self.Callback, v) end
            self:_Fire(v)
        end
    end

    function self:Draw(x, y, w)
        local th = State.Theme
        local checkbox = string.lower(tostring(State.Settings.ToggleStyle or "Switch")) == "checkbox"
        local trackW = checkbox and 18 or Layout.ToggleW
        local trackH = checkbox and 18 or Layout.ToggleH
        local knob   = Layout.ToggleKnob

        local trackX = x + w - trackW
        local trackY = y + (self.Height - trackH) / 2

        local hover = MouseIn(trackX, trackY, trackW, trackH) and self.Enabled
        TickAnim(self, hover, hover and Input.Down, State.Delta)

        local target = self.Value and 1 or 0
        self._knob = Approach(self._knob, target, 22, State.Delta)
        if math.abs(self._knob - target) < 0.01 then self._knob = target end

        if checkbox then
            local fill = mix(th.PanelHi, th.Accent, self._knob)
            Rect(trackX, trackY, trackW, trackH, fill, 52, 4, 0.82 + 0.12 * self._hover)
            Stroke(trackX, trackY, trackW, trackH,
                   self.Value and th.AccentA or th.Stroke, 53, 4,
                   self.Value and 0.92 or 0.62)

            local checkA = self._knob
            Bar(trackX + 4, trackY + 9, trackX + 7, trackY + 12,
                1.6, th.Text, 54, checkA)
            Bar(trackX + 7, trackY + 12, trackX + 14, trackY + 5,
                1.6, th.Text, 54, checkA)
        else
            local trackColor = mix(th.Track, th.Accent, self._knob)
            local trackAlpha = 0.75 + 0.25 * self._hover
            Rect(trackX, trackY, trackW, trackH, trackColor, 52,
                 trackH / 2, trackAlpha)
            Stroke(trackX, trackY, trackW, trackH, th.Stroke, 53,
                   trackH / 2, 0.5)

            local knobX = trackX + 2 + (trackW - knob - 4) * self._knob
            local knobY = trackY + (trackH - knob) / 2
            local knobColor = mix(th.TextDim, th.Text, self._knob)
            Circle(knobX + knob / 2, knobY + knob / 2, knob / 2,
                   knobColor, 54, true, 1, 18, 1)
        end

        if self.Title ~= "" then
            local titleY = TextMidY(y, self.Height, Layout.TextSize)
            Text(self.Title, x, titleY,
                 th.Text, Layout.TextSize, Fonts.System,
                 51, self.Enabled and 0.92 or 0.4,
                 trackX - x - 10)
        end

        if self.Description ~= "" then
            local descY = y + self.Height - 4
            Text(self.Description, x, descY,
                 th.TextDim, Layout.SmallSize, Fonts.System,
                 51, self.Enabled and 0.6 or 0.25,
                 trackX - x - 10)
            self.Height = math.max(self.Height, Layout.ToggleH + 12)
        end
    end

    function self:Input(x, y, w)
        if not self.Enabled then return end
        local checkbox = string.lower(tostring(State.Settings.ToggleStyle or "Switch")) == "checkbox"
        local trackW = checkbox and 18 or Layout.ToggleW
        local trackH = checkbox and 18 or Layout.ToggleH
        local trackX = x + w - trackW
        local trackY = y + (self.Height - trackH) / 2

        if MouseIn(trackX, trackY, trackW, trackH) and Input.Click then
            Input.Click = false
            self:SetValue(not self.Value)
        end
    end

    return self
end)

Register("Radio", function(parent, opts)
    opts = opts or {}
    local self = Base.New("Radio", parent, opts)
    self.Options = opts.Options or opts.options or {}
    self.Value = opts.Default or opts.default or self.Options[1]
    self.Callback = opts.Callback or opts.callback
    self.RowH = 24
    self.Height = math.max(28, (#self.Options * self.RowH) + (self.Title ~= "" and 24 or 4))

    function self:GetValue() return self.Value end

    function self:SetValue(v, silent)
        local valid = false
        for _, option in ipairs(self.Options) do
            if option == v then valid = true break end
        end
        if not valid or self.Value == v then return end
        self.Value = v
        if not silent then
            if self.Callback then pcall(self.Callback, v) end
            self:_Fire(v)
        end
    end

    function self:Draw(x, y, w)
        local th = State.Theme
        local top = y
        if self.Title ~= "" then
            Text(self.Title, x, y + 2, th.Text, Layout.TextSize,
                 Fonts.System, 51, self.Enabled and 0.92 or 0.4, w)
            top = y + 23
        end

        for i, option in ipairs(self.Options) do
            local cy = top + (i - 1) * self.RowH + self.RowH / 2
            local selected = self.Value == option
            local hover = MouseIn(x, top + (i - 1) * self.RowH, w, self.RowH) and self.Enabled
            local ring = selected and th.AccentA or th.Stroke
            Circle(x + 9, cy, 7, ring, 52, false, 1.5, 18, hover and 0.95 or 0.72)
            Circle(x + 9, cy, 3.5, th.AccentA, 53, true, 1, 18, selected and 1 or 0)
            Text(tostring(option), x + 24, cy - Layout.TextSize / 2,
                 selected and th.Text or th.TextDim, Layout.TextSize,
                 Fonts.System, 53, self.Enabled and 0.95 or 0.4, w - 24)
        end
    end

    function self:Input(x, y, w)
        if not self.Enabled then return end
        local top = y + (self.Title ~= "" and 23 or 0)
        for i, option in ipairs(self.Options) do
            local ry = top + (i - 1) * self.RowH
            if MouseIn(x, ry, w, self.RowH) and Input.Click then
                Input.Click = false
                self:SetValue(option)
                return
            end
        end
    end

    return self
end)

Register("Slider", function(parent, opts)
    opts = opts or {}
    local self = Base.New("Slider", parent, opts)
    self.Min     = opts.Min or 0
    self.Max     = opts.Max or 100
    self.Step    = opts.Step or 1
    self.Value   = opts.Default or self.Min
    self.Suffix  = opts.Suffix or ""
    self.Callback = opts.Callback
    self.Height  = 37

    self._dragging = false
    self._knobAnim = 0

    local function snap(v)
        if self.Step <= 0 then
            return Clamp(v, self.Min, self.Max)
        end
        local s = math.floor((v - self.Min) / self.Step + 0.5) * self.Step + self.Min
        return Clamp(s, self.Min, self.Max)
    end

    local function frac()
        if self.Max <= self.Min then return 0 end
        return (self.Value - self.Min) / (self.Max - self.Min)
    end

    function self:GetValue() return self.Value end

    function self:SetValue(v, silent)
        v = snap(v)
        if self.Value == v then return end
        self.Value = v
        if not silent then
            if self.Callback then pcall(self.Callback, v) end
            self:_Fire(v)
        end
    end

    function self:Draw(x, y, w)
        local th = State.Theme
        local trackH = Layout.SliderH
        local knobR  = Layout.SliderKnob

        local valueText = tostring(self.Value) .. self.Suffix
        local valueW = TextWidth(valueText, Layout.TextSize, Fonts.Monospace)
        local badgeW = valueW + 14
        local badgeH = 18
        local badgeX = x + w - badgeW
        local badgeY = y + 2

        if self.Title ~= "" then
            Text(self.Title, x, y + 1,
                 th.Text, Layout.TextSize, Fonts.System,
                 51, self.Enabled and 0.92 or 0.4,
                 w - badgeW - 12)
        end

        Rect(badgeX, badgeY, badgeW, badgeH,
             th.PanelHi, 52, 4, 0.85)
        Stroke(badgeX, badgeY, badgeW, badgeH,
               th.Stroke, 53, 4, 0.55)
        Text(valueText,
             badgeX + (badgeW - valueW) / 2,
             badgeY + (badgeH - Layout.TextSize) / 2,
             th.Accent, Layout.TextSize, Fonts.Monospace,
             54, 1)

        local trackY = y + 29
        local trackX = x
        local trackW = w

        Rect(trackX, trackY - trackH / 2, trackW, trackH,
             th.Track, 51, trackH / 2, 0.8)

        local f = frac()
        local fillW = trackW * f
        if fillW > 0.5 then
            Rect(trackX, trackY - trackH / 2, fillW, trackH,
                 th.Accent, 52, trackH / 2, 0.85)
        end

        local knobX = trackX + fillW
        local hover = MouseIn(x, trackY - 10, w, 20) and self.Enabled
        TickAnim(self, hover, self._dragging, State.Delta)
        self._knobAnim = Approach(self._knobAnim, (self._dragging or hover) and 1 or 0, 22, State.Delta)
        if math.abs(self._knobAnim - ((self._dragging or hover) and 1 or 0)) < 0.01 then
            self._knobAnim = (self._dragging or hover) and 1 or 0
        end

        local kR = knobR + self._knobAnim * 2
        Circle(knobX, trackY, kR + 3,
               th.Accent, 53, false, 1.4, 24, (0.3 + self._knobAnim * 0.5))
        Circle(knobX, trackY, kR,
               th.Text, 54, true, 1, 24, 1)
    end

    function self:Input(x, y, w)
        if not self.Enabled then return end
        local trackY = y + 29
        local hitY = trackY - 12
        local hitH = 24

        local clicked = MouseIn(x, hitY, w, hitH) and Input.Click
        local held = MouseIn(x, hitY, w, hitH) and Input.Down

        if clicked then
            self._dragging = true
        end
        if not Input.Down then
            self._dragging = false
        end

        if self._dragging and held then
            local t = Clamp((Input.X - x) / w, 0, 1)
            local v = self.Min + t * (self.Max - self.Min)
            self:SetValue(v)
        end
    end

    return self
end)

Register("Segmented", function(parent, opts)
    opts = opts or {}
    local self = Base.New("Segmented", parent, opts)
    self.Options = opts.Options or opts.options or {"One", "Two"}
    self.Value = opts.Default or opts.default or self.Options[1]
    self.Callback = opts.Callback or opts.callback
    self.Height = Layout.ButtonH + 8

    function self:GetValue() return self.Value end

    function self:SetValue(v, silent)
        local valid = false
        for _, option in ipairs(self.Options) do
            if option == v then valid = true break end
        end
        if not valid or self.Value == v then return end
        self.Value = v
        if not silent then
            if self.Callback then pcall(self.Callback, v) end
            self:_Fire(v)
        end
    end

    function self:Draw(x, y, w)
        local th = State.Theme
        local n = math.max(1, #self.Options)
        local gap = 2
        local totalW = math.min(w, math.max(150, n * 58))
        local startX = x + w - totalW
        local cellW = (totalW - (n - 1) * gap) / n
        local h = Layout.ButtonH

        if self.Title ~= "" then
            Text(self.Title, x, TextMidY(y + 3, h, Layout.TextSize),
                 th.Text, Layout.TextSize, Fonts.System, 51,
                 self.Enabled and 0.92 or 0.4,
                 math.max(1, startX - x - 10))
        end

        for i, option in ipairs(self.Options) do
            local bx = startX + (i - 1) * (cellW + gap)
            local selected = option == self.Value
            local hover = self.Enabled and MouseIn(bx, y + 3, cellW, h)
            local bg = selected and mix(th.PanelHi, th.Accent, 0.32) or th.PanelHi
            local alpha = selected and 0.92 or (hover and 0.82 or 0.62)
            Rect(bx, y + 3, cellW, h, bg, 52, 5, alpha)
            Stroke(bx, y + 3, cellW, h, selected and th.Accent or th.Stroke,
                   53, 5, selected and 0.72 or 0.42)

            local label = tostring(option)
            local maxW = math.max(1, cellW - 10)
            while #label > 1 and TextWidth(label, Layout.TextSize, Fonts.SystemBold) > maxW do
                label = string.sub(label, 1, #label - 1)
            end
            local lw = TextWidth(label, Layout.TextSize, Fonts.SystemBold)
            Text(label, bx + (cellW - lw) / 2, TextMidY(y + 3, h, Layout.TextSize),
                 selected and th.Accent or th.Text,
                 Layout.TextSize, Fonts.SystemBold, 54,
                 self.Enabled and 1 or 0.4, maxW)
        end
    end

    function self:Input(x, y, w)
        if not self.Enabled then return end
        local n = math.max(1, #self.Options)
        local gap = 2
        local totalW = math.min(w, math.max(150, n * 58))
        local startX = x + w - totalW
        local cellW = (totalW - (n - 1) * gap) / n
        local h = Layout.ButtonH

        if Input.Click then
            for i, option in ipairs(self.Options) do
                local bx = startX + (i - 1) * (cellW + gap)
                if MouseIn(bx, y + 3, cellW, h) then
                    Input.Click = false
                    self:SetValue(option)
                    return
                end
            end
        end
    end

    return self
end)

Register("Progress", function(parent, opts)
    opts = opts or {}
    local self = Base.New("Progress", parent, opts)
    self.Min = tonumber(opts.Min) or 0
    self.Max = tonumber(opts.Max) or 100
    self.Value = Clamp(tonumber(opts.Default or opts.Value) or self.Min, self.Min, self.Max)
    self.Suffix = tostring(opts.Suffix or "%")
    self.Height = 34

    function self:GetValue() return self.Value end
    function self:SetValue(v)
        self.Value = Clamp(tonumber(v) or self.Min, self.Min, self.Max)
    end

    function self:Draw(x, y, w)
        local th = State.Theme
        local valueText = tostring(math.floor(self.Value * 100 + 0.5) / 100) .. self.Suffix
        Text(self.Title, x, y, th.Text, Layout.TextSize, Fonts.System, 51,
             self.Enabled and 0.92 or 0.4, math.max(1, w - 70))
        local vw = TextWidth(valueText, Layout.SmallSize, Fonts.SystemBold)
        Text(valueText, x + w - vw, y + 1, th.Accent, Layout.SmallSize,
             Fonts.SystemBold, 52, self.Enabled and 0.95 or 0.4)

        local barY = y + 21
        local frac = (self.Value - self.Min) / math.max(0.0001, self.Max - self.Min)
        Rect(x, barY, w, 6, th.Track, 51, 3, 0.72)
        if frac > 0 then
            Rect(x, barY, math.max(2, w * frac), 6, th.Accent, 52, 3, 0.9)
        end
    end

    function self:Input() end
    return self
end)

Register("Status", function(parent, opts)
    opts = opts or {}
    local self = Base.New("Status", parent, opts)
    self.Value = tostring(opts.Default or opts.Value or "Ready")
    self.Tone = string.lower(tostring(opts.Tone or "accent"))
    self.Height = 28

    function self:GetValue() return self.Value end
    function self:SetValue(v, tone)
        self.Value = tostring(v or "")
        if tone ~= nil then self.Tone = string.lower(tostring(tone)) end
    end

    function self:Draw(x, y, w)
        local th = State.Theme
        local accent = th.Accent
        if self.Tone == "success" then
            accent = Color3.fromRGB(82, 220, 145)
        elseif self.Tone == "warning" then
            accent = Color3.fromRGB(245, 190, 82)
        elseif self.Tone == "danger" or self.Tone == "error" then
            accent = Color3.fromRGB(245, 82, 96)
        elseif self.Tone == "muted" then
            accent = th.TextDim
        end

        Text(self.Title, x, TextMidY(y, 24, Layout.TextSize),
             th.Text, Layout.TextSize, Fonts.System, 51,
             self.Enabled and 0.92 or 0.4, math.max(1, w - 100))

        local badgeW = math.max(54, TextWidth(self.Value, Layout.SmallSize, Fonts.SystemBold) + 18)
        local bx = x + w - badgeW
        Rect(bx, y + 2, badgeW, 22, mix(th.PanelHi, accent, 0.18), 52, 11, 0.86)
        Stroke(bx, y + 2, badgeW, 22, accent, 53, 11, 0.55)
        local tw = TextWidth(self.Value, Layout.SmallSize, Fonts.SystemBold)
        Text(self.Value, bx + (badgeW - tw) / 2, TextMidY(y + 2, 22, Layout.SmallSize),
             accent, Layout.SmallSize, Fonts.SystemBold, 54, 0.96)
    end

    function self:Input() end
    return self
end)

local WantTooltip

local function LayoutInline(row, x, y, w)

    local n = #row.Cells
    if n == 0 then return end

    local weights = row.Weights or {}
    local total = 0
    for i = 1, n do total = total + (weights[i] or 1) end
    if total <= 0 then total = n end

    local pad = row.Gap or Layout.RowColumnGap
    local availW = w - (n - 1) * pad
    local cx = x
    local maxH = 0

    for i = 1, n do
        local frac = (weights[i] or 1) / total
        local cw = math.floor(availW * frac)
        local ctrl = row.Cells[i]
        ctrl._inlineX = cx
        ctrl._inlineY = y
        ctrl._inlineW = cw
        if ctrl.Kind == "Button" then ctrl.Expand = true end
        cx = cx + cw + pad
        if ctrl.Height > maxH then maxH = ctrl.Height end
    end

    for i = 1, n do
        local ctrl = row.Cells[i]
        if not ctrl.Hidden then
            ctrl:Draw(ctrl._inlineX, ctrl._inlineY, ctrl._inlineW)
            if ctrl.Enabled ~= false and MouseIn(ctrl._inlineX, ctrl._inlineY, ctrl._inlineW, ctrl.Height or Layout.RowHeight) then
                WantTooltip(ctrl.Tooltip or ctrl.Description)
            end
        end
    end

    return maxH
end

local function InputInline(row, x, y, w)
    local n = #row.Cells
    if n == 0 then return 0 end

    local weights = row.Weights or {}
    local total = 0
    for i = 1, n do total = total + (weights[i] or 1) end
    if total <= 0 then total = n end

    local pad = row.Gap or Layout.RowColumnGap
    local availW = w - (n - 1) * pad
    local cx = x
    local maxH = 0

    for i = 1, n do
        local frac = (weights[i] or 1) / total
        local cw = math.floor(availW * frac)
        local ctrl = row.Cells[i]
        ctrl._inlineX = cx
        ctrl._inlineY = y
        ctrl._inlineW = cw
        maxH = math.max(maxH, ctrl.Height or Layout.RowHeight)
        cx = cx + cw + pad
    end

    for i = 1, n do
        local ctrl = row.Cells[i]
        if not ctrl.Hidden and ctrl.Enabled ~= false and ctrl.Input then
            ctrl:Input(ctrl._inlineX, ctrl._inlineY, ctrl._inlineW)
        end
    end

    return maxH
end

local DrawKeybindOverlay
local UpdateKeybindOverlayInput
local DrawPerformanceOverlay
local UpdatePerformanceOverlayInput
local TickPerformanceOverlay

local ContentCursor = { y = 0 }

local DrawRow
local InputRow

local function IsSection(row)
    return getmetatable(row) == Section
end

local function GetSectionHeaderHeight(section)

    if section.Description and section.Description ~= "" then
        return Layout.SectionTitleH + Layout.SectionDescH + 17
    end
    return Layout.SectionTitleH + 15
end

local function TickSection(section)
    local target = section.Collapsed and 1 or 0
    section._collapse = section._collapse or target
    if State.NoAnim then
        section._collapse = target
    else
        section._collapse = Approach(section._collapse, target, 18, State.Delta)
        if math.abs(section._collapse - target) < 0.01 then
            section._collapse = target
        end
    end
end

local function MeasureSection(section, w)
    TickSection(section)

    local panelW = math.max(1, w)
    local innerW = math.max(1, panelW - Layout.SectionPadX * 2)
    local contentH = 0

    for _, child in ipairs(section.Rows or {}) do
        if not child.Hidden then
            if getmetatable(child) == InlineRow then
                local h = 0
                for _, ctrl in ipairs(child.Cells or {}) do
                    if not ctrl.Hidden then
                        h = math.max(h, ctrl.Height or Layout.RowHeight)
                    end
                end
                contentH = contentH + (h > 0 and h or Layout.RowHeight)
            else
                contentH = contentH + (child.Height or Layout.RowHeight)
            end
            contentH = contentH + Layout.RowGapY
        end
    end

    if contentH > 0 then
        contentH = contentH - Layout.RowGapY
    end

    local headerH = GetSectionHeaderHeight(section)
    local contentMinH = math.max(Layout.RowHeight, contentH)
    local fullPanelH = Layout.SectionPadY + contentMinH + Layout.SectionPadY + Layout.SectionBottomPad
    local collapse = Clamp(section._collapse or 0, 0, 1)
    local visiblePanelH = fullPanelH * (1 - collapse)

    return headerH + visiblePanelH
end

local function VerticalVisible(y, h)
    if ActiveClipTop == nil or ActiveClipBottom == nil then return true end
    h = math.max(0, h or 0)
    return (y + h >= ActiveClipTop) and (y <= ActiveClipBottom)
end

local function DrawSection(section, x, y, w)
    TickSection(section)

    local headerH = GetSectionHeaderHeight(section)
    local collapse = Clamp(section._collapse or 0, 0, 1)

    local contentH = 0
    for _, child in ipairs(section.Rows or {}) do
        if not child.Hidden then
            if getmetatable(child) == InlineRow then
                local h = 0
                for _, ctrl in ipairs(child.Cells or {}) do
                    if not ctrl.Hidden then h = math.max(h, ctrl.Height or Layout.RowHeight) end
                end
                contentH = contentH + (h > 0 and h or Layout.RowHeight)
            else
                contentH = contentH + (child.Height or Layout.RowHeight)
            end
            contentH = contentH + Layout.RowGapY
        end
    end
    if contentH > 0 then contentH = contentH - Layout.RowGapY end

    local fullContentH = Layout.SectionPadY + math.max(Layout.RowHeight, contentH) + Layout.SectionPadY + Layout.SectionBottomPad
    local visibleContentH = math.max(0, fullContentH * (1 - collapse))
    local totalH = headerH + visibleContentH

    section._layoutX = x
    section._layoutY = y
    section._layoutW = w
    section._layoutH = totalH

    local viewportTop = ActiveClipTop or -math.huge
    local viewportBottom = ActiveClipBottom or math.huge
    local clippedTop = math.max(y, viewportTop)
    local clippedBottom = math.min(y + totalH, viewportBottom)
    local clippedH = math.max(0, clippedBottom - clippedTop)
    if clippedH <= 0 then return end

    if clippedTop == y and clippedBottom == y + totalH then
        CutPanel(x, y, w, totalH, 10, State.Theme.Panel, 40, GlassSurfaceAlpha * FrameAlpha)
        CutOutline(x, y, w, totalH, 10, mix(State.Theme.Stroke, State.Theme.Accent, 0.42), 41, 0.82 * FrameAlpha, 1)
    else
        local cut = math.min(10, w * 0.25, clippedH * 0.25)
        local fill, alpha = State.Theme.Panel, GlassSurfaceAlpha * FrameAlpha
        local edgeAlpha = 0.82 * FrameAlpha

        if clippedH > cut * 2 then
            Rect(x + cut, clippedTop, w - cut, cut, fill, 40, 0, alpha)
            Rect(x, clippedTop + cut, w, clippedH - cut * 2, fill, 40, 0, alpha)
            Rect(x, clippedBottom - cut, w - cut, cut, fill, 40, 0, alpha)
            Triangle(x, clippedTop + cut, x + cut, clippedTop, x + cut, clippedTop + cut, fill, 40, alpha)
            Triangle(x + w - cut, clippedBottom - cut, x + w, clippedBottom - cut, x + w - cut, clippedBottom, fill, 40, alpha)
            Line(x + cut, clippedTop, x + w, clippedTop, mix(State.Theme.Stroke, State.Theme.Accent, 0.42), 41, 1.3, edgeAlpha)
            Line(x, clippedTop + cut, x + cut, clippedTop, mix(State.Theme.Stroke, State.Theme.Accent, 0.42), 41, 1.3, edgeAlpha)
            Line(x, clippedTop + cut, x, clippedBottom, mix(State.Theme.Stroke, State.Theme.Accent, 0.42), 41, 1.3, edgeAlpha)
            Line(x, clippedBottom, x + w - cut, clippedBottom, mix(State.Theme.Stroke, State.Theme.Accent, 0.42), 41, 1.3, edgeAlpha)
            Line(x + w - cut, clippedBottom, x + w, clippedBottom - cut, mix(State.Theme.Stroke, State.Theme.Accent, 0.42), 41, 1.3, edgeAlpha)
            Line(x + w, clippedTop, x + w, clippedBottom - cut, mix(State.Theme.Stroke, State.Theme.Accent, 0.42), 41, 1.3, edgeAlpha)
        else
            Rect(x, clippedTop, w, clippedH, fill, 40, 0, alpha)
        end
    end

    local headerVisible = (y + headerH > viewportTop and y < viewportBottom)
    if headerVisible then
        local titleX = x + Layout.SectionPadX
        local chevronCX = x + w - Layout.SectionPadX - 7
        local chevronCY = y + math.floor(headerH * 0.43)

        Text(section.Title,
             titleX, y + 7,
             State.Theme.Text, Layout.TitleSize,
             Fonts.SystemBold, 50, 0.98,
             math.max(1, chevronCX - titleX - 16))

        if section.Description and section.Description ~= "" then
            Text(section.Description,
                 titleX, y + 7 + Layout.SectionTitleH,
                 State.Theme.TextDim, Layout.SmallSize,
                 Fonts.System, 50, 0.72,
                 math.max(1, chevronCX - titleX - 16))
        end

        local arm = 4.2
        local downLX, downLY = chevronCX - arm, chevronCY - 2
        local downRX, downRY = chevronCX + arm, chevronCY - 2
        local downMX, downMY = chevronCX, chevronCY + 2.5
        local rightLX, rightLY = chevronCX - 2, chevronCY - arm
        local rightRX, rightRY = chevronCX - 2, chevronCY + arm
        local rightMX, rightMY = chevronCX + 2.5, chevronCY

        local ax = downLX + (rightLX - downLX) * collapse
        local ay = downLY + (rightLY - downLY) * collapse
        local bx = downMX + (rightMX - downMX) * collapse
        local by = downMY + (rightMY - downMY) * collapse
        local cx = downRX + (rightRX - downRX) * collapse
        local cy = downRY + (rightRY - downRY) * collapse

        Line(ax, ay, bx, by, State.Theme.Accent, 51, 1.6, 0.88)
        Line(bx, by, cx, cy, State.Theme.Accent, 51, 1.6, 0.88)

        local separatorAlpha = 0.50 * (1 - collapse)
        if separatorAlpha > 0.01 then
            Line(x + Layout.SectionPadX, y + headerH - 1,
                 x + w - Layout.SectionPadX, y + headerH - 1,
                 State.Theme.Stroke, 49, 1, separatorAlpha)
        end
    end

    if collapse >= 0.985 then return end

    local panelY = y + headerH
    local innerX = x + Layout.SectionPadX
    local innerY = panelY + Layout.SectionPadY
    local innerW = math.max(1, w - Layout.SectionPadX * 2)
    local cy = innerY
    local contentBottom = math.min(panelY + visibleContentH - Layout.SectionPadY,
                                   viewportBottom - Layout.SectionPadY)

    for _, child in ipairs(section.Rows or {}) do
        if not child.Hidden and cy < contentBottom then
            local estimatedH = child.Height or Layout.RowHeight
            if getmetatable(child) == InlineRow then
                estimatedH = Layout.RowHeight
                for _, ctrl in ipairs(child.Cells or {}) do
                    if not ctrl.Hidden then
                        estimatedH = math.max(estimatedH, ctrl.Height or Layout.RowHeight)
                    end
                end
            end

            local h = estimatedH
            local intersectsViewport =
                (cy + estimatedH) > viewportTop and
                cy < contentBottom and
                cy < viewportBottom

            if intersectsViewport then
                if getmetatable(child) == InlineRow then
                    h = LayoutInline(child, innerX, cy, innerW)
                else
                    h = DrawRow(child, innerX, cy, innerW)
                end
            end

            cy = cy + (h or Layout.RowHeight) + Layout.RowGapY
        end
    end
end

local function InputSection(section, x, y, w)

    x = x or section._layoutX or 0
    y = y or section._layoutY or 0
    w = w or section._layoutW or 0
    local headerH = GetSectionHeaderHeight(section)

    if MouseIn(x, y, w, headerH) and Input.Click then
        section.Collapsed = not section.Collapsed
        Input.Click = false
        return
    end

    if (section._collapse or 0) >= 0.98 then return end

    local panelY = y + headerH
    local innerX = x + Layout.SectionPadX
    local innerY = panelY + Layout.SectionPadY
    local innerW = math.max(1, w - Layout.SectionPadX * 2)
    local cy = innerY

    for _, child in ipairs(section.Rows or {}) do
        if not child.Hidden then
            local h = child.Height or Layout.RowHeight
            if getmetatable(child) == InlineRow then
                h = Layout.RowHeight
                for _, ctrl in ipairs(child.Cells or {}) do
                    if not ctrl.Hidden then h = math.max(h, ctrl.Height or Layout.RowHeight) end
                end
                if cy >= Geometry.ContentY and cy + h <= Geometry.ContentY + Geometry.ContentH then
                    InputInline(child, innerX, cy, innerW)
                end
            else
                if cy >= Geometry.ContentY and cy + h <= Geometry.ContentY + Geometry.ContentH then
                    h = InputRow(child, innerX, cy, innerW)
                end
            end
            cy = cy + (h or Layout.RowHeight) + Layout.RowGapY
        end
    end
end

function Base.AccessoryWidth(ctrl)
    if ctrl.Kind == "ColorPicker" then return 30 end
    if ctrl.Kind == "Keybind" then
        local display = ctrl._listening and "..." or KeyLabel.Format(ctrl.Value)
        return math.max(42, TextWidth(display, Layout.TextSize, Fonts.Monospace) + 22)
    end
    return 0
end

function Base.LayoutAccessories(row, x, y, w, inputOnly)
    local list = row.Accessories or {}
    if #list == 0 then return w end

    local ordered = {}
    local wanted = row.InlineOrder
    if type(wanted) == "table" then
        local used = {}
        for _, kind in ipairs(wanted) do
            kind = string.lower(tostring(kind))
            if kind ~= "toggle" and kind ~= "host" then
                for i, ctrl in ipairs(list) do
                    if not used[i] and string.lower(tostring(ctrl.Kind)) == kind then
                        ordered[#ordered + 1] = ctrl
                        used[i] = true
                    end
                end
            end
        end
        for i, ctrl in ipairs(list) do
            if not used[i] then ordered[#ordered + 1] = ctrl end
        end
    else
        for _, ctrl in ipairs(list) do ordered[#ordered + 1] = ctrl end
    end

    local right = x + w
    local gap = row.InlineGap or 8
    for i = #ordered, 1, -1 do
        local ctrl = ordered[i]
        if not ctrl.Hidden then
            local aw = Base.AccessoryWidth(ctrl)
            right = right - aw
            local oldTitle = ctrl.Title
            ctrl.Title = ""
            local cy = y + math.max(0, ((row.Height or Layout.RowHeight) - (ctrl.Height or Layout.RowHeight)) * 0.5)
            if inputOnly then ctrl:Input(right, cy, aw) else ctrl:Draw(right, cy, aw) end
            ctrl.Title = oldTitle
            right = right - gap
        end
    end
    return math.max(1, right - x)
end

function DrawRow(row, x, y, w)
    if row.Hidden then return 0 end

    if IsSection(row) then
        DrawSection(row, x, y, w)
        return row._layoutH or MeasureSection(row, w)
    end

    if getmetatable(row) == InlineRow then
        local h = LayoutInline(row, x, y, w)
        for _, ctrl in ipairs(row.Cells or {}) do
            local kind = ctrl.Kind
            local tooltipAllowed = kind == "Toggle"
                or kind == "Button"
                or kind == "Slider"
                or kind == "RangeSlider"
                or kind == "Dropdown"
            if tooltipAllowed and ctrl.Enabled ~= false and ctrl.Tooltip and ctrl.Tooltip ~= ""
                and ctrl._inlineX and ctrl._inlineY and ctrl._inlineW
                and MouseIn(ctrl._inlineX, ctrl._inlineY, ctrl._inlineW, ctrl.Height or Layout.RowHeight) then
                WantTooltip(ctrl.Tooltip)
            end
        end
        return h or Layout.RowHeight
    end

    if row.Draw then
        local contentW = w
        if row.Accessories and #row.Accessories > 0 then
            local reserved = 0
            for _, accessory in ipairs(row.Accessories) do
                if not accessory.Hidden then reserved = reserved + Base.AccessoryWidth(accessory) + (row.InlineGap or 8) end
            end
            contentW = math.max(1, w - reserved)
        end
        local ok, err = pcall(function()
            row:Draw(x, y, contentW)
            if row.Accessories and #row.Accessories > 0 then
                Base.LayoutAccessories(row, x, y, w, false)
            end
        end)
        if not ok then
            if not row._drawErrorShown then
                row._drawErrorShown = true
                warn("[Library] control draw error:", tostring(row.Kind), tostring(row.Title), tostring(err))
            end
            return row.Height or Layout.RowHeight
        end

        local kind = row.Kind
        local tooltipAllowed = kind == "Toggle"
            or kind == "Button"
            or kind == "Slider"
            or kind == "RangeSlider"
            or kind == "Dropdown"
        if tooltipAllowed and row.Enabled ~= false and row.Tooltip and row.Tooltip ~= ""
            and MouseIn(x, y, w, row.Height or Layout.RowHeight) then
            WantTooltip(row.Tooltip)
        end
        return row.Height or Layout.RowHeight
    end

    return 0
end

function InputRow(row, x, y, w)
    if row.Hidden then return 0 end

    if IsSection(row) then
        InputSection(row, x, y, w)
        return row._layoutH or MeasureSection(row, w)
    end

    if getmetatable(row) == InlineRow then
        InputInline(row, x, y, w)
        return Layout.RowHeight
    end

    if row.Input then
        local contentW = w
        if row.Accessories and #row.Accessories > 0 then
            local reserved = 0
            for _, accessory in ipairs(row.Accessories) do
                if not accessory.Hidden then reserved = reserved + Base.AccessoryWidth(accessory) + (row.InlineGap or 8) end
            end
            contentW = math.max(1, w - reserved)
        end
        row:Input(x, y, contentW)
        if row.Accessories and #row.Accessories > 0 then
            Base.LayoutAccessories(row, x, y, w, true)
        end
        return row.Height or Layout.RowHeight
    end

    return 0
end

Register("RangeSlider", function(parent, opts)
    opts = opts or {}
    local self = Base.New("RangeSlider", parent, opts)
    self.Min      = opts.Min or 0
    self.Max      = opts.Max or 100
    self.Step     = opts.Step or 1
    self.Low      = opts.DefaultLow or self.Min
    self.High     = opts.DefaultHigh or self.Max
    self.DeclaredDefaultLow = self.Low
    self.DeclaredDefaultHigh = self.High
    self.Suffix   = opts.Suffix or ""
    self.Callback = opts.Callback
    self.Height   = 38

    self._dragging = nil
    self._lowAnim  = 0
    self._highAnim = 0

    local function snap(v)
        if self.Step <= 0 then return Clamp(v, self.Min, self.Max) end
        local s = math.floor((v - self.Min) / self.Step + 0.5) * self.Step + self.Min
        return Clamp(s, self.Min, self.Max)
    end

    local function fracOf(v)
        if self.Max <= self.Min then return 0 end
        return (v - self.Min) / (self.Max - self.Min)
    end

    function self:GetValue() return self.Low, self.High end
    function self:GetLow() return self.Low end
    function self:GetHigh() return self.High end

    function self:SetValue(lo, hi, silent)
        lo = snap(lo)
        hi = snap(hi)
        if lo > hi then lo, hi = hi, lo end
        if self.Low == lo and self.High == hi then return end
        self.Low, self.High = lo, hi
        if not silent then
            if self.Callback then pcall(self.Callback, lo, hi) end
            self:_Fire({ lo, hi })
        end
    end

    function self:Draw(x, y, w)
        local th = State.Theme
        local trackH = Layout.SliderH
        local knobR  = Layout.SliderKnob

        local valueText = tostring(self.Low) .. " - " .. tostring(self.High) .. self.Suffix
        local valueW = TextWidth(valueText, Layout.TextSize, Fonts.Monospace)
        local badgeW = valueW + 14
        local badgeH = 18
        local badgeX = x + w - badgeW
        local badgeY = y + 2

        if self.Title ~= "" then
            Text(self.Title, x, y + 1,
                 th.Text, Layout.TextSize, Fonts.System,
                 51, self.Enabled and 0.92 or 0.4,
                 w - badgeW - 12)
        end

        Rect(badgeX, badgeY, badgeW, badgeH,
             th.PanelHi, 52, 4, 0.85)
        Stroke(badgeX, badgeY, badgeW, badgeH,
               th.Stroke, 53, 4, 0.55)
        Text(valueText,
             badgeX + (badgeW - valueW) / 2,
             badgeY + (badgeH - Layout.TextSize) / 2,
             th.Accent, Layout.TextSize, Fonts.Monospace,
             54, 1)

        local trackY = y + 28
        local trackX = x
        local trackW = w

        Rect(trackX, trackY - trackH / 2, trackW, trackH,
             th.Track, 51, trackH / 2, 0.8)

        local flo = fracOf(self.Low)
        local fhi = fracOf(self.High)
        local fillX = trackX + trackW * flo
        local fillW = trackW * (fhi - flo)
        if fillW > 0.5 then
            Rect(fillX, trackY - trackH / 2, fillW, trackH,
                 th.Accent, 52, trackH / 2, 0.85)
        end

        local hover = MouseIn(x, trackY - 10, w, 20) and self.Enabled
        TickAnim(self, hover, self._dragging ~= nil, State.Delta)

        self._lowAnim  = Approach(self._lowAnim,  (self._dragging == "low")  and 1 or 0, 22, State.Delta)
        self._highAnim = Approach(self._highAnim, (self._dragging == "high") and 1 or 0, 22, State.Delta)

        local lx = trackX + trackW * flo
        local hx = trackX + trackW * fhi

        local lr = knobR + self._lowAnim * 2
        Circle(lx, trackY, lr + 3, th.Accent, 53, false, 1.4, 24, 0.3 + self._lowAnim * 0.5)
        Circle(lx, trackY, lr, th.Text, 54, true, 1, 24, 1)

        local hr = knobR + self._highAnim * 2
        Circle(hx, trackY, hr + 3, th.Accent, 53, false, 1.4, 24, 0.3 + self._highAnim * 0.5)
        Circle(hx, trackY, hr, th.Text, 54, true, 1, 24, 1)
    end

    function self:Input(x, y, w)
        if not self.Enabled then return end
        local trackY = y + 28
        local hitY = trackY - 12
        local hitH = 24

        local inTrack = MouseIn(x, hitY, w, hitH)

        if inTrack and Input.Click then

            local t = Clamp((Input.X - x) / w, 0, 1)
            local v = self.Min + t * (self.Max - self.Min)
            local dlo = math.abs(v - self.Low)
            local dhi = math.abs(v - self.High)
            self._dragging = (dlo <= dhi) and "low" or "high"
        end

        if not Input.Down then self._dragging = nil end

        if self._dragging and Input.Down then
            local t = Clamp((Input.X - x) / w, 0, 1)
            local v = self.Min + t * (self.Max - self.Min)
            if self._dragging == "low" then
                self:SetValue(math.min(v, self.High), self.High)
            else
                self:SetValue(self.Low, math.max(v, self.Low))
            end
        end
    end

    return self
end)

Register("Dropdown", function(parent, opts)
    opts = opts or {}
    local self = Base.New("Dropdown", parent, opts)
    self.Options  = opts.Options or opts.options or {}
    self.Multi    = (opts.Multi == true or opts.multi == true or
                     opts.MultiSelect == true or opts.multiSelect == true)
    self.Callback = opts.Callback or opts.callback
    self.Height   = 32

    self._open = false
    self._openAnim = 0
    self._listScroll = 0
    self._listScrollTo = 0
    self._scrollDrag = false
    self._scrollDragOffsetY = 0
    self._popupGeom = nil

    local function CopyArray(value)
        local out = {}
        if type(value) == "table" then
            for _, v in ipairs(value) do out[#out + 1] = v end
        end
        return out
    end

    local function Contains(list, value)
        for _, v in ipairs(list or {}) do
            if v == value then return true end
        end
        return false
    end

    local default = opts.Default
    if default == nil then default = opts.default end

    if self.Multi then
        self.Value = CopyArray(default)
    else
        self.Value = default
        if self.Value == nil then self.Value = self.Options[1] end
    end

    function self:GetValue()
        if self.Multi then return CopyArray(self.Value) end
        return self.Value
    end

    function self:SetValue(v, silent)
        if self.Multi then
            local nextValue = CopyArray(v)
            self.Value = nextValue
            if not silent then
                local emitted = CopyArray(nextValue)
                if self.Callback then pcall(self.Callback, emitted) end
                self:_Fire(emitted)
            end
            return
        end

        if self.Value == v then return end
        self.Value = v
        if not silent then
            if self.Callback then pcall(self.Callback, v) end
            self:_Fire(v)
        end
    end

    function self:_ToggleOption(option)
        if not self.Multi then
            self:SetValue(option)
            self._open = false
            return
        end

        local nextValue = CopyArray(self.Value)
        local found = nil
        for i, v in ipairs(nextValue) do
            if v == option then found = i break end
        end
        if found then
            table.remove(nextValue, found)
        else
            nextValue[#nextValue + 1] = option
        end
        self:SetValue(nextValue)
    end

    function self:_DisplayValue()
        if not self.Multi then return tostring(self.Value or "-") end
        if #self.Value == 0 then return "None" end
        local parts = {}
        for _, v in ipairs(self.Value) do parts[#parts + 1] = tostring(v) end
        return table.concat(parts, ", ")
    end

    local function FitText(text, maxW, size, font)
        text = tostring(text or "")
        maxW = math.max(1, maxW or 1)
        if TextWidth(text, size, font) <= maxW then return text end

        local dots = "..."
        local dotsW = TextWidth(dots, size, font)
        if dotsW >= maxW then return "" end

        local lo, hi = 0, #text
        while lo < hi do
            local mid = math.ceil((lo + hi) / 2)
            local candidate = string.sub(text, 1, mid) .. dots
            if TextWidth(candidate, size, font) <= maxW then
                lo = mid
            else
                hi = mid - 1
            end
        end
        return string.sub(text, 1, lo) .. dots
    end

    function self:_BuildFieldGeometry(x, y, w, h)
        local fieldY = y + 2
        local labelW = self.Title ~= "" and TextWidth(self.Title, Layout.TextSize, Fonts.System) or 0

        local labelReserve = math.min(w * 0.48, labelW + 18)
        local availableW = math.max(70, w - labelReserve)
        local maxFieldW = math.min(240, availableW)

        local display = self:_DisplayValue()
        local textW = TextWidth(display, Layout.TextSize, Fonts.SystemBold)
        local desiredW = textW + 34
        local fieldW = Clamp(desiredW, 70, maxFieldW)

        local fieldX = x + w - fieldW

        return {
            X = fieldX,
            Y = fieldY,
            W = fieldW,
            H = h,
            Display = display,
            LabelRoom = math.max(1, fieldX - x - 8),
        }
    end

    function self:_BuildPopupGeometry(fieldX, fieldY, fieldW, h)
        local rowH = 22
        local rowGap = 2
        local maxVisible = math.max(3, math.floor(tonumber(opts.VisibleRows or opts.visibleRows) or 6))
        local visible = math.min(#self.Options, maxVisible)

        local shownRows = math.max(1, visible)
        local listH = 8 + shownRows * rowH + math.max(0, shownRows - 1) * rowGap

        local minX = Geometry.ContentX + 4
        local maxRight = Geometry.ContentX + Geometry.ContentW - 4
        local availableW = math.max(70, maxRight - minX)
        local requestedW = tonumber(opts.PopupWidth or opts.popupWidth) or 210
        local popupW = Clamp(math.max(fieldW, requestedW), 70, availableW)

        local preferredX = fieldX + fieldW - popupW
        local popupX = Clamp(preferredX, minX, math.max(minX, maxRight - popupW))
        local popupY = fieldY + h + 3

        local maxScroll = math.max(0, #self.Options - maxVisible)
        local barW = 5
        local trackX = popupX + popupW - barW - 3
        local trackY = popupY + 4
        local trackH = listH - 8
        local thumbH = maxScroll > 0 and math.max(14, trackH * (maxVisible / math.max(#self.Options, 1))) or trackH
        local travel = math.max(1, trackH - thumbH)

        return {
            X = popupX, Y = popupY, W = popupW, H = listH,
            RowH = rowH, RowGap = rowGap, RowStride = rowH + rowGap,
            MaxVisible = maxVisible, Visible = visible,
            MaxScroll = maxScroll,
            TrackX = trackX, TrackY = trackY, TrackW = barW,
            TrackH = trackH, ThumbH = thumbH, Travel = travel,
        }
    end

    function self:Draw(x, y, w)
        local th = State.Theme
        local h = Layout.DropdownH

        local fg = self:_BuildFieldGeometry(x, y, w, h)
        local fieldX, fieldY, fieldW = fg.X, fg.Y, fg.W

        local hover = MouseIn(fieldX, fieldY, fieldW, h) and self.Enabled
        TickAnim(self, hover, self._open, State.Delta)

        local bg = mix(th.PanelHi, th.Panel, self._hover * 0.5)
        Rect(fieldX, fieldY, fieldW, h, bg, 52, 6, 0.85 + 0.1 * self._hover)
        Stroke(fieldX, fieldY, fieldW, h, th.Stroke, 53, 6, 0.5 + 0.3 * self._hover)

        if self.Title ~= "" then
            Text(self.Title, x, fieldY + (h - Layout.TextSize) / 2,
                 th.Text, Layout.TextSize, Fonts.System,
                 54, self.Enabled and 0.92 or 0.4,
                 fg.LabelRoom)
        end

        local valueRightPad = 22
        local valueMaxW = math.max(1, fieldW - valueRightPad - 6)
        local valueText = FitText(fg.Display, valueMaxW, Layout.TextSize, Fonts.SystemBold)
        local valueW = TextWidth(valueText, Layout.TextSize, Fonts.SystemBold)
        Text(valueText,
             fieldX + fieldW - valueRightPad - valueW,
             fieldY + (h - Layout.TextSize) / 2,
             th.Accent, Layout.TextSize, Fonts.SystemBold,
             54, self.Enabled and 1 or 0.4,
             valueMaxW)

        local cx = fieldX + fieldW - 14
        local cy = fieldY + h / 2
        local ang = (self._open and 1 or 0) * math.pi
        local rad = 4
        local ca, sa = math.cos(ang), math.sin(ang)
        local function rot(ox, oy)
            return cx + ox * ca - oy * sa, cy + ox * sa + oy * ca
        end
        local x1, y1 = rot(-rad, -rad * 0.45)
        local xt, yt = rot(0, rad * 0.45)
        local x2, y2 = rot(rad, -rad * 0.45)
        Bar(x1, y1, xt, yt, 1.5, th.TextDim, 55, 0.85)
        Bar(xt, yt, x2, y2, 1.5, th.TextDim, 55, 0.85)

        self._openAnim = Approach(self._openAnim, self._open and 1 or 0, 20, State.Delta)
        if math.abs(self._openAnim - (self._open and 1 or 0)) < 0.01 then
            self._openAnim = self._open and 1 or 0
        end

        if self._openAnim > 0.02 then
            local pg = self:_BuildPopupGeometry(fieldX, fieldY, fieldW, h)
            self._popupGeom = pg
            if self._open then
                State.OpenDropdownWheelRect = { X = pg.X, Y = pg.Y, W = pg.W, H = pg.H }
                State.ActiveDropdown = self
            end
            self:_DrawList(pg, th)
        elseif not self._open then
            self._popupGeom = nil
        end
    end

    function self:_DrawList(pg, th)
        local maxScroll = pg.MaxScroll
        self._listScrollTo = Clamp(self._listScrollTo, 0, maxScroll)
        if State.NoAnim then
            self._listScroll = self._listScrollTo
        else
            self._listScroll = Approach(self._listScroll, self._listScrollTo, 22, State.Delta)
            if math.abs(self._listScroll - self._listScrollTo) < 0.05 then
                self._listScroll = self._listScrollTo
            end
        end

        Rect(pg.X + 2, pg.Y + 3, pg.W, pg.H, Color3.new(0, 0, 0), 60, 6, 0.25 * self._openAnim)
        Rect(pg.X, pg.Y, pg.W, pg.H, th.Base, 61, 6, 0.98 * self._openAnim)
        Stroke(pg.X, pg.Y, pg.W, pg.H, th.Accent, 62, 6, 0.5 * self._openAnim)

        local scrollbarReserve = maxScroll > 0 and 11 or 3
        local optionPadX = 8
        local labelMaxW = math.max(1, pg.W - optionPadX - 5 - scrollbarReserve)

        local firstRow = math.floor(Clamp(self._listScroll, 0, maxScroll) + 0.5)
        if self._listScrollTo >= maxScroll - 0.01 then firstRow = maxScroll end
        for i = 1, pg.Visible do
            local idx = i + firstRow
            local option = self.Options[idx]
            if option == nil then break end

            local ry = pg.Y + 4 + (i - 1) * pg.RowStride
            local selected = self.Multi and Contains(self.Value, option) or (option == self.Value)
            local hoverW = math.max(1, pg.W - 8 - (maxScroll > 0 and 9 or 0))
            local hover = MouseIn(pg.X + 4, ry, hoverW, pg.RowH)

            if selected or hover then
                local a = selected and 0.18 or 0.1
                Rect(pg.X + 4, ry, hoverW, pg.RowH, th.Accent, 63, 4, a * self._openAnim)
            end

            local optionText = FitText(option, labelMaxW, Layout.TextSize, Fonts.System)
            local labelColor = selected and th.Accent or th.Text
            Text(optionText,
                 pg.X + optionPadX, ry + (pg.RowH - Layout.TextSize) / 2,
                 labelColor, Layout.TextSize, Fonts.System,
                 64, (selected and 1 or 0.85) * self._openAnim,
                 labelMaxW)

            if hover and Input.Click and not self._scrollDrag then
                Input.Click = false
                self:_ToggleOption(option)
            end
        end

        if maxScroll > 0 then
            local thumbY = pg.TrackY + pg.Travel * (self._listScroll / maxScroll)
            Rect(pg.TrackX, pg.TrackY, pg.TrackW, pg.TrackH,
                 th.Track, 65, pg.TrackW / 2, 0.62 * self._openAnim)
            Rect(pg.TrackX, thumbY, pg.TrackW, pg.ThumbH,
                 th.Accent, 66, pg.TrackW / 2,
                 (self._scrollDrag and 1 or 0.9) * self._openAnim)
        end
    end

    function self:Input(x, y, w)
        if not self.Enabled then return end
        local h = Layout.DropdownH
        local fg = self:_BuildFieldGeometry(x, y, w, h)
        local fieldX, fieldY, fieldW = fg.X, fg.Y, fg.W

        if self._open and self._popupGeom then
            local pg = self._popupGeom
            if Input.Click and MouseIn(pg.X, pg.Y, pg.W, pg.H) then
                local localY = Input.Y - (pg.Y + 4)
                local row = math.floor(localY / pg.RowStride) + 1
                local withinRow = localY - (row - 1) * pg.RowStride
                if row >= 1 and row <= pg.Visible and withinRow >= 0 and withinRow < pg.RowH then
                    local firstRow = math.floor(Clamp(self._listScroll, 0, pg.MaxScroll) + 0.5)
                    if self._listScrollTo >= pg.MaxScroll - 0.01 then firstRow = pg.MaxScroll end
                    local idx = row + firstRow
                    local option = self.Options[idx]
                    local scrollbarZone = pg.MaxScroll > 0 and
                        MouseIn(pg.TrackX - 3, pg.TrackY, pg.TrackW + 6, pg.TrackH)
                    if option ~= nil and not scrollbarZone then
                        Input.Click = false
                        self:_ToggleOption(option)
                        return
                    end
                end
            end

            if Input.Click
               and not MouseIn(fieldX, fieldY, fieldW, h)
               and not MouseIn(pg.X, pg.Y, pg.W, pg.H) then
                self._open = false
            end
        end

        if MouseIn(fieldX, fieldY, fieldW, h) and Input.Click then
            Input.Click = false
            self._open = not self._open
            if self._open then State.ActiveDropdown = self end
        end
    end

    return self
end)

Register("Keybind", function(parent, opts)
    opts = opts or {}
    local self = Base.New("Keybind", parent, opts)
    self.Value    = opts.Default or "none"
    self.Callback = opts.Callback
    self.PressedCallback = opts.Pressed or opts.OnPressed or opts.PressCallback
    self.ReleasedCallback = opts.Released or opts.OnReleased
    self.Mode     = opts.Mode or "Hold"
    self.Height   = Layout.ToggleH

    self._listening = false
    self._chipAnim = 0
    self._bindHeld = false
    self._bindToggle = false
    Keys.Track(self.Value)

    function self:GetValue() return self.Value end

    function self:SetValue(v, silent)
        v = v or "none"
        v = string.lower(v)
        if self.Value == v then return end
        self.Value = v
        Keys.Track(v)
        if not silent then
            if self.Callback then pcall(self.Callback, v) end
            self:_Fire(v)
        end
    end

    function self:Draw(x, y, w)
        local th = State.Theme
        local h = Layout.FieldH

        local titleW = 0
        if self.Title ~= "" then
            Text(self.Title, x, TextMidY(y, self.Height, Layout.TextSize),
                 th.Text, Layout.TextSize, Fonts.System,
                 51, self.Enabled and 0.92 or 0.4,
                 w - 80)
            titleW = TextWidth(self.Title, Layout.TextSize, Fonts.System)
        end

        local display = self._listening and "..." or KeyLabel.Format(self.Value)
        local chipW = math.max(38, TextWidth(display, Layout.TextSize, Fonts.Monospace) + 18)
        local chipX = x + w - chipW
        local chipY = y + (self.Height - h) / 2

        local hover = MouseIn(chipX, chipY, chipW, h) and self.Enabled
        TickAnim(self, hover, self._listening, State.Delta)
        self._chipAnim = Approach(self._chipAnim, self._listening and 1 or 0, 22, State.Delta)

        local bg = mix(th.PanelHi, th.Accent, self._chipAnim * 0.5)
        Rect(chipX, chipY, chipW, h, bg, 52, 6, 0.85 + 0.1 * self._hover)

        local strokeColor = self._listening and th.Accent or th.Stroke
        local strokeA = self._listening and (0.6 + 0.4 * self._chipAnim) or (0.5 + 0.3 * self._hover)
        Stroke(chipX, chipY, chipW, h, strokeColor, 53, 6, strokeA)

        local dotColor = th.TextDim
        if self.Mode == "Toggle" then dotColor = th.AccentA
        elseif self.Mode == "Always" then dotColor = th.AccentB end

        Circle(chipX + 8, chipY + h / 2, 2, dotColor, 54, true, 1, 10, 0.9)

        local labelColor = self._listening and th.Accent or th.Text
        Text(display,
             chipX + (chipW - TextWidth(display, Layout.TextSize, Fonts.Monospace)) / 2 + 4,
             chipY + (h - Layout.TextSize) / 2,
             labelColor, Layout.TextSize, Fonts.Monospace,
             54, self.Enabled and 1 or 0.5)
    end

    function self:Input(x, y, w)
        if not self.Enabled then return end
        local h = Layout.FieldH

        local display = self._listening and "..." or KeyLabel.Format(self.Value)
        local chipW = math.max(38, TextWidth(display, Layout.TextSize, Fonts.Monospace) + 18)
        local chipX = x + w - chipW
        local chipY = y + (self.Height - h) / 2

        if MouseIn(chipX, chipY, chipW, h) and Input.Click then
            Input.Click = false
            self._listening = true
            BeginCapture(self, function(name)
                self._listening = false
                self:SetValue(name)
            end)
        end
    end

    return self
end)

Register("ConfigTextbox", function(parent, opts)
    opts = opts or {}
    local self = Base.New("ConfigTextbox", parent, opts)
    self.Value       = opts.Default or ""
    self.Placeholder = opts.Placeholder or "Enter..."
    self.Callback    = opts.Callback
    self.Allowed     = opts.Allowed
    self.Height      = 30

    self._focus = { Value = self.Value, Caret = #self.Value, Anchor = nil }
    self._caretAnim = 1

    function self:GetValue()
        if Focus.Field == self._focus then return self._focus.Value end
        return self.Value
    end

    function self:SetValue(v, silent)
        v = tostring(v or "")
        self.Value = v
        self._focus.Value = v
        self._focus.Caret = #v
        self._focus.Anchor = nil
        if not silent then
            if self.Callback then pcall(self.Callback, v) end
            self:_Fire(v)
        end
    end

    function self:Draw(x, y, w)
        local th = State.Theme
        local h = Layout.FieldH + 2
        local fieldY = y + 2

        local fieldX = x
        local fieldW = math.max(70, w)

        local hover = MouseIn(fieldX, fieldY, fieldW, h) and self.Enabled
        local focused = (Focus.Field == self._focus)
        TickAnim(self, hover, focused, State.Delta)

        local bg = mix(th.PanelHi, th.Panel, self._hover * 0.5)
        Rect(fieldX, fieldY, fieldW, h, bg, 52, 6, 0.85 + 0.1 * self._hover)

        local strokeColor = focused and th.Accent or th.Stroke
        local strokeA = focused and 0.85 or (0.5 + 0.3 * self._hover)
        Stroke(fieldX, fieldY, fieldW, h, strokeColor, 53, 6, strokeA)

        local textX = fieldX + 10

        local val = self._focus.Value
        local display = (val == "" and not focused) and self.Placeholder or val
        local color = (val == "" and not focused) and th.TextMuted or th.Text

        local availW = fieldW - (textX - fieldX) - 12
        local charWidth = Layout.TextSize * 0.50
        local fit = math.max(1, math.floor(availW / charWidth))
        local caret = math.max(0, math.min(self._focus.Caret or #val, #val))
        local scroll = focused and caret > fit and caret - fit or 0
        local visible = string.sub(display, scroll + 1, math.min(#display, scroll + fit))

        if focused then

            for index = 1, #visible do
                Text(string.sub(visible, index, index),
                     textX + (index - 1) * charWidth,
                     fieldY + (h - Layout.TextSize) / 2,
                     color, Layout.TextSize, Fonts.UI, 54, 1)
            end
        else
            Text(visible, textX, fieldY + (h - Layout.TextSize) / 2,
                 color, Layout.TextSize, Fonts.System, 54, 1)
        end

        if focused then
            self._caretAnim = self._caretAnim - State.Delta * 1.6
            if self._caretAnim < 0 then self._caretAnim = 1 end
            local caretAlpha = (self._caretAnim > 0.5) and 1 or 0.2
            local caretX = textX + math.min(math.max(caret - scroll, 0), #visible) * charWidth

            self._focus.CharWidth = charWidth
            self._focus.EditX = textX
            self._focus.Scroll = scroll

            Rect(caretX, fieldY + 4, 1.0, h - 8, th.Text, 55, 0, caretAlpha)
        end
    end

    function self:Input(x, y, w)
        if not self.Enabled then return end
        local h = Layout.FieldH + 2
        local fieldX = x
        local fieldY = y + 2
        local fieldW = math.max(70, w)
        local hovered = MouseIn(fieldX, fieldY, fieldW, h)

        if Input.Click and hovered then
            self._focus.Value = (Focus.Field == self._focus) and self._focus.Value or self.Value
            self._focus.OnCommit = function(v)
                self:SetValue(v)
            end

            local charWidth = self._focus.CharWidth or (Layout.TextSize * 0.50)
            local editX = self._focus.EditX or (fieldX + 10)
            local scroll = self._focus.Scroll or 0
            local hit = math.min(
                math.max(scroll + math.floor((Input.X - editX) / charWidth + 0.5), 0),
                #self._focus.Value
            )

            SetFocus(self._focus)
            self._focus.Caret = hit
            self._focus.Anchor = hit
            Input.Click = false
            return
        end

        if Input.Click and Focus.Field == self._focus and not hovered then
            self:SetValue(self._focus.Value)
            ClearFocus()
        end
    end

    return self
end)

local function RGBToHSV(r, g, b)
    local maxc = math.max(r, g, b)
    local minc = math.min(r, g, b)
    local delta = maxc - minc

    local h = 0
    if delta > 0 then
        if maxc == r then
            h = ((g - b) / delta) % 6
        elseif maxc == g then
            h = ((b - r) / delta) + 2
        else
            h = ((r - g) / delta) + 4
        end
        h = h / 6
        if h < 0 then h = h + 1 end
    end

    local s = (maxc == 0) and 0 or (delta / maxc)
    local v = maxc

    return h, s, v
end

local function HSVToRGB(h, s, v)
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)

    local r, g, b
    i = i % 6
    if i == 0 then r, g, b = v, t, p
    elseif i == 1 then r, g, b = q, v, p
    elseif i == 2 then r, g, b = p, v, t
    elseif i == 3 then r, g, b = p, q, v
    elseif i == 4 then r, g, b = t, p, v
    else              r, g, b = v, p, q
    end

    return r, g, b
end

Register("ColorPicker", function(parent, opts)
    opts = opts or {}
    local self = Base.New("ColorPicker", parent, opts)
    self.Value     = opts.Default or Color3.fromRGB(120, 140, 255)
    self.Callback  = opts.Callback
    self.Height    = 22

    self._open     = false
    self._openAnim = 0

    self._h, self._s, self._v = RGBToHSV(self.Value.R, self.Value.G, self.Value.B)

    self._svDrag   = false
    self._hueDrag  = false
    self._alphaDrag = false
    self._alpha    = opts.DefaultAlpha or 1
    self._hexFocus = { Value = "", Caret = 0, Anchor = nil, Allowed = "[#%x]" }
    self._hexCaretAnim = 1

    local function colorToHex(color)
        return string.format("#%02X%02X%02X",
            math.floor(color.R * 255 + 0.5),
            math.floor(color.G * 255 + 0.5),
            math.floor(color.B * 255 + 0.5))
    end

    local function parseHex(value)
        local hex = tostring(value or ""):gsub("#", "")
        if #hex == 3 then
            hex = hex:sub(1,1):rep(2) .. hex:sub(2,2):rep(2) .. hex:sub(3,3):rep(2)
        end
        if #hex ~= 6 or not hex:match("^[%x]+$") then return nil end
        return Color3.fromRGB(tonumber(hex:sub(1,2), 16), tonumber(hex:sub(3,4), 16), tonumber(hex:sub(5,6), 16))
    end

    self._hexFocus.Value = colorToHex(self.Value)
    self._hexFocus.Caret = #self._hexFocus.Value

    function self:GetValue() return self.Value, self._alpha end

    function self:SetValue(color, silent, alpha)
        if not color then return end
        if alpha ~= nil then
            self._alpha = math.max(0, math.min(1, tonumber(alpha) or self._alpha))
        end
        self.Value = color
        self._h, self._s, self._v = RGBToHSV(color.R, color.G, color.B)
        self._hexFocus.Value = colorToHex(color)
        self._hexFocus.Caret = #self._hexFocus.Value
        if not silent then
            if self.Callback then pcall(self.Callback, color, self._alpha) end
            self:_Fire(color)
        end
    end

    local function emit()
        local r, g, b = HSVToRGB(self._h, self._s, self._v)
        self.Value = Color3.new(r, g, b)
        if Focus.Field ~= self._hexFocus then
            self._hexFocus.Value = colorToHex(self.Value)
            self._hexFocus.Caret = #self._hexFocus.Value
        end
        if self.Callback then pcall(self.Callback, self.Value, self._alpha) end
        self:_Fire(self.Value)
    end

    function self:Draw(x, y, w)
        local th = State.Theme
        local h = 16

        local titleW = 0
        if self.Title ~= "" then
            Text(self.Title, x, TextMidY(y, self.Height, Layout.TextSize),
                 th.Text, Layout.TextSize, Fonts.System,
                 51, self.Enabled and 0.92 or 0.4,
                 w - 44)
        end

        local swatchW = 24
        local swatchX = x + w - swatchW
        local swatchY = y + (self.Height - h) / 2

        local hover = MouseIn(swatchX, swatchY, swatchW, h) and self.Enabled
        TickAnim(self, hover, self._open, State.Delta)

        Rect(swatchX, swatchY, swatchW, h, self.Value, 52, 5, self._alpha)
        Stroke(swatchX, swatchY, swatchW, h, th.Text, 53, 5, 0.35 + 0.35 * self._hover)

        self._openAnim = Approach(self._openAnim, self._open and 1 or 0, 18, State.Delta)
        if math.abs(self._openAnim - (self._open and 1 or 0)) < 0.01 then
            self._openAnim = self._open and 1 or 0
        end

        if self._openAnim > 0.02 then
            self:_DrawPanel(swatchX - 190, swatchY + h + 4, 190)
        end
    end

    function self:_DrawPanel(px, py, pw)
        local th = State.Theme
        local a = self._openAnim
        local pph = 172

        Rect(px, py, pw, pph, th.Base, 61, 8, 0.98 * a)
        Stroke(px, py, pw, pph, th.Stroke, 62, 8, 0.55 * a)

        local padX = 10
        local padY = 10

        local svX = px + padX
        local svY = py + padY
        local svW = pw - padX * 2 - 14
        local svH = 88

        local hr, hg, hb = HSVToRGB(self._h, 1, 1)
        local hueColor = Color3.new(hr, hg, hb)

        GradientRect(svX, svY, svW, svH,
                     Color3.new(1, 1, 1), hueColor, 63, a, 64)

        local steps = math.max(1, math.floor(svH))
        for i = 1, steps do
            local t = i / steps
            Rect(svX, svY + i - 1, svW, 1.05,
                 Color3.new(0, 0, 0), 64, 0, t * a)
        end

        local cxp = svX + svW * self._s
        local cyp = svY + svH * (1 - self._v)
        Circle(cxp, cyp, 6, th.Text, 66, false, 1.8, 24, a)
        Circle(cxp, cyp, 6, Color3.new(0, 0, 0), 66, false, 2.6, 24, 0.5 * a)
        Circle(cxp, cyp, 3, self.Value, 67, true, 1, 20, a)

        local hueX = svX
        local hueY = svY + svH + 8
        local hueW = svW
        local hueH = 12

        local hues = 48
        for i = 1, hues do
            local t = (i - 0.5) / hues
            local r, g, b = HSVToRGB(t, 1, 1)
            local sw = hueW / hues + 1
            Rect(hueX + (i - 1) * (hueW / hues), hueY, sw, hueH,
                 Color3.new(r, g, b), 63, 0, a)
        end

        local hueCx = hueX + hueW * self._h
        Rect(hueCx - 1.5, hueY - 2, 3, hueH + 4, th.Text, 66, 1.5, a)
        Rect(hueCx - 2.5, hueY - 2, 5, hueH + 4, Color3.new(0, 0, 0), 66, 2.5, 0.5 * a)

        local prevY = hueY + hueH + 8
        local prevH = 22
        local previewX = px + padX
        local previewW = 42

        Rect(previewX, prevY, previewW, prevH, self.Value, 63, 5, self._alpha)

        local hexX = previewX + previewW + 8
        local hexY = prevY
        local hexW = pw - padX - hexX + px
        local hexH = prevH
        local hexFocused = Focus.Field == self._hexFocus
        Rect(hexX, hexY, hexW, hexH, th.PanelHi, 63, 5, 0.82 * a)
        Stroke(hexX, hexY, hexW, hexH, hexFocused and th.Accent or th.Stroke, 64, 5,
               (hexFocused and 0.9 or 0.5) * a)

        local hexValue = self._hexFocus.Value
        local textX = hexX + 7
        local availW = hexW - 14
        local charWidth = Layout.SmallSize * 0.50
        local fit = math.max(1, math.floor(availW / charWidth))
        local caret = math.max(0, math.min(self._hexFocus.Caret or #hexValue, #hexValue))
        local scroll = hexFocused and caret > fit and caret - fit or 0
        local visible = string.sub(hexValue, scroll + 1, math.min(#hexValue, scroll + fit))

        if hexFocused then

            for index = 1, #visible do
                Text(string.sub(visible, index, index),
                     textX + (index - 1) * charWidth,
                     TextMidY(hexY, hexH, Layout.SmallSize),
                     th.Text, Layout.SmallSize, Fonts.UI, 65, 0.95 * a)
            end
        else
            Text(visible, textX, TextMidY(hexY, hexH, Layout.SmallSize),
                 th.Text, Layout.SmallSize, Fonts.System, 65, 0.95 * a, availW)
        end

        if hexFocused then
            self._hexCaretAnim = self._hexCaretAnim - State.Delta * 1.6
            if self._hexCaretAnim < 0 then self._hexCaretAnim = 1 end
            local caretX = textX + math.min(math.max(caret - scroll, 0), #visible) * charWidth
            Rect(caretX, hexY + 4, 1, hexH - 8, th.Text, 66, 0,
                 (self._hexCaretAnim > 0.5 and 1 or 0.2) * a)
            self._hexFocus.CharWidth = charWidth
            self._hexFocus.EditX = textX
            self._hexFocus.Scroll = scroll
        end
        self._hexX, self._hexY, self._hexW, self._hexH = hexX, hexY, hexW, hexH

        local alphaY = prevY + prevH + 6
        local alphaX = px + padX
        local alphaW = pw - padX * 2
        local alphaH = 6

        Rect(alphaX, alphaY, alphaW, alphaH, th.Track, 63, 2, 0.5 * a)

        local baseColor = Color3.new(1, 1, 1)
        GradientRect(alphaX, alphaY, alphaW * self._alpha, alphaH,
                     Color3.new(1, 1, 1), self.Value, 64, a, 16)

        local alphaCx = alphaX + alphaW * self._alpha
        Rect(alphaCx - 1.5, alphaY - 2, 3, alphaH + 4, th.Text, 66, 1.5, a)
        Rect(alphaCx - 2.5, alphaY - 2, 5, alphaH + 4, Color3.new(0, 0, 0), 66, 2.5, 0.5 * a)

        Text(string.format("%d%%", math.floor(self._alpha * 100 + 0.5)),
             alphaX + alphaW - 30, alphaY + 8,
             th.TextDim, Layout.TinySize, Fonts.Monospace, 65, 0.8)

        self._panelX = px
        self._panelY = py
        self._panelW = pw
        self._panelH = pph
        self._svX, self._svY, self._svW, self._svH = svX, svY, svW, svH
        self._hueX, self._hueY, self._hueW, self._hueH = hueX, hueY, hueW, hueH
        self._alphaX, self._alphaY, self._alphaW, self._alphaH = alphaX, alphaY, alphaW, alphaH
    end

    function self:Input(x, y, w)
        if not self.Enabled then return end
        local h = 16
        local swatchW = 24
        local swatchX = x + w - swatchW
        local swatchY = y + (self.Height - h) / 2

        if MouseIn(swatchX, swatchY, swatchW, h) and Input.Click then
            Input.Click = false
            local opening = not self._open
            if State.Popup and State.Popup ~= self and State.Popup.Kind == "ColorPicker" then
                State.Popup._open = false
                State.Popup._svDrag = false
                State.Popup._hueDrag = false
                State.Popup._alphaDrag = false
                if Focus.Field == State.Popup._hexFocus then ClearFocus() end
            end
            self._open = opening
            State.Popup = opening and self or nil
        end

        if not self._open then return end

        local px, py, pw = self._panelX, self._panelY, self._panelW
        if not px then return end

        if self._svX then
            local inside = MouseIn(self._svX, self._svY, self._svW, self._svH)
            if inside and Input.Click then
                self._svDrag = true
            end
            if not Input.Down then self._svDrag = false end
            if self._svDrag and Input.Down then
                local s = Clamp((Input.X - self._svX) / self._svW, 0, 1)
                local v = 1 - Clamp((Input.Y - self._svY) / self._svH, 0, 1)
                self._s, self._v = s, v
                emit()
            end
        end

        if self._hueX then
            local inside = MouseIn(self._hueX, self._hueY, self._hueW, self._hueH)
            if (inside and Input.Click) or self._hueDrag then
                if Input.Click then self._hueDrag = true end
                if not Input.Down then
                    self._hueDrag = false
                else
                    local hh = Clamp((Input.X - self._hueX) / self._hueW, 0, 1)
                    self._h = hh
                    emit()
                end
            end
        end

        if self._hexX then
            local hexHover = MouseIn(self._hexX, self._hexY, self._hexW, self._hexH)
            if Input.Click and hexHover then
                self._hexFocus.Value = colorToHex(self.Value)
                self._hexFocus.OnCommit = function(v)
                    local parsed = parseHex(v)
                    if parsed then
                        self:SetValue(parsed)
                    else
                        self._hexFocus.Value = colorToHex(self.Value)
                        self._hexFocus.Caret = #self._hexFocus.Value
                    end
                end
                self._hexFocus.OnBlur = function()
                    local parsed = parseHex(self._hexFocus.Value)
                    if parsed then self:SetValue(parsed) end
                    self._hexFocus.Value = colorToHex(self.Value)
                    self._hexFocus.Caret = #self._hexFocus.Value
                end
                SetFocus(self._hexFocus)
                local cw = self._hexFocus.CharWidth or (Layout.SmallSize * 0.56)
                self._hexFocus.Caret = math.min(#self._hexFocus.Value,
                    math.max(0, math.floor((Input.X - (self._hexFocus.EditX or self._hexX + 7)) / cw + 0.5)))
                self._hexFocus.Anchor = self._hexFocus.Caret
                Input.Click = false
                return
            end
        end

        if self._alphaX then
            local inside = MouseIn(self._alphaX, self._alphaY, self._alphaW, self._alphaH + 6)
            if (inside and Input.Click) or self._alphaDrag then
                if Input.Click then self._alphaDrag = true end
                if not Input.Down then
                    self._alphaDrag = false
                else
                    local aa = Clamp((Input.X - self._alphaX) / self._alphaW, 0, 1)
                    self._alpha = aa
                    emit()
                end
            end
        end

        if Input.Click and not MouseIn(px, py, pw, self._panelH or 200)
                        and not MouseIn(swatchX, swatchY, swatchW, h) then
            self._open = false
            if State.Popup == self then State.Popup = nil end
            if Focus.Field == self._hexFocus then ClearFocus() end
        end
    end

    function self:PopupInput()
        if not self.Enabled or not self._open then return false end
        local px, py, pw = self._panelX, self._panelY, self._panelW
        if not px then return false end

        if self._svX then
            local inside = MouseIn(self._svX, self._svY, self._svW, self._svH)
            if inside and Input.Click then self._svDrag = true; Input.Click = false end
            if not Input.Down then self._svDrag = false end
            if self._svDrag and Input.Down then
                self._s = Clamp((Input.X - self._svX) / self._svW, 0, 1)
                self._v = 1 - Clamp((Input.Y - self._svY) / self._svH, 0, 1)
                emit()
                return true
            end
        end

        if self._hueX then
            local inside = MouseIn(self._hueX, self._hueY, self._hueW, self._hueH)
            if inside and Input.Click then self._hueDrag = true; Input.Click = false end
            if not Input.Down then self._hueDrag = false end
            if self._hueDrag and Input.Down then
                self._h = Clamp((Input.X - self._hueX) / self._hueW, 0, 1)
                emit()
                return true
            end
        end

        if self._hexX and Input.Click and MouseIn(self._hexX, self._hexY, self._hexW, self._hexH) then
            self._hexFocus.Value = colorToHex(self.Value)
            self._hexFocus.OnCommit = function(v)
                local parsed = parseHex(v)
                if parsed then self:SetValue(parsed)
                else self._hexFocus.Value = colorToHex(self.Value); self._hexFocus.Caret = #self._hexFocus.Value end
            end
            self._hexFocus.OnBlur = function()
                local parsed = parseHex(self._hexFocus.Value)
                if parsed then self:SetValue(parsed) end
                self._hexFocus.Value = colorToHex(self.Value)
                self._hexFocus.Caret = #self._hexFocus.Value
            end
            SetFocus(self._hexFocus)
            local cw = self._hexFocus.CharWidth or (Layout.SmallSize * 0.50)
            local editX = self._hexFocus.EditX or (self._hexX + 7)
            local scroll = self._hexFocus.Scroll or 0
            self._hexFocus.Caret = math.min(#self._hexFocus.Value,
                math.max(0, scroll + math.floor((Input.X - editX) / cw + 0.5)))
            self._hexFocus.Anchor = self._hexFocus.Caret
            Input.Click = false
            return true
        end

        if self._alphaX then
            local inside = MouseIn(self._alphaX, self._alphaY, self._alphaW, self._alphaH + 6)
            if inside and Input.Click then self._alphaDrag = true; Input.Click = false end
            if not Input.Down then self._alphaDrag = false end
            if self._alphaDrag and Input.Down then
                self._alpha = Clamp((Input.X - self._alphaX) / self._alphaW, 0, 1)
                emit()
                return true
            end
        end

        if Input.Click and not MouseIn(px, py, pw, self._panelH or 200) then
            self._open = false
            if State.Popup == self then State.Popup = nil end
            if Focus.Field == self._hexFocus then ClearFocus() end
        end
        return MouseIn(px, py, pw, self._panelH or 200)
    end

    return self
end)

local function GetContentRevealUnits(tab)
    if not tab then return 0 end
    local units = 0
    local i = 1
    while i <= #(tab.Rows or {}) do
        local row = tab.Rows[i]
        if not row.Hidden then
            if IsSection(row) and tab.Rows[i + 1] and not tab.Rows[i + 1].Hidden and IsSection(tab.Rows[i + 1]) then
                units = units + 1
                i = i + 2
            else
                units = units + 1
                i = i + 1
            end
        else
            i = i + 1
        end
    end
    return units
end

local function BuildContentLayout(tab, viewportTop, halfW)
    local items = {}
    local leftY = viewportTop
    local rightY = viewportTop
    local sectionIndex = 0
    local revealIndex = 0
    local i = 1

    while i <= #(tab.Rows or {}) do
        local row = tab.Rows[i]
        if row.Hidden then
            i = i + 1
        elseif IsSection(row) then
            sectionIndex = sectionIndex + 1
            revealIndex = revealIndex + 1

            local h = MeasureSection(row, halfW)
            local useLeft
            if row.Column == "left" then
                useLeft = true
            elseif row.Column == "right" then
                useLeft = false
            else
                useLeft = (sectionIndex % 2) == 1
            end
            local x = useLeft and Geometry.InnerX or (Geometry.InnerX + halfW + Layout.SectionColumnGap)
            local y = useLeft and leftY or rightY

            row._layoutX = x
            row._layoutY = y
            row._layoutW = halfW
            row._layoutH = h

            items[#items + 1] = {
                row = row,
                x = x,
                y = y,
                w = halfW,
                h = h,
                reveal = revealIndex,
                kind = "section",
            }

            if useLeft then
                leftY = y + h + Layout.SectionGap
            else
                rightY = y + h + Layout.SectionGap
            end
            i = i + 1
        else

            local y = math.max(leftY, rightY)
            local h
            if getmetatable(row) == InlineRow then
                h = 0
                for _, ctrl in ipairs(row.Cells or {}) do
                    if not ctrl.Hidden then
                        h = math.max(h, ctrl.Height or Layout.RowHeight)
                    end
                end
                h = h > 0 and h or Layout.RowHeight
            else
                h = row.Height or Layout.RowHeight
            end

            revealIndex = revealIndex + 1
            items[#items + 1] = {
                row = row,
                x = Geometry.InnerX,
                y = y,
                w = Geometry.InnerW,
                h = h,
                reveal = revealIndex,
                kind = "row",
            }

            local nextY = y + h + Layout.RowGapY
            leftY = nextY
            rightY = nextY
            i = i + 1
        end
    end

    return items, math.max(leftY, rightY) - viewportTop
end

local TabPageTransition = { Index = 1, Time = 0.38, Duration = 0.38 }

local function PageReveal(progress)
    progress = Clamp(progress, 0, 1)
    return 1 - (1 - progress) * (1 - progress) * (1 - progress)
end

local function DrawContent()
    local tab = State.Tabs[State.ActiveIndex]
    if not tab then return end

    if TabPageTransition.Index ~= State.ActiveIndex then
        TabPageTransition.Index = State.ActiveIndex
        TabPageTransition.Time = 0
    end
    TabPageTransition.Time = math.min(TabPageTransition.Duration, TabPageTransition.Time + State.Delta)
    local pageProgress = TabPageTransition.Time / TabPageTransition.Duration
    local pageBaseAlpha = FrameAlpha
    FrameAlpha = pageBaseAlpha * (0.22 + 0.78 * PageReveal(pageProgress))

    FrameAlpha = pageBaseAlpha
    local titleY = Geometry.ContentY + 17
    local headerH = ContentHeaderHeight(tab)
    if Input.Click and not State.Drag and not State.Resize and MouseIn(Geometry.ContentX + Layout.ContentPadX, Geometry.ContentY + 4, Geometry.ContentW - Layout.ContentPadX * 2, headerH - 6) then
        BeginDrag()
        Input.Click = false
    end
    local headerWidth = math.max(40, Geometry.ContentW - Layout.ContentPadX * 2)
    local titleLines = #WrapHeaderLines(tab.Name, headerWidth, 21, Fonts.SystemBold)
    HeaderText(tab.Name, Geometry.ContentX + Layout.ContentPadX, titleY,
               headerWidth, 21, Fonts.SystemBold, State.Theme.Text, 60, 1, 4)
    if tab.Subtitle and tab.Subtitle ~= "" then
        HeaderText(tab.Subtitle, Geometry.ContentX + Layout.ContentPadX, titleY + titleLines * 25 + 4,
                   headerWidth, 14, Fonts.System, State.Theme.TextDim, 60, 1, 4)
    end

    Line(
        Geometry.ContentX + Layout.ContentPadX,
        Geometry.ContentY + headerH - 7,
        Geometry.ContentX + Geometry.ContentW - Layout.ContentPadX,
        Geometry.ContentY + headerH - 7,
        mix(State.Theme.Divider, State.Theme.Accent, 0.45), 60, 1.5, 0.88)

    local viewportTop = Geometry.ContentY + headerH + Layout.ContentPadY
    local viewportH = Geometry.ContentH - headerH - Layout.ContentPadY * 2
    local halfW = math.floor((Geometry.InnerW - Layout.SectionColumnGap) / 2)

    local items, contentH = BuildContentLayout(tab, viewportTop, halfW)
    tab.MaxScroll = math.max(0, contentH - viewportH)
    if tab._SearchTarget then
        for _, item in ipairs(items) do
            if item.row == tab._SearchTarget then
                tab.ScrollTo = Clamp(item.y - viewportTop, 0, tab.MaxScroll)
                tab.Scroll = tab.ScrollTo
                break
            end
        end
        tab._SearchTarget = nil
    end
    TickScroll(tab, State.Delta)
    HandleWheel(tab)

    local clipTop = viewportTop
    local clipBottom = Geometry.ContentY + Geometry.ContentH - 12
    ActiveClipTop = clipTop
    ActiveClipBottom = clipBottom
    for itemIndex, item in ipairs(items) do
        local revealProgress = Clamp((pageProgress - (itemIndex - 1) * 0.020) / 0.72, 0, 1)
        FrameAlpha = pageBaseAlpha * PageReveal(revealProgress)
        local row = item.row
        local y = item.y - tab.Scroll
        local h = item.h
        local revealThis = item.reveal <= StartupRevealCount(#items)

        if revealThis then
            if item.kind == "section" then
                if y + h >= clipTop and y <= clipBottom then
                    DrawSection(row, item.x, y, item.w)
                end
            else

                if y + h >= clipTop and y <= clipBottom then
                    DrawRow(row, item.x, y, item.w)
                end
            end
        end
    end

    FrameAlpha = pageBaseAlpha
    DrawScrollbar(tab)
    ActiveClipTop = nil
    ActiveClipBottom = nil
end

local function UpdateDropdownScrollbarInput()
    local dropdown = State.ActiveDropdown
    if not dropdown or not dropdown._open then
        if dropdown then dropdown._scrollDrag = false end
        State.ActiveDropdown = nil
        return false
    end

    local pg = dropdown._popupGeom
    if not pg or pg.MaxScroll <= 0 then
        dropdown._scrollDrag = false
        return false
    end

    local trackX, trackY = pg.TrackX, pg.TrackY
    local trackW, trackH = pg.TrackW, pg.TrackH
    local thumbH, travel = pg.ThumbH, pg.Travel
    local maxScroll = pg.MaxScroll
    local thumbY = trackY + travel * ((dropdown._listScrollTo or 0) / maxScroll)

    if dropdown._scrollDrag then
        if Input.Down then
            local newThumbY = Clamp(Input.Y - dropdown._scrollDragOffsetY,
                                    trackY, trackY + travel)
            local frac = (newThumbY - trackY) / math.max(1, travel)
            dropdown._listScrollTo = Clamp(frac * maxScroll, 0, maxScroll)
            dropdown._listScroll = dropdown._listScrollTo
            Input.Click = false
            return true
        else
            dropdown._scrollDrag = false
        end
    end

    if Input.Click and MouseIn(trackX - 3, thumbY - 2, trackW + 6, thumbH + 4) then
        dropdown._scrollDrag = true
        dropdown._scrollDragOffsetY = Input.Y - thumbY
        Input.Click = false
        return true
    end

    if Input.Click and MouseIn(trackX - 3, trackY, trackW + 6, trackH) then
        local centered = Clamp(Input.Y - thumbH / 2, trackY, trackY + travel)
        local frac = (centered - trackY) / math.max(1, travel)
        dropdown._listScrollTo = Clamp(frac * maxScroll, 0, maxScroll)
        dropdown._listScroll = dropdown._listScrollTo
        dropdown._scrollDrag = true
        dropdown._scrollDragOffsetY = thumbH / 2
        Input.Click = false
        return true
    end

    return false
end

local function InputContent()
    local tab = State.Tabs[State.ActiveIndex]
    if not tab then return end

    if State.Popup and State.Popup.Kind == "ColorPicker" and State.Popup.PopupInput then
        if State.Popup:PopupInput() then return end
    end

    if UpdateDropdownScrollbarInput() then return end

    UpdateContentScrollbarInput(tab)
    if ContentScrollbarDrag.Active then return end

    if not MouseIn(Geometry.ContentX, Geometry.ContentY,
                   Geometry.ContentW, Geometry.ContentH) then
        return
    end

    local headerH = ContentHeaderHeight(tab)
    local viewportTop = Geometry.ContentY + headerH + Layout.ContentPadY
    local halfW = math.floor((Geometry.InnerW - Layout.SectionColumnGap) / 2)
    local items = BuildContentLayout(tab, viewportTop, halfW)

    for _, item in ipairs(items) do
        local row = item.row
        local y = item.y - tab.Scroll
        local h = item.h

        local viewportBottom = Geometry.ContentY + Geometry.ContentH
        if item.kind == "section" then
            if y + h >= viewportTop and y <= viewportBottom then
                InputSection(row, item.x, y, item.w)
            end
        elseif y >= viewportTop and (y + h) <= viewportBottom then
            InputRow(row, item.x, y, item.w)
        end
    end

    if Input.Click and State.Popup then
        State.Popup = nil
    end
end

local function FindTab(name)
    for i, tab in ipairs(State.Tabs) do
        if tab.Name == name then return tab, i end
    end
    return nil, nil
end

local function SetActiveTab(index)
    if index >= 1 and index <= #State.Tabs then
        State.ActiveIndex = index
    end
end

local function SetActiveTabByName(name)
    local _, idx = FindTab(name)
    if idx then State.ActiveIndex = idx end
end

local ThemeTween = {
    Active = false,
    From = nil,
    To = nil,
    T = 0,
    Duration = 0.35,
}

local function IsColor3(value)
    if value == nil then return false end

    local okR, r = pcall(function() return value.R end)
    local okG, g = pcall(function() return value.G end)
    local okB, b = pcall(function() return value.B end)

    return okR and okG and okB
        and type(r) == "number"
        and type(g) == "number"
        and type(b) == "number"
end

local function SwitchTheme(index)
    if index == State.ThemeIndex then return end
    local new = Themes[index]
    if not new then return end

    if State.NoAnim then
        State.Theme = new
        State.ThemeIndex = index
        return
    end

    local from = {}
    for k, v in pairs(State.Theme) do
        if IsColor3(v) then from[k] = v end
    end

    ThemeTween.Active = true
    ThemeTween.From = from
    ThemeTween.To = new
    ThemeTween.T = 0
    State.ThemeIndex = index
end

local function TickTheme(dt)
    if not ThemeTween.Active then return end

    ThemeTween.T = ThemeTween.T + dt / ThemeTween.Duration
    if ThemeTween.T >= 1 then ThemeTween.T = 1 end

    local t = ThemeTween.T

    t = 1 - (1 - t) ^ 3

    local from = ThemeTween.From
    local to   = ThemeTween.To
    local result = {}
    for k, v in pairs(to) do
        if IsColor3(v) and from[k] then
            result[k] = mix(from[k], v, t)
        else
            result[k] = v
        end
    end
    State.Theme = result

    if ThemeTween.T >= 1 then
        ThemeTween.Active = false
        State.Theme = to
    end
end

local function SetThemeByName(name)
    for i, th in ipairs(Themes) do
        if th.Name == name then
            SwitchTheme(i)
            return true
        end
    end
    return false
end

local function NextTheme()
    local nxt = State.ThemeIndex + 1
    if nxt > #Themes then nxt = 1 end
    SwitchTheme(nxt)
end

local Notification = {}
Notification.__index = Notification

local NoteColors = {
    info    = { accent = "Accent",   icon = "info",    label = "INFO"    },
    success = { accent = "Success",  icon = "success", label = "SUCCESS" },
    warning = { accent = "Warning",  icon = "warning", label = "WARNING" },
    error   = { accent = "Danger",   icon = "error",   label = "ERROR"   },
}

local function NormalizeNotificationPosition(value)
    local p = string.lower(tostring(value or "top_left"))
    p = string.gsub(p, "%s+", "_")
    p = string.gsub(p, "-", "_")
    if p == "topleft" then p = "top_left" end
    if p == "topright" then p = "top_right" end
    if p == "bottomleft" then p = "bottom_left" end
    if p == "bottomright" then p = "bottom_right" end

    if p ~= "top_left" and p ~= "top_right"
       and p ~= "bottom_left" and p ~= "bottom_right" then
        p = "top_left"
    end
    return p
end

local function Notify(opts)
    opts = opts or {}
    local logoSource = opts.Logo or opts.logo
    local entry = setmetatable({
        Title = tostring(opts.Title or opts.title or "Notice"),
        Content = tostring(opts.Content or opts.content or ""),
        Type = string.lower(tostring(opts.Type or opts.type or "info")),
        Duration = math.max(0.5, tonumber(opts.Duration or opts.duration) or 4),
        Fade = 0, Slide = 0, Life = 0,
        TargetLife = math.max(0.5, tonumber(opts.Duration or opts.duration) or 4),
        Done = false,
        Logo = logoSource and LoadPicture(logoSource, "notification_logo") or nil,
    }, Notification)
    State.Notifications[#State.Notifications + 1] = entry
    return entry
end

local function TickNotifications(dt)
    local list = State.Notifications
    local i = 1

    while i <= #list do
        local n = list[i]
        n.Life = n.Life + dt

        local targetFade, targetSlide
        local fadeDuration = 0.42

        if n.Life < 0.22 then
            local t = n.Life / 0.22
            targetFade = t
            targetSlide = (1 - t) * 34
        elseif n.Life <= n.TargetLife then
            targetFade = 1
            targetSlide = 0
        else
            local fadeT = Clamp((n.Life - n.TargetLife) / fadeDuration, 0, 1)
            targetFade = 1 - fadeT
            targetSlide = fadeT * 26
        end

        n.Fade  = Approach(n.Fade, targetFade, 22, dt)
        n.Slide = Approach(n.Slide, targetSlide, 20, dt)

        if n.Life >= n.TargetLife + fadeDuration and n.Fade < 0.02 then
            n.Done = true
        end

        if n.Done then
            HidePicture(n.Logo)
            if n.Logo and n.Logo.Image then PoolMade.Lib.Kill(n.Logo.Image); n.Logo.Image = nil end
            table.remove(list, i)
        else
            i = i + 1
        end
    end
end

local function NotificationLines(value, width, size, font)
    local lines = {}
    local charW = size * (FontMetrics[font] or 0.5)
    local limit = math.max(1, math.floor(width / charW))
    for paragraph in (tostring(value) .. "\\n"):gmatch("(.-)\\n") do
        local current = ""
        for word in paragraph:gmatch("%S+") do
            while #word > limit do
                if current ~= "" then lines[#lines + 1] = current; current = "" end
                lines[#lines + 1] = word:sub(1, limit)
                word = word:sub(limit + 1)
            end
            if word ~= "" then
                if current == "" then current = word
                elseif #current + #word + 1 <= limit then current = current .. " " .. word
                else lines[#lines + 1] = current; current = word end
            end
        end
        lines[#lines + 1] = current
    end
    return lines
end

local function DrawNotifications()
    local th = State.Theme
    local vp = Camera.ViewportSize
    local pos = NormalizeNotificationPosition(State.NotificationPosition)
    local notW, gap = 350, 10
    local marginX, marginY, cut = 18, 18, 19
    local fromTop = pos == "top_left" or pos == "top_right"
    local fromLeft = pos == "top_left" or pos == "bottom_left"
    local stackOffset = 0
    for _, n in ipairs(State.Notifications) do
        local hasLogo = n.Logo ~= nil
        local textW = hasLogo and (notW - 139) or (notW - 72)
        local titleLines = NotificationLines(n.Title, textW, 15, Fonts.SystemBold)
        local contentLines = n.Content ~= "" and NotificationLines(n.Content, textW, 11, Fonts.System) or {}
        local titleH, contentH = #titleLines * 18, #contentLines * 15
        local notH = math.max(90, 18 + titleH + (contentH > 0 and 7 + contentH or 0) + 18)
        local a = n.Fade
        if a > 0.005 then
            local ny = fromTop and (marginY + stackOffset) or (vp.Y - marginY - notH - stackOffset)
            local baseX = fromLeft and marginX or (vp.X - marginX - notW)
            local nx = baseX + (fromLeft and -1 or 1) * n.Slide
            local colors = NoteColors[n.Type] or NoteColors.info
            local accent = th[colors.accent] or th.Accent
            local bg = rgb(23, 23, 34)
            local x2, y2 = nx + notW, ny + notH
            local fillAlpha = 0.97 * a
            Rect(nx + cut, ny, notW - cut, cut, bg, 371, 0, fillAlpha)
            Rect(nx, ny + cut, notW, notH - 2 * cut, bg, 371, 0, fillAlpha)
            Rect(nx, y2 - cut, notW - cut, cut, bg, 371, 0, fillAlpha)
            Triangle(nx, ny + cut, nx + cut, ny, nx + cut, ny + cut, bg, 371, fillAlpha)
            Triangle(x2 - cut, y2 - cut, x2, y2 - cut, x2 - cut, y2, bg, 371, fillAlpha)
            local outline = th.Accent
            Line(nx + cut, ny, x2, ny, outline, 373, 1.5, a)
            Line(x2, ny, x2, y2 - cut, outline, 373, 1.5, a)
            Line(x2, y2 - cut, x2 - cut, y2, outline, 373, 1.5, a)
            Line(x2 - cut, y2, nx, y2, outline, 373, 1.5, a)
            Line(nx, y2, nx, ny + cut, outline, 373, 1.5, a)
            Line(nx, ny + cut, nx + cut, ny, outline, 373, 1.5, a)
            local cx, cy = nx + 30, ny + 35
            Circle(cx, cy, 13, mix(bg, accent, 0.17), 374, true, 1, 28, a)
            DrawIconByName(colors.icon, cx - 9, cy - 9, 18, accent, 376, a)
            local textX = nx + 53
            local titleY = ny + 18
            for i, line in ipairs(titleLines) do
                Text(line, textX, titleY + (i - 1) * 18, th.Text, 15, Fonts.SystemBold, 378, a)
            end
            if #contentLines > 0 then
                local contentY = titleY + titleH + 7
                for i, line in ipairs(contentLines) do
                    Text(line, textX, contentY + (i - 1) * 15, th.TextDim, 11, Fonts.System, 378, 0.90 * a)
                end
            end
            if hasLogo then
                local dividerX = x2 - 94
                Line(dividerX, ny + 16, dividerX, y2 - 16, th.Divider, 375, 1, 0.85 * a)
                local logoSize = 52
                local logoX, logoY = x2 - 73, ny + (notH - logoSize) / 2
                DrawPicture(n.Logo, logoX, logoY, logoSize, logoSize, Layer(377), a, 6)
            end
        end
        stackOffset = stackOffset + notH + gap
    end
end

local Tooltip = {
    Current = nil,
    X = 0, Y = 0,
    Fade = 0,
    LastSetAt = 0,
    Delay = 0.35,
    Hovered = false,
}

WantTooltip = function(text)
    if not text or text == "" then return end
    Tooltip.Hovered = true
    if Tooltip.Current ~= text then
        Tooltip.Current = text
        Tooltip.LastSetAt = os.clock()
    end
    Tooltip.X = Input.X
    Tooltip.Y = Input.Y
end

local function TickTooltip(dt)
    local target = 0
    if Tooltip.Hovered and Tooltip.Current and (os.clock() - Tooltip.LastSetAt) >= Tooltip.Delay then
        target = 1
    end

    Tooltip.Fade = Approach(Tooltip.Fade, target, 18, dt)

    if not Tooltip.Hovered and Tooltip.Fade < 0.02 then
        Tooltip.Current = nil
    end
    Tooltip.Hovered = false
end

local function DrawTooltip()
    if Tooltip.Fade < 0.02 or not Tooltip.Current then return end

    local th = State.Theme
    local a = Tooltip.Fade

    local text = Tooltip.Current
    local textW = TextWidth(text, 12, Fonts.System)
    local padX = 10
    local padY = 6
    local boxW = textW + padX * 2
    local boxH = 12 + padY * 2 + 4

    local vp = Camera.ViewportSize
    local tx = Tooltip.X + 14
    local ty = Tooltip.Y + 18

    if tx + boxW > vp.X - 8 then
        tx = Tooltip.X - boxW - 8
    end
    if ty + boxH > vp.Y - 8 then
        ty = Tooltip.Y - boxH - 8
    end

    Rect(tx + 2, ty + 3, boxW, boxH, Color3.new(0, 0, 0), 300, 6, 0.28 * a)
    Rect(tx, ty, boxW, boxH, th.Base, 301, 6, 0.98 * a)
    Stroke(tx, ty, boxW, boxH, th.Stroke, 302, 6, 0.6 * a)

    Text(text, tx + padX, ty + padY + 1,
         th.Text, 12, Fonts.System, 303, a)
end

local function ClearTooltip()
    Tooltip.Current = nil
    Tooltip.Fade = 0
end

local HUDBox = {}
HUDBox.__index = HUDBox

local HUDBoxes = {}

function HUDBox.new(opts)
    opts = opts or {}

    local visible = opts.Visible
    if visible == nil then visible = opts.visible end
    if visible == nil then visible = opts.SetVisible end
    if visible == nil then visible = opts.setVisible end
    if visible == nil then visible = true end

    local dynamic = opts.Dynamic
    if dynamic == nil then dynamic = opts.dynamic end
    dynamic = dynamic and true or false

    local dynamicWidth = opts.DynamicWidth
    if dynamicWidth == nil then dynamicWidth = opts.dynamicWidth end
    if dynamicWidth == nil then dynamicWidth = dynamic end
    if type(dynamicWidth) == "string" and string.lower(dynamicWidth) == "expand" then
        dynamicWidth = "expand"
    else
        dynamicWidth = dynamicWidth and true or false
    end

    local dynamicHeight = opts.DynamicHeight
    if dynamicHeight == nil then dynamicHeight = opts.dynamicHeight end
    if dynamicHeight == nil then dynamicHeight = dynamic end
    dynamicHeight = dynamicHeight and true or false

    local explicitW = tonumber(opts.Width or opts.width or opts.W or opts.w)
    local explicitH = tonumber(opts.Height or opts.height or opts.H or opts.h)

    local self = setmetatable({
        Title       = tostring(opts.Title or opts.title or "Overlay"),
        X           = tonumber(opts.X or opts.x) or 40,
        Y           = tonumber(opts.Y or opts.y) or 40,
        W           = math.max(100, explicitW or 200),
        BaseW       = math.max(100, explicitW or 200),
        H           = explicitH,
        Lines       = {},
        Visible     = visible and true or false,
        Dynamic     = dynamic,
        DynamicWidth  = dynamicWidth,
        DynamicHeight = dynamicHeight,
        MaxLines    = Clamp(math.floor(tonumber(opts.MaxLines or opts.maxLines) or 100), 1, 100),
        MaxChars    = Clamp(math.floor(tonumber(opts.MaxWidth or opts.maxWidth or opts.MaxChars or opts.maxChars) or 50), 8, 50),
        Font        = Fonts.ResolveOverlay(opts.Font or opts.font, Fonts.SystemBold),
        HeaderFont  = Fonts.ResolveOverlay(opts.HeaderFont or opts.headerFont, Fonts.SystemBold),
        FontSize    = Clamp(tonumber(opts.FontSize or opts.fontSize) or 10, 7, 18),
        HeaderSize  = Clamp(tonumber(opts.HeaderSize or opts.headerSize) or 12, 8, 20),
        LineSpacing = Clamp(tonumber(opts.LineSpacing or opts.lineSpacing) or 12, 0, 24),
        MinLineHeight = Clamp(tonumber(opts.LineHeight or opts.lineHeight or opts.MinLineHeight or opts.minLineHeight) or 25, 8, 48),
        Pin         = false,
        _drag       = nil,
        _hover      = 0,
        _reveal     = 0,
        _revealOrder = #HUDBoxes + 1,
        _layoutDirty = true,
        _layoutW = nil,
        _layoutH = nil,
        _lineH = nil,
    }, HUDBox)

    if self.H then self.H = math.max(48, self.H) end

    HUDBoxes[#HUDBoxes + 1] = self
    return self
end

function HUDBox:SetVisible(v)
    local nextVisible = v and true or false
    if nextVisible and not self.Visible then
        self._reveal = 0
        local now = State.OverlayRevealTime or 0
        local queued = math.max(now + 0.5, State.OverlayNextRevealAt or 0)
        self._revealAt = queued
        State.OverlayNextRevealAt = queued + 0.5
    end
    self.Visible = nextVisible
    if not self.Visible then self._drag = nil end
    return self
end

function HUDBox:GetVisible()
    return self.Visible
end

function HUDBox:Toggle()
    return self:SetVisible(not self.Visible)
end

function HUDBox:SetTitle(title)
    self.Title = tostring(title or "")
    self._layoutDirty = true
    return self
end

function HUDBox:SetSize(width, height)
    if width ~= nil then
        self.W = math.max(100, tonumber(width) or self.W)
        self.BaseW = self.W
    end
    if height ~= nil then self.H = math.max(48, tonumber(height) or (self.H or 48)) end
    self._layoutDirty = true
    return self
end

function HUDBox:SetDynamic(value)
    local enabled = value and true or false
    self.Dynamic = enabled
    self.DynamicWidth = enabled
    self.DynamicHeight = enabled
    self._layoutDirty = true
    return self
end

function HUDBox:SetDynamicWidth(value)
    if type(value) == "string" and string.lower(value) == "expand" then
        self.DynamicWidth = "expand"
    else
        self.DynamicWidth = value and true or false
    end
    self._layoutDirty = true
    return self
end

function HUDBox:SetDynamicHeight(value)
    self.DynamicHeight = value and true or false
    self._layoutDirty = true
    return self
end

function HUDBox:SetFont(font)
    self.Font = Fonts.ResolveOverlay(font, self.Font)
    self._layoutDirty = true
    return self
end

function HUDBox:SetHeaderFont(font)
    self.HeaderFont = Fonts.ResolveOverlay(font, self.HeaderFont)
    self._layoutDirty = true
    return self
end

function HUDBox:SetPosition(x, y)
    if x ~= nil then self.X = tonumber(x) or self.X end
    if y ~= nil then self.Y = tonumber(y) or self.Y end
    return self
end

function HUDBox:Line(text, color, font)

    if type(text) == "table" and not text.Text and not text.text then
        local segments = {}
        for _, part in ipairs(text) do
            if type(part) == "table" then
                segments[#segments + 1] = {
                    Text = tostring(part.Text or part.text or part[1] or ""),
                    Color = part.Color or part.color or part[2],
                    Font = Fonts.ResolveOverlay(part.Font or part.font or part[3], nil),
                    Size = tonumber(part.Size or part.size or part[4]),
                }
            else
                segments[#segments + 1] = {
                    Text = tostring(part),
                    Color = color,
                    Font = Fonts.ResolveOverlay(font, nil),
                }
            end
        end
        self.Lines[#self.Lines + 1] = {
            Segments = segments,
            Color = color,
            Font = Fonts.ResolveOverlay(font, self.Font),
        }
    else
        local tableFont = type(text) == "table" and (text.Font or text.font or text[3]) or nil
        local tableSize = type(text) == "table" and (text.Size or text.size or text[4]) or nil
        self.Lines[#self.Lines + 1] = {
            Text = tostring((type(text) == "table" and (text.Text or text.text or text[1])) or text or ""),
            Color = (type(text) == "table" and (text.Color or text.color or text[2])) or color,
            Font = Fonts.ResolveOverlay(tableFont or font, self.Font),
            Size = tonumber(tableSize),
        }
    end
    self._layoutDirty = true
    return self
end

function HUDBox:AddLine(text, color, font)
    return self:Line(text, color, font)
end

function HUDBox:SetLines(lines)
    self.Lines = {}
    for _, line in ipairs(lines or {}) do
        if type(line) == "table" and (line.Segments or line.segments) then
            self:Line(line.Segments or line.segments,
                      line.Color or line.color,
                      line.Font or line.font)
        elseif type(line) == "table" and (line.Text or line.text) then
            self:Line(line)
        elseif type(line) == "table" then
            self:Line(line)
        else
            self:Line(line)
        end
    end
    return self
end

function HUDBox:Clear()
    self.Lines = {}
    self._layoutDirty = true
    return self
end

local function DrawHUDBoxes()
    local th = State.Theme
    local previousAlpha = FrameAlpha
    FrameAlpha = 1

    for _, box in ipairs(HUDBoxes) do
        do
            local revealAt = box._revealAt
            if revealAt == nil then
                revealAt = math.max(0, (box._revealOrder + 1) * 0.5)
            end
            local revealTarget = (box.Visible and (State.OverlayRevealTime or 0) >= revealAt) and 1 or 0
            box._reveal = State.NoAnim and revealTarget
                or Approach(box._reveal or 0, revealTarget, 14, State.Delta)
            if math.abs((box._reveal or 0) - revealTarget) < 0.01 then box._reveal = revealTarget end

            local boxAlpha = box._reveal or 0
            FrameAlpha = boxAlpha

            local headerH = 34
            local padX = 8
            local contentPadY = 4
            local visibleCount = math.min(#box.Lines, box.MaxLines or 100)

            if box._layoutDirty or box._layoutW == nil or box._layoutH == nil then
                local widestLine = 0
                local tallestLine = box.FontSize or 10
                for i = 1, visibleCount do
                    local line = box.Lines[i]
                    local lineW = 0
                    local lineTall = box.FontSize or 10
                    if line.Segments then
                        for _, segment in ipairs(line.Segments) do
                            local font = segment.Font or line.Font or box.Font or Fonts.SystemBold
                            local size = segment.Size or box.FontSize or 10
                            lineW = lineW + TextWidth(tostring(segment.Text or ""), size, font)
                            lineTall = math.max(lineTall, size)
                        end
                    else
                        local font = line.Font or box.Font or Fonts.SystemBold
                        local size = line.Size or box.FontSize or 10
                        lineW = TextWidth(tostring(line.Text or ""), size, font)
                        lineTall = math.max(lineTall, size)
                    end
                    widestLine = math.max(widestLine, lineW)
                    tallestLine = math.max(tallestLine, lineTall)
                end

                local headerFont = box.HeaderFont or Fonts.SystemBold
                local headerSize = box.HeaderSize or 12
                local header = string.upper(tostring(box.Title or "OVERLAY"))
                local headerW = TextWidth(header, headerSize, headerFont)
                local maxChars = Clamp(box.MaxChars or 50, 8, 50)
                local charCapW = TextWidth(string.rep("M", maxChars),
                                           box.FontSize or 10,
                                           box.Font or Fonts.SystemBold) + padX * 2
                local naturalW = math.max(headerW + 20, widestLine + padX * 2)
                local dynamicW = Clamp(naturalW, 100, math.max(100, charCapW))
                local measuredW
                if box.DynamicWidth == "expand" then
                    measuredW = math.max(box.BaseW or box.W, dynamicW)
                elseif box.DynamicWidth then
                    measuredW = dynamicW
                else
                    measuredW = box.W
                end
                local lineH = math.max(box.MinLineHeight or 25, tallestLine + (box.LineSpacing or 12))
                local naturalH = headerH + contentPadY + math.max(1, visibleCount) * lineH + contentPadY
                local measuredH = box.DynamicHeight and naturalH
                    or (box.H and math.max(headerH + contentPadY * 2, box.H) or naturalH)

                box._layoutW = measuredW
                box._layoutH = measuredH
                box._lineH = lineH
                box._layoutDirty = false
                if box.DynamicWidth == true then box.W = measuredW end
            end

            local boxW = box._layoutW or box.W
            local totalH = box._layoutH or (headerH + 8)
            local lineH = box._lineH or math.max(box.MinLineHeight or 25, (box.FontSize or 10) + (box.LineSpacing or 12))
            local headerFont = box.HeaderFont or Fonts.SystemBold
            local headerSize = box.HeaderSize or 12
            local header = string.upper(tostring(box.Title or "OVERLAY"))

            local vp = Camera.ViewportSize
            box.X = math.max(6, math.min(box.X, math.max(6, vp.X - boxW - 6)))
            box.Y = math.max(6, math.min(box.Y, math.max(6, vp.Y - totalH - 6)))

            if box._drag then
                if Input.Down then
                    box.X = Input.X - box._drag.gx
                    box.Y = Input.Y - box._drag.gy
                else
                    box._drag = nil
                end
            end

            local hover = MouseIn(box.X, box.Y, boxW, totalH)
            box._hover = Approach(box._hover, hover and 1 or 0, 16, State.Delta)

            if box.Visible and boxAlpha > 0.95
               and hover and Input.Click and State.Open and State.Visible >= 0.50 then
                box._drag = { gx = Input.X - box.X, gy = Input.Y - box.Y }
                Input.Click = false
            end

            CutPanel(box.X, box.Y, boxW, totalH, 10, rgb(13, 16, 23), 351, 0.96)
            CutOutline(box.X, box.Y, boxW, totalH, 10, th.Accent, 352, 0.88, 1)

            local measuredHeaderW = TextWidth(header, headerSize, headerFont)
            Text(header,
                 box.X + (boxW - measuredHeaderW) / 2,
                 TextMidY(box.Y, headerH, headerSize) - 2,
                 th.Text, headerSize, headerFont, 354, 1,
                 math.max(1, boxW - 20))

            Line(box.X + 10, box.Y + headerH - 1,
                 box.X + boxW - 10, box.Y + headerH - 1,
                 th.Accent, 354, 1, 0.22)

            for i = 1, visibleCount do
                local line = box.Lines[i]
                local rowY = box.Y + headerH + contentPadY + (i - 1) * lineH
                if rowY + 8 <= box.Y + totalH - 5 then
                    local tx = box.X + padX
                    local maxRight = box.X + boxW - padX

                    if line.Segments then
                        for _, segment in ipairs(line.Segments) do
                            if tx >= maxRight then break end
                            local font = segment.Font or line.Font or box.Font or Fonts.SystemBold
                            local size = segment.Size or box.FontSize or 10
                            local room = maxRight - tx
                            local segmentText = TrimText(tostring(segment.Text or ""), room, size, font)
                            if segmentText ~= "" then
                                Text(segmentText, tx,
                                     TextMidY(rowY, lineH, size),
                                     segment.Color or line.Color or th.Text,
                                     size, font, 355, 0.96, room)
                                tx = tx + TextWidth(segmentText, size, font)
                            end
                        end
                    else
                        local font = line.Font or box.Font or Fonts.SystemBold
                        local size = line.Size or box.FontSize or 10
                        Text(line.Text or "", tx,
                             TextMidY(rowY, lineH, size),
                             line.Color or th.Text,
                             size, font, 355, 0.96,
                             maxRight - tx)
                    end
                end
            end
            if not box.Visible then box._drag = nil end
        end
    end

    FrameAlpha = previousAlpha
end

local function HUDBox_Remove(box)
    for i, b in ipairs(HUDBoxes) do
        if b == box then
            table.remove(HUDBoxes, i)
            return
        end
    end
end

local function TickVisibility(dt)
    local target = State.Open and 1 or 0
    if State.NoAnim then
        State.Visible = target
    else
        State.Visible = Approach(State.Visible, target, 16, dt)
        if math.abs(State.Visible - target) < 0.01 then
            State.Visible = target
        end
    end
    FrameAlpha = State.Visible
end

local function ToggleUI()
    State.Open = not State.Open
    if not State.Open then
        ClearFocus()
        CancelCapture()
        State.Popup = nil
        ClearTooltip()
    end
end

local LastHotkeyState = false

local function Render()

    State._kbCache = nil
    ReadInput()
    ReadKeys(State, Focus, Capture)
    State.TickKeybindCallbacks()

    local now = os.clock()
    State.Delta = math.min(now - State.LastTick, 1 / 20)
    State.LastTick = now
    State.Frame = State.Frame + 1
    TickPerformanceOverlay(State.Delta)

    UpdateCapture()

    TickFocus()

    if true then
        local key = string.lower(State.MenuKey)
        local hk = Keys[string.upper(key)]
        if hk and hk.Click then
            ToggleUI()
            hk.Click = false
        end
    end

    if true then
        EnsureWindowFitsTabs()
    end
    TickVisibility(State.Delta)
    TickTheme(State.Delta)
    if State.Entrance.Active then
        State.Entrance.Time = math.min(State.Entrance.Duration, State.Entrance.Time + State.Delta)
        if State.Entrance.Time >= State.Entrance.Duration then State.Entrance.Active = false end
    end
    if true then
        State.OverlayRevealTime = (State.OverlayRevealTime or 0) + State.Delta
    end

    if State.Visible < 0.005 then
        HidePicture(State.Logo)
        HidePicture(State.BackgroundImage)

        ResetPool()

        TickNotifications(State.Delta)
        DrawNotifications()
        UpdateKeybindOverlayInput()
        UpdatePerformanceOverlayInput()
        DrawKeybindOverlay()
        DrawPerformanceOverlay()

        DrawHUDBoxes()
        State.ApplyInputState(false)
        HideUnused()
        return
    end

    Geometry.Recalculate()

    TickRailOpen(State.Delta)
    TickDrag(State.Delta)
    TickResize()

    Geometry.Recalculate()

    ResetPool()
    Tooltip.Hovered = false

    UpdateKeybindOverlayInput()
    UpdatePerformanceOverlayInput()
    DrawKeybindOverlay()
    DrawPerformanceOverlay()
    DrawHUDBoxes()

    local entranceAlpha = 1
    if State.Entrance.Active then
        local t = math.min(1, State.Entrance.Time / State.Entrance.Duration)
        entranceAlpha = t * t * (3 - 2 * t)
    end
    FrameAlpha = entranceAlpha * State.Visible
    DrawFrame()
    DrawTabRail()
    DrawContent()
    FrameAlpha = State.Visible
    TickTooltip(State.Delta)

    if not State.Entrance.Active then InputContent() end

    TickNotifications(State.Delta)
    DrawNotifications()
    DrawTooltip()

    DrawResizeHandle()

    State.ApplyInputState(false)

    HideUnused()
end

local function IsBindHeld(bindName)
    if not bindName or bindName == "" then return false end

    for segment in string.gmatch(bindName, "[^+]+") do
        local seg = string.upper(segment)
        local key = Keys[seg]
        if not key or not key.Held then return false end
    end
    return true
end

local function IsBindClicked(bindName)
    if not bindName or bindName == "" then return false end

    local clickedAny = false
    for segment in string.gmatch(bindName, "[^+]+") do
        local seg = string.upper(segment)
        local key = Keys[seg]
        if not key or not key.Held then return false end
        if key.Click then clickedAny = true end
    end
    return clickedAny
end

local function CollectKeybinds()
    local cached = State._kbCache
    if cached then return cached end
    local out = {}
    local function walk(container, prefix)
        for _, row in ipairs(container.Rows or {}) do
            if getmetatable(row) == Section then
                walk(row, prefix .. row.Title .. "/")
            elseif getmetatable(row) == InlineRow then
                for _, ctrl in ipairs(row.Cells or {}) do
                    if ctrl.Kind == "Keybind" then
                        out[#out + 1] = { Path = prefix .. (ctrl.Title ~= "" and ctrl.Title or "Keybind"), Title = (ctrl.Title ~= "" and ctrl.Title or "Keybind"), Row = ctrl }
                    end
                end
            elseif row.Kind == "Keybind" then
                out[#out + 1] = { Path = prefix .. (row.Title ~= "" and row.Title or "Keybind"), Title = (row.Title ~= "" and row.Title or "Keybind"), Row = row }
            end
            if row.Accessories then
                for _, ctrl in ipairs(row.Accessories) do
                    if ctrl.Kind == "Keybind" then
                        local title = ctrl.Title ~= "" and ctrl.Title or (row.Title ~= "" and row.Title or "Keybind")
                        out[#out + 1] = { Path = prefix .. title, Title = title, Row = ctrl }
                    end
                end
            end
        end
    end
    for _, tab in ipairs(State.Tabs) do
        walk(tab, tab.Name .. "/")
    end
    State._kbCache = out
    return out
end

function State.TickKeybindCallbacks()
    local list = CollectKeybinds()
    for i = 1, #list do
        local row = list[i].Row
        if row and row.Enabled ~= false and row.Value and row.Value ~= "none" then
            Keys.Track(row.Value)

            local held = IsBindHeld(row.Value)
            local clicked = IsBindClicked(row.Value)
            if clicked then
                if row.Mode == "Toggle" then row._bindToggle = not row._bindToggle end
                if row.PressedCallback then
                    task.spawn(row.PressedCallback, row.Value,
                               row.Mode == "Toggle" and row._bindToggle or true)
                end
            end
            if row._bindHeld and not held and row.ReleasedCallback then
                task.spawn(row.ReleasedCallback, row.Value)
            end
            row._bindHeld = held
        end
    end
end

local KeybindHUD = {
    X = nil,
    Y = 18,
    Dragging = false,
    DragOffsetX = 0,
    DragOffsetY = 0,
    Reveal = 0,
}

local function GetKeybindOverlayGeometry()
    local vp = Camera.ViewportSize
    local list = CollectKeybinds()
    local maxRows = math.min(#list, 8)
    local rowH = 27
    local headerH = 34
    local footerH = #list > 8 and 20 or 8

    local labelSize = 11
    local keySize = 12
    local longestLabelW = TextWidth("No hotkeys assigned", labelSize, Fonts.SystemBold)
    local longestKeyW = TextWidth("NONE", keySize, Fonts.SystemBold)
    for i = 1, math.min(#list, 8) do
        local entry = list[i]
        local title = tostring(entry.Title or "Hotkey")
        local value = string.upper(tostring(entry.Row and entry.Row.Value or "NONE"))
        longestLabelW = math.max(longestLabelW, TextWidth(title, labelSize, Fonts.SystemBold))
        longestKeyW = math.max(longestKeyW, TextWidth(value, keySize, Fonts.SystemBold))
    end

    local pillW = math.max(36, longestKeyW + 18)
    local leftPad, gap, rightPad = 12, 14, 12
    local w = math.max(142, leftPad + longestLabelW + gap + pillW + rightPad)
    local h = headerH + math.max(1, maxRows) * rowH + footerH
    local x = KeybindHUD.X
    if x == nil then x = math.max(10, vp.X - w - 18) end
    x = math.max(6, math.min(x, math.max(6, vp.X - w - 6)))
    local y = math.max(6, math.min(KeybindHUD.Y, math.max(6, vp.Y - h - 6)))
    return x, y, w, h, headerH, rowH, list, longestLabelW, pillW
end

UpdateKeybindOverlayInput = function()
    if State.Settings and State.Settings.KeybindOverlay == false then return end
    if (KeybindHUD.Reveal or 0) < 0.95 then return end
    if not State.Open or State.Visible < 0.50 then
        KeybindHUD.Dragging = false
        return
    end
    local x, y, w, h = GetKeybindOverlayGeometry()
    local hover = MouseIn(x, y, w, h)

    if KeybindHUD.Dragging then
        if Input.Down then
            KeybindHUD.X = Input.X - KeybindHUD.DragOffsetX
            KeybindHUD.Y = Input.Y - KeybindHUD.DragOffsetY
        else
            KeybindHUD.Dragging = false
        end
        Input.Click = false
        return
    end

    if hover and Input.Click then
        KeybindHUD.Dragging = true
        KeybindHUD.DragOffsetX = Input.X - x
        KeybindHUD.DragOffsetY = Input.Y - y
        KeybindHUD.X = x
        KeybindHUD.Y = y
        Input.Click = false
    end
end

DrawKeybindOverlay = function()
    local target = (State.Settings and State.Settings.KeybindOverlay ~= false
                    and (State.OverlayRevealTime or 0) >= 0) and 1 or 0
    KeybindHUD.Reveal = State.NoAnim and target
        or Approach(KeybindHUD.Reveal or 0, target, 14, State.Delta)
    if (KeybindHUD.Reveal or 0) <= 0.01 then return end
    local th = State.Theme
    local x, y, w, h, headerH, rowH, list, labelColumnW, pillW =
        GetKeybindOverlayGeometry()

    local previousAlpha = FrameAlpha
    FrameAlpha = KeybindHUD.Reveal or 0

    CutPanel(x, y, w, h, 10, rgb(13, 16, 23), 331, 0.96)
    CutOutline(x, y, w, h, 10, th.Accent, 332, 0.88, 1)

    local header = "HOTKEYS"
    local headerSize = 12
    local headerW = TextWidth(header, headerSize, Fonts.SystemBold)
    Text(header, x + (w - headerW) / 2,
         TextMidY(y, headerH, headerSize) - 2,
         th.Text, headerSize, Fonts.SystemBold, 334, 1, headerW + 2)

    Line(x + 10, y + headerH - 1, x + w - 10, y + headerH - 1,
         th.Accent, 334, 1, 0.22)

    local rowY = y + headerH
    if #list == 0 then
        local empty = "No hotkeys assigned"
        local emptyW = TextWidth(empty, 11, Fonts.SystemBold)
        Text(empty, x + (w - emptyW) / 2,
             TextMidY(rowY, rowH, 11),
             th.TextDim, 11, Fonts.SystemBold, 335, 0.82, emptyW + 2)
        FrameAlpha = previousAlpha
        return
    end

    local labelX = x + 12
    local pillX = labelX + labelColumnW + 14
    for i = 1, math.min(#list, 8) do
        local entry = list[i]
        local title = tostring(entry.Title or "Hotkey")
        local value = string.upper(tostring(entry.Row and entry.Row.Value or "NONE"))
        local labelSize = 11
        local keySize = 12
        local valueW = TextWidth(value, keySize, Fonts.SystemBold)
        local pillH = 20
        local pillY = rowY + (rowH - pillH) / 2

        Text(title, labelX, TextMidY(rowY, rowH, labelSize),
             th.Text, labelSize, Fonts.SystemBold, 336, 0.96, labelColumnW + 2)

        Rect(pillX, pillY, pillW, pillH, th.Accent, 337, 5, 0.13)
        Stroke(pillX, pillY, pillW, pillH, th.Accent, 338, 5, 0.42)
        Text(value,
             pillX + (pillW - valueW) / 2,
             TextMidY(pillY, pillH, keySize),
             th.Accent, keySize, Fonts.SystemBold, 339, 1, valueW + 2)

        rowY = rowY + rowH
    end

    if #list > 8 then
        local more = "+" .. tostring(#list - 8) .. " more"
        local moreW = TextWidth(more, 8, Fonts.SystemBold)
        Text(more, x + (w - moreW) / 2, rowY + 4,
             th.TextDim, 8, Fonts.SystemBold, 339, 0.68, moreW + 2)
    end

    FrameAlpha = previousAlpha
end

local PerformanceHUD = {
    X = 18,
    Y = 18,
    Dragging = false,
    DragOffsetX = 0,
    DragOffsetY = 0,
    FPS = 60,
    FrameMS = 16.7,
    AccumTime = 0,
    AccumFrames = 0,
    Reveal = 0,
}

TickPerformanceOverlay = function(dt)
    dt = math.max(0.0001, tonumber(dt) or (1 / 60))
    PerformanceHUD.AccumTime = PerformanceHUD.AccumTime + dt
    PerformanceHUD.AccumFrames = PerformanceHUD.AccumFrames + 1
    if PerformanceHUD.AccumTime >= 0.35 then
        PerformanceHUD.FPS = PerformanceHUD.AccumFrames / PerformanceHUD.AccumTime
        PerformanceHUD.FrameMS = (PerformanceHUD.AccumTime / PerformanceHUD.AccumFrames) * 1000
        PerformanceHUD.AccumTime = 0
        PerformanceHUD.AccumFrames = 0
    end
end

local function GetPerformanceRows()
    local vp = Camera.ViewportSize
    return {
        {"FPS", tostring(math.floor(PerformanceHUD.FPS + 0.5))},
        {"FRAME", string.format("%.1f ms", PerformanceHUD.FrameMS)},
        {"WINDOW", tostring(math.floor(State.W)) .. " x " .. tostring(math.floor(State.H))},
        {"VIEWPORT", tostring(math.floor(vp.X)) .. " x " .. tostring(math.floor(vp.Y))},
    }
end

local function GetPerformanceOverlayGeometry()
    local vp = Camera.ViewportSize
    local rows = GetPerformanceRows()
    local labelSize, valueSize = 10, 10
    local labelW, valueW = 0, 0
    for _, row in ipairs(rows) do
        labelW = math.max(labelW, TextWidth(row[1], labelSize, Fonts.SystemBold))
        valueW = math.max(valueW, TextWidth(row[2], valueSize, Fonts.SystemBold))
    end
    local headerH, rowH = 34, 25
    local w = math.max(158, 12 + labelW + 18 + valueW + 12)
    local h = headerH + #rows * rowH + 8
    local x = math.max(6, math.min(PerformanceHUD.X, math.max(6, vp.X - w - 6)))
    local y = math.max(6, math.min(PerformanceHUD.Y, math.max(6, vp.Y - h - 6)))
    return x, y, w, h, headerH, rowH, rows, labelW, valueW
end

UpdatePerformanceOverlayInput = function()
    if State.Settings and State.Settings.PerformanceOverlay == false then return end
    if (PerformanceHUD.Reveal or 0) < 0.95 then return end
    if not State.Open or State.Visible < 0.50 then
        PerformanceHUD.Dragging = false
        return
    end
    local x, y, w, h = GetPerformanceOverlayGeometry()
    local hover = MouseIn(x, y, w, h)

    if PerformanceHUD.Dragging then
        if Input.Down then
            PerformanceHUD.X = Input.X - PerformanceHUD.DragOffsetX
            PerformanceHUD.Y = Input.Y - PerformanceHUD.DragOffsetY
        else
            PerformanceHUD.Dragging = false
        end
        Input.Click = false
        return
    end

    if hover and Input.Click then
        PerformanceHUD.Dragging = true
        PerformanceHUD.DragOffsetX = Input.X - x
        PerformanceHUD.DragOffsetY = Input.Y - y
        PerformanceHUD.X = x
        PerformanceHUD.Y = y
        Input.Click = false
    end
end

DrawPerformanceOverlay = function()
    local target = (State.Settings and State.Settings.PerformanceOverlay ~= false
                    and (State.OverlayRevealTime or 0) >= 0.5) and 1 or 0
    PerformanceHUD.Reveal = State.NoAnim and target
        or Approach(PerformanceHUD.Reveal or 0, target, 14, State.Delta)
    if (PerformanceHUD.Reveal or 0) <= 0.01 then return end
    local th = State.Theme
    local x, y, w, h, headerH, rowH, rows, labelW =
        GetPerformanceOverlayGeometry()

    local previousAlpha = FrameAlpha
    FrameAlpha = PerformanceHUD.Reveal or 0

    CutPanel(x, y, w, h, 10, rgb(13, 16, 23), 341, 0.96)
    CutOutline(x, y, w, h, 10, th.Accent, 342, 0.88, 1)

    local header = "PERFORMANCE"
    local headerSize = 12
    local headerW = TextWidth(header, headerSize, Fonts.SystemBold)
    Text(header, x + (w - headerW) / 2,
         TextMidY(y, headerH, headerSize) - 2,
         th.Text, headerSize, Fonts.SystemBold, 344, 1, headerW + 2)

    Line(x + 10, y + headerH - 1, x + w - 10, y + headerH - 1,
         th.Accent, 344, 1, 0.22)

    local rowY = y + headerH
    local valueX = x + 12 + labelW + 18
    for _, row in ipairs(rows) do
        Text(row[1], x + 12, TextMidY(rowY, rowH, 10),
             th.TextDim, 10, Fonts.SystemBold, 345, 0.86, labelW + 2)
        Text(row[2], valueX, TextMidY(rowY, rowH, 10),
             th.Text, 10, Fonts.SystemBold, 346, 0.98, w - (valueX - x) - 12)
        rowY = rowY + rowH
    end

    FrameAlpha = previousAlpha
end

local function EnsureGlobalSettingsTab(library)
    for _, tab in ipairs(State.Tabs) do
        if tab.IsSettings then return tab end
    end

    local tab = Tab.new(library, {
        Title = "Settings",
        Icon = "settings",
        IsSettings = true,
    })

    local behavior = Section.new(tab, "Behavior", "Window and navigation preferences", {})
    Controls.Keybind(behavior, {
        Title = "Menu key",
        Description = "Overrides the menu key configured by the script.",
        Default = State.MenuKey,
        ConfigKey = "settings.menuKey",
        Callback = function(value)
            value = string.lower(tostring(value or ""))
            if value ~= "" and value ~= "none" then
                State.MenuKey = value
                Keys.Track(State.MenuKey)
            end
        end,
    })
    Controls.Toggle(behavior, {
        Title = "Performance overlay",
        Description = "Show the performance statistics overlay.",
        Default = State.Settings.PerformanceOverlay ~= false,
        ConfigKey = "settings.performanceOverlay",
        Callback = function(enabled)
            State.Settings.PerformanceOverlay = enabled
        end,
    })
    Controls.Toggle(behavior, {
        Title = "Hotkey overlay",
        Description = "Show the active hotkeys overlay.",
        Default = State.Settings.KeybindOverlay ~= false,
        ConfigKey = "settings.keybindOverlay",
        Callback = function(enabled)
            State.Settings.KeybindOverlay = enabled
        end,
    })
    Controls.Button(behavior, {
        Title = "Reset overlay position",
        Callback = function()
            KeybindHUD.X = nil
            KeybindHUD.Y = 18
        end,
    })
    Controls.Button(behavior, {
        Title = "Reset window position",
        Callback = function()
            local vp = Camera.ViewportSize
            State.X = math.floor((vp.X - State.W) / 2)
            State.Y = math.floor((vp.Y - State.H) / 2)
        end,
    })

    local appearance = Section.new(tab, "Appearance", "Global interface appearance", {})
    Controls.Dropdown(appearance, {
        Title = "Theme",
        Options = {"Midnight", "Obsidian", "Burgundy", "Cyber", "Bubblegum", "Emerald", "Crimson", "Arctic", "Sunset", "Royal"},
        Default = (State.Theme and State.Theme.Name) or "Midnight",
        Callback = function(value) SetThemeByName(value) end,
    })
    Controls.Dropdown(appearance, {
        Title = "Background",
        Options = {"none", "dots", "particles", "aurora", "snow", "rainfall"},
        Default = type(State.Background) == "table" and (State.Background.Type or "none") or State.Background,
        Callback = function(value) State.Background = NormalizeBackground(value) end,
    })
    Controls.Slider(appearance, {
        Title = "Window opacity",
        Description = "Controls how transparent or solid the main glass window is.",
        Min = 35, Max = 100, Default = State.Settings.WindowOpacity, Step = 1,
        Suffix = "%",
        Callback = function(v)
            State.Settings.WindowOpacity = v
            GlassSurfaceAlpha = math.max(0.20, math.min(1, v / 100))
        end,
    })
    Controls.Toggle(appearance, {
        Title = "Background effects",
        Description = "Master switch for the animated window background.",
        Default = State.Settings.BackgroundEffects,
        Callback = function(v) State.Settings.BackgroundEffects = v end,
    })
    Controls.Toggle(appearance, {
        Title = "Border animation",
        Description = "Animated comet travelling around the main border.",
        Default = State.Settings.BorderComet,
        Callback = function(v) State.Settings.BorderComet = v end,
    })
    Controls.Toggle(appearance, {
        Title = "Reduce animations",
        Description = "Disables most UI tweening and motion.",
        Default = State.NoAnim,
        Callback = function(v) State.NoAnim = v end,
    })
    Controls.Dropdown(appearance, {
        Title = "Toggle style",
        Description = "Switch between sliding toggles and compact checkboxes.",
        Options = {"Switch", "Checkbox"},
        Default = State.Settings.ToggleStyle,
        Callback = function(v) State.Settings.ToggleStyle = v end,
    })

    local configs = Section.new(tab, "Configs", "Save and manage interface configurations.", {})

    Controls.Label(configs, {
        Title = "Config name",
    })

    local configNameBox = Controls.ConfigTextbox(configs, {
        Title = "",
        Placeholder = "default",
        Default = State.Settings.ConfigName or "default",
        Callback = function(v)
            v = string.gsub(tostring(v or "default"), "[^%w_%-]", "_")
            if v == "" then v = "default" end
            State.Settings.ConfigName = v
        end,
    })

    local savedConfigs = Controls.Dropdown(configs, {
        Title = "Saved configs",
        Options = {"None"},
        Default = "None",
    })

    local function RefreshConfigs(selectName)
        local names = {}
        local seen = {}

        local function AddName(name)
            name = tostring(name or "")
            if name == "" or name == "None" or seen[name] then return end
            seen[name] = true
            names[#names + 1] = name
        end

        AddName(selectName)

        if type(listfiles) == "function" then
            for _, root in ipairs({".", ""}) do
                local ok, files = pcall(listfiles, root)
                if ok and type(files) == "table" then
                    for _, path in ipairs(files) do
                        local file = tostring(path):gsub("\\", "/"):match("([^/]+)$") or tostring(path)
                        local name = file:match("^Nexa_(.+)%.json$")
                        AddName(name)
                    end
                end
            end
        end

        table.sort(names, function(a, b)
            return string.lower(a) < string.lower(b)
        end)

        if #names == 0 then names[1] = "None" end

        savedConfigs.Options = names
        savedConfigs._listScroll = 0
        savedConfigs._listScrollTo = 0

        local wanted = selectName
        local found = false
        if wanted then
            for _, name in ipairs(names) do
                if name == wanted then found = true break end
            end
        end

        savedConfigs:SetValue(found and wanted or names[1], true)
    end

    local configActions = InlineRow.new(configs, {1, 1, 1, Gap = 6})

    Controls.Button(configActions, {
        Title = "",
        ButtonText = "Save",
        Variant = "primary",
        Callback = function()
            local name = configNameBox:GetValue()
            name = string.gsub(tostring(name or "default"), "[^%w_%-]", "_")
            if name == "" then name = "default" end

            configNameBox:SetValue(name, true)
            State.Settings.ConfigName = name

            if library.SaveConfig then
                local ok = library:SaveConfig(name)
                if ok then
                    RefreshConfigs(name)
                end
            end
        end,
    })

    Controls.Button(configActions, {
        Title = "",
        ButtonText = "Load",
        Callback = function()
            local name = savedConfigs:GetValue()
            if name and name ~= "None" and library.LoadConfig then
                library:LoadConfig(name)
                State.Settings.ConfigName = name
                configNameBox:SetValue(name, true)
            end
        end,
    })

    Controls.Button(configActions, {
        Title = "",
        ButtonText = "Delete",
        Variant = "danger",
        Callback = function()
            local name = savedConfigs:GetValue()
            if name and name ~= "None" and library.DeleteConfig then
                local ok = library:DeleteConfig(name)
                if ok then RefreshConfigs() end
            end
        end,
    })

    RefreshConfigs()

    local scriptSec = Section.new(tab, "Script", "Fully close the script and remove its interface.", {})
    Controls.Button(scriptSec, {
        Title = "",
        ButtonText = "Unload Script",
        Variant = "danger",
        Expand = true,
        Callback = function()
            task.spawn(function()
                if library.Unload then library:Unload() else library:Destroy() end
                task.wait(0.25)
                PoolMade.Lib.KillAll()
                if type(setrobloxinput) == "function" then pcall(setrobloxinput, true) end
            end)
        end,
    })

    return tab
end

local Library = {}

function Library:CreateWindow(opts)
    opts = opts or {}

    local requestedOpacity = tonumber(opts.Opacity or opts.opacity)
    if requestedOpacity ~= nil then
        State.Settings.WindowOpacity = math.max(35, math.min(100, requestedOpacity))
    end
    GlassSurfaceAlpha = math.max(0.20, math.min(1, (State.Settings.WindowOpacity or 82) / 100))

    local size = opts.Size or opts.size
    if type(size) == "userdata" or type(size) == "table" then
        local sw = tonumber(size.X or size.x)
        local sh = tonumber(size.Y or size.y)
        if sw then State.W = math.max(Layout.WindowMinW, sw) end
        if sh then State.H = math.max(Layout.WindowMinH, sh) end
    else
        if opts.Width or opts.width then State.W = math.max(Layout.WindowMinW, tonumber(opts.Width or opts.width) or State.W) end
        if opts.Height or opts.height then State.H = math.max(Layout.WindowMinH, tonumber(opts.Height or opts.height) or State.H) end
    end

    State.WindowTitle = tostring(opts.Title or opts.title or opts.Name or opts.name or State.WindowTitle or "Window")
    State.WindowSubtitle = tostring(opts.Subtitle or opts.subtitle or "")

    State.ProfileDisplayName = tostring(LocalPlayer.DisplayName or LocalPlayer.Name or "Player")
    State.ProfileUsername = tostring(LocalPlayer.Name or "Player")
    if State.ProfileAvatar == nil and not State.ProfileAvatarLoading then
        State.ProfileAvatarLoading = true
        task.spawn(function()
            local userId = tonumber(LocalPlayer.UserId)
            local loaded = false

            if userId and userId > 0 then
                local endpoints = {
                    "https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=%d&size=150x150&format=Png&isCircular=false",
                    "https://thumbnails.roproxy.com/v1/users/avatar-headshot?userIds=%d&size=150x150&format=Png&isCircular=false",
                    "https://thumbnails.roblox.com/v1/users/avatar-bust?userIds=%d&size=150x150&format=Png&isCircular=false",
                }

                for _, pattern in ipairs(endpoints) do
                    if loaded then break end

                    local ok, body = pcall(function()
                        local url = string.format(pattern, userId)
                        if type(httpget) == "function" then return httpget(url) end
                        if game and game.HttpGet then return game:HttpGet(url) end
                        return nil
                    end)

                    if ok and type(body) == "string" then
                        local imageUrl = string.match(body, '"imageUrl"%s*:%s*"([^"]+)"')
                        if imageUrl then
                            imageUrl = string.gsub(imageUrl, "\\/", "/")
                            local holder = LoadPicture(imageUrl, "profile_avatar_" .. tostring(userId))
                            if holder then
                                State.ProfileAvatarSource = imageUrl
                                State.ProfileAvatar = holder
                                loaded = true
                            end
                        end
                    end
                end
            end

            if not loaded then
                local ok, thumbnail = pcall(function()
                    return Players:GetUserThumbnailAsync(
                        LocalPlayer.UserId,
                        Enum.ThumbnailType.HeadShot,
                        Enum.ThumbnailSize.Size150x150
                    )
                end)
                if ok and type(thumbnail) == "string" and thumbnail ~= "" then
                    local holder = LoadPicture(thumbnail, "profile_avatar_" .. tostring(LocalPlayer.UserId))
                    if holder then
                        State.ProfileAvatarSource = thumbnail
                        State.ProfileAvatar = holder
                    end
                end
            end

            State.ProfileAvatarLoading = false
        end)
    end

    State.ShowGameName = (opts.ShowGameName ~= false and opts.showGameName ~= false)
    State.ShowLogo = (opts.ShowLogo ~= false and opts.showLogo ~= false)
    local customGameName = opts.GameName or opts.gameName
    if customGameName ~= nil then
        State.GameName = tostring(customGameName)
    else

        State.GameName = State.CachedGameName or ("PLACE " .. tostring(game.PlaceId))
        if not State.GameNameLoading and not State.CachedGameName then
            State.GameNameLoading = true
            task.spawn(function()
                local resolvedName
                if tonumber(game.GameId) and tonumber(game.GameId) > 0 then
                    local ok, body = pcall(function()
                        return game:HttpGet("https://games.roblox.com/v1/games?universeIds=" .. tostring(game.GameId))
                    end)
                    if ok and type(body) == "string" and body ~= "" then
                        local decodedOk, decoded = pcall(function()
                            return game:GetService("HttpService"):JSONDecode(body)
                        end)
                        if decodedOk and type(decoded) == "table" and type(decoded.data) == "table"
                           and type(decoded.data[1]) == "table" and decoded.data[1].name then
                            resolvedName = tostring(decoded.data[1].name)
                        end
                    end
                end
                if not resolvedName then
                    local ok, info = pcall(function()
                        return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId, Enum.InfoType.Asset)
                    end)
                    if ok and type(info) == "table" and info.Name then resolvedName = tostring(info.Name) end
                end
                if resolvedName then
                    State.CachedGameName = resolvedName
                    if State.Alive and State.ShowGameName and not State.CustomGameName then
                        State.GameName = resolvedName
                    end
                end
                State.GameNameLoading = false
            end)
        end
    end
    State.CustomGameName = customGameName ~= nil

    local logoSource = opts.Logo
    if logoSource == nil then logoSource = opts.logo end
    if logoSource == nil or logoSource == false or logoSource == "" or State.ShowLogo == false then
        HidePicture(State.Logo)
        State.Logo = nil
        State.LogoSource = nil
    elseif logoSource ~= nil and logoSource ~= State.LogoSource then
        HidePicture(State.Logo)
        State.LogoSource = logoSource
        State.Logo = LoadPicture(logoSource, "logo")
    end
    local logoSize = tonumber(opts.LogoSize or opts.logoSize)
    if logoSize then State.LogoSize = math.max(24, math.min(48, logoSize)) end

    local backgroundImageSource = opts.BackgroundImage or opts.backgroundImage
    if backgroundImageSource ~= nil and backgroundImageSource ~= State.BackgroundImageSource then
        HidePicture(State.BackgroundImage)
        State.BackgroundImageSource = backgroundImageSource
        State.BackgroundImage = LoadPicture(backgroundImageSource, "background")
    end

    if opts.MenuKey or opts.menuKey then State.MenuKey = string.lower(tostring(opts.MenuKey or opts.menuKey)) end

    local notifPos = opts.NotifPos or opts.notifpos or opts.NotificationPosition or opts.notificationPosition
    if notifPos ~= nil then
        State.NotificationPosition = NormalizeNotificationPosition(notifPos)
    end
    if opts.NoAnim ~= nil or opts.noAnim ~= nil then State.NoAnim = (opts.NoAnim ~= nil and opts.NoAnim or opts.noAnim) and true or false end
    if opts.Background ~= nil or opts.background ~= nil then State.Background = NormalizeBackground(opts.Background or opts.background) end
    local themeOption = opts.Theme or opts.theme
    if themeOption ~= nil then
        if type(themeOption) == "string" then
            for i, th in ipairs(Themes) do
                if string.lower(th.Name) == string.lower(themeOption) then
                    State.Theme = th
                    State.ThemeIndex = i
                    break
                end
            end
        elseif type(themeOption) == "table" then
            ApplyThemeOptions(themeOption)
        end
    end

    EnsureGlobalSettingsTab(self)

    local vp = Camera.ViewportSize
    State.X = math.floor((vp.X - State.W) / 2)
    State.Y = math.floor((vp.Y - State.H) / 2)
    State.Entrance.Time = 0
    State.Entrance.Active = not State.NoAnim
    State.Visible = 1
    State.Open = true
    State.ApplyInputState(true)
    return self
end
Library.Version       = "1.4.2"
Library.Themes         = Themes
Library.Layout         = Layout
Library.State          = State
Library.Tabs           = {}

function Library:AddTab(opts)
    opts = opts or {}
    local settingsTab, settingsIndex = nil, nil
    for i, existing in ipairs(State.Tabs) do
        if existing.IsSettings then
            settingsTab, settingsIndex = existing, i
            break
        end
    end

    if settingsTab then
        table.remove(State.Tabs, settingsIndex)
        if self.Tabs then
            for i, existing in ipairs(self.Tabs) do
                if existing == settingsTab then table.remove(self.Tabs, i) break end
            end
        end
    end

    local tab = Tab.new(self, opts)

    if settingsTab then
        State.Tabs[#State.Tabs + 1] = settingsTab
        self.Tabs[#self.Tabs + 1] = settingsTab
    end

    EnsureWindowFitsTabs()
    if opts.Select then
        local _, idx = FindTab(tab.Name)
        if idx then State.ActiveIndex = idx end
    end

    return tab
end

function Library:GetTab(name)
    local tab = FindTab(name)
    return tab
end

function Library:SelectTab(name)
    SetActiveTabByName(name)
end

function Library:ResetDefaults()
    local function resetControl(ctrl)
        if not ctrl or not ctrl.SetValue then return end
        if ctrl.Kind == "RangeSlider" then
            if ctrl.DeclaredDefaultLow ~= nil and ctrl.DeclaredDefaultHigh ~= nil then
                ctrl:SetValue(ctrl.DeclaredDefaultLow, ctrl.DeclaredDefaultHigh)
            end
        elseif ctrl.DeclaredDefault ~= nil then
            ctrl:SetValue(ctrl.DeclaredDefault)
        end
    end

    for _, tab in ipairs(State.Tabs) do
        for _, row in ipairs(tab.Rows or {}) do
            if IsSection(row) then
                for _, child in ipairs(row.Rows or {}) do
                    if getmetatable(child) == InlineRow then
                        for _, ctrl in ipairs(child.Cells or {}) do resetControl(ctrl) end
                    else
                        resetControl(child)
                    end
                end
            elseif getmetatable(row) == InlineRow then
                for _, ctrl in ipairs(row.Cells or {}) do resetControl(ctrl) end
            else
                resetControl(row)
            end
        end
    end
    return self
end

function Library:SaveConfig(name)
    name = string.gsub(tostring(name or "default"), "[^%w_%-]", "_")
    if name == "" then name = "default" end

    local data = {
        version = 1,
        theme = State.Theme and State.Theme.Name or "Midnight",
        background = type(State.Background) == "table" and (State.Background.Type or "none") or State.Background,
        settings = {
            WindowOpacity = State.Settings.WindowOpacity,
            BackgroundEffects = State.Settings.BackgroundEffects,
            BorderComet = State.Settings.BorderComet,
            ToggleStyle = State.Settings.ToggleStyle,
            RailPinned = State.RailPinned,
            NoAnim = State.NoAnim,
        },
        controls = {},
    }

    local function storeControl(ctrl, path)
        if not ctrl or not ctrl.GetValue then return end
        if ctrl.Kind ~= "Toggle" and ctrl.Kind ~= "Slider"
           and ctrl.Kind ~= "RangeSlider" and ctrl.Kind ~= "Dropdown"
           and ctrl.Kind ~= "Radio" and ctrl.Kind ~= "Segmented"
           and ctrl.Kind ~= "Keybind"
           and ctrl.Kind ~= "ColorPicker" then return end
        local key = ctrl.ConfigKey or path
        local ok, a, b = pcall(function() return ctrl:GetValue() end)
        if ok then
            if ctrl.Kind == "RangeSlider" then
                data.controls[key] = {a, b}
            elseif ctrl.Kind == "ColorPicker" and typeof(a) == "Color3" then
                data.controls[key] = {
                    r = math.floor(a.R * 255 + 0.5),
                    g = math.floor(a.G * 255 + 0.5),
                    b = math.floor(a.B * 255 + 0.5),
                    a = tonumber(b) or 1,
                }
            else
                data.controls[key] = a
            end
        end
        for ai, accessory in ipairs(ctrl.Accessories or {}) do
            storeControl(accessory, path .. "/Accessory/" .. tostring(ai))
        end
    end

    for ti, tab in ipairs(State.Tabs) do
        for ri, row in ipairs(tab.Rows or {}) do
            if IsSection(row) then
                for ci, child in ipairs(row.Rows or {}) do
                    if getmetatable(child) == InlineRow then
                        for ii, ctrl in ipairs(child.Cells or {}) do
                            storeControl(ctrl, tostring(tab.Name).."/"..tostring(row.Title).."/"..tostring(ctrl.Title).."/"..ii)
                        end
                    else
                        storeControl(child, tostring(tab.Name).."/"..tostring(row.Title).."/"..tostring(child.Title).."/"..ci)
                    end
                end
            else
                storeControl(row, tostring(tab.Name).."/"..tostring(row.Title).."/"..ri)
            end
        end
    end

    if not writefile then return false, "writefile unavailable" end
    local ok, encoded = pcall(function()
        return game:GetService("HttpService"):JSONEncode(data)
    end)
    if not ok then return false, encoded end
    local path = "Nexa_" .. name .. ".json"
    local wrote, err = pcall(function() writefile(path, encoded) end)
    if wrote then
        State.Settings.ConfigName = name
    end
    return wrote, wrote and path or err
end

function Library:LoadConfig(name)
    name = string.gsub(tostring(name or "default"), "[^%w_%-]", "_")
    if name == "" then name = "default" end
    local path = "Nexa_" .. name .. ".json"
    if not readfile then return false, "readfile unavailable" end
    if isfile then
        local okExists, exists = pcall(function() return isfile(path) end)
        if okExists and not exists then return false, "config not found" end
    end
    local okRead, raw = pcall(function() return readfile(path) end)
    if not okRead then return false, raw end
    local okDecode, data = pcall(function()
        return game:GetService("HttpService"):JSONDecode(raw)
    end)
    if not okDecode or type(data) ~= "table" then return false, data end

    if data.theme then SetThemeByName(data.theme) end
    if data.background then State.Background = NormalizeBackground(data.background) end
    local st = data.settings or {}
    if st.WindowOpacity ~= nil then
        State.Settings.WindowOpacity = st.WindowOpacity
        GlassSurfaceAlpha = math.max(0.20, math.min(1, st.WindowOpacity / 100))
    end
    if st.BackgroundEffects ~= nil then State.Settings.BackgroundEffects = st.BackgroundEffects end
    if st.BorderComet ~= nil then State.Settings.BorderComet = st.BorderComet end
    if st.ToggleStyle ~= nil then State.Settings.ToggleStyle = st.ToggleStyle end
    State.RailPinned = true
    State.RailOpen = 1
    if st.NoAnim ~= nil then State.NoAnim = st.NoAnim end

    local values = data.controls or {}
    local function loadControl(ctrl, pathKey)
        if not ctrl or not ctrl.SetValue then return end
        local key = ctrl.ConfigKey or pathKey
        local value = values[key]
        if value == nil then return end
        if ctrl.Kind == "RangeSlider" and type(value) == "table" then
            ctrl:SetValue(value[1], value[2])
        elseif ctrl.Kind == "ColorPicker" and type(value) == "table" then
            local r = math.max(0, math.min(255, tonumber(value.r or value[1]) or 255))
            local g = math.max(0, math.min(255, tonumber(value.g or value[2]) or 255))
            local b = math.max(0, math.min(255, tonumber(value.b or value[3]) or 255))
            local alpha = math.max(0, math.min(1, tonumber(value.a or value.alpha or value[4]) or 1))
            ctrl:SetValue(Color3.fromRGB(r, g, b), false, alpha)
        else
            ctrl:SetValue(value)
        end
        for ai, accessory in ipairs(ctrl.Accessories or {}) do
            loadControl(accessory, pathKey .. "/Accessory/" .. tostring(ai))
        end
    end

    for _, tab in ipairs(State.Tabs) do
        for ri, row in ipairs(tab.Rows or {}) do
            if IsSection(row) then
                for ci, child in ipairs(row.Rows or {}) do
                    if getmetatable(child) == InlineRow then
                        for ii, ctrl in ipairs(child.Cells or {}) do
                            loadControl(ctrl, tostring(tab.Name).."/"..tostring(row.Title).."/"..tostring(ctrl.Title).."/"..ii)
                        end
                    else
                        loadControl(child, tostring(tab.Name).."/"..tostring(row.Title).."/"..tostring(child.Title).."/"..ci)
                    end
                end
            else
                loadControl(row, tostring(tab.Name).."/"..tostring(row.Title).."/"..ri)
            end
        end
    end
    State.Settings.ConfigName = name
    return true, path
end

function Library:DeleteConfig(name)
    name = string.gsub(tostring(name or ""), "[^%w_%-]", "_")
    if name == "" then return false, "invalid config name" end

    local path = "Nexa_" .. name .. ".json"
    if type(delfile) ~= "function" then return false, "delfile unavailable" end

    if type(isfile) == "function" then
        local okExists, exists = pcall(isfile, path)
        if okExists and not exists then return false, "config not found" end
    end

    local ok, err = pcall(delfile, path)
    return ok, ok and path or err
end

function Library:Notify(opts)
    return Notify(opts)
end

function Library:SetTheme(name)
    return SetThemeByName(name)
end

function Library:NextTheme()
    NextTheme()
end

function Library:SetBackground(effect)
    State.Background = NormalizeBackground(effect)
end

function Library:OpenKeybinds()
    State.Settings.KeybindOverlay = true
end

function Library:CloseKeybinds()
    State.Settings.KeybindOverlay = false
end

function Library:OpenPerformance()
    State.Settings.PerformanceOverlay = true
end

function Library:ClosePerformance()
    State.Settings.PerformanceOverlay = false
end

function Library:SetKeybind(key)
    State.MenuKey = string.lower(tostring(key))
end

function Library:Toggle()   ToggleUI() end
function Library:Show()     State.Open = true end
function Library:Hide()     State.Open = false; ClearFocus() end

function Library:IsAlive() return State.Alive end

function Library:OnDestroy(callback)
    if type(callback) == "function" then
        State.DestroyCallbacks[#State.DestroyCallbacks + 1] = callback
    end
    return self
end

function Library:Destroy()
    if not State.Alive then return end
    State.Alive = false
    if State.RenderConnection then
        pcall(function() State.RenderConnection:Disconnect() end)
        State.RenderConnection = nil
    end

    for i = 1, #State.DestroyCallbacks do
        pcall(State.DestroyCallbacks[i])
    end
    State.DestroyCallbacks = {}

    ClearFocus()
    State.InputSent = true
    if type(setrobloxinput) == "function" then pcall(setrobloxinput, true) end
    PoolMade.Lib.Dead = true
    ClearPool()
    State.Logo, State.ProfileAvatar, State.BackgroundImage = nil, nil, nil
    PoolMade.Lib.KillAll()
    CancelCapture()
end

-- Fully tears down the UI: destroys the window, removes every Drawing object it
-- ever created, restores game input and clears the library globals.
function Library:Unload()
    pcall(function() self:Destroy() end)
    local removed = PoolMade.Lib.KillAll()
    if removed == 0 and type(cleardrawcache) == "function" then pcall(cleardrawcache) end
    if type(setrobloxinput) == "function" then pcall(setrobloxinput, true) end
    for _, env in ipairs({ type(getgenv) == "function" and getgenv() or nil, type(_G) == "table" and _G or nil, type(shared) == "table" and shared or nil }) do
        for _, name in ipairs({ "Nexa", "UI", "DrawingUI" }) do
            if env[name] == Library then env[name] = nil end
        end
    end
    return removed
end

-- Optional: register a Drawing object created outside the library so Unload removes it too.
function Library:TrackDrawing(obj)
    if obj then PoolMade.Lib.All[obj] = true end
    return obj
end

function Library:CreateOverlay(opts)
    return HUDBox.new(opts)
end

function Library:CreateBox(opts)
    return HUDBox.new(opts)
end

Library.IsBindHeld    = IsBindHeld
Library.IsBindClicked = IsBindClicked

do
    local function AttachControl(parentType, methodName, ctorName)
        local ctor = Controls[ctorName]
        if not ctor then return end
        parentType[methodName] = function(self, opts)
            local obj = ctor(self, opts)
            return obj
        end
    end

    for _, parentType in ipairs({ Tab, Section }) do
        AttachControl(parentType, "AddLabel",       "Label")
        AttachControl(parentType, "AddDivider",     "Divider")
        AttachControl(parentType, "AddButton",      "Button")
        AttachControl(parentType, "AddToggle",      "Toggle")
        AttachControl(parentType, "AddRadio",       "Radio")
        AttachControl(parentType, "AddSegmented",   "Segmented")
        AttachControl(parentType, "AddProgress",    "Progress")
        AttachControl(parentType, "AddStatus",      "Status")
        AttachControl(parentType, "AddSlider",      "Slider")
        AttachControl(parentType, "AddRangeSlider", "RangeSlider")
        AttachControl(parentType, "AddDropdown",    "Dropdown")
        AttachControl(parentType, "AddKeybind",     "Keybind")
        AttachControl(parentType, "AddColorPicker", "ColorPicker")
    end

    function Tab:AddSection(title, description, opts)
        return Section.new(self, title, description, opts)
    end

    function Tab:AddInline(weights)
        return InlineRow.new(self, weights)
    end

    function Section:AddInline(weights)
        return InlineRow.new(self, weights)
    end

    function InlineRow:AddRow(builder)
        self.Cells[#self.Cells + 1] = builder
        return builder
    end

    for _, ctrlName in ipairs({
        "Label", "Divider", "Toggle", "Radio", "Segmented", "Progress", "Status",
        "Slider", "RangeSlider", "Dropdown", "Keybind", "ColorPicker", "Button"
    }) do
        AttachControl(InlineRow, "Add" .. ctrlName, ctrlName)
    end

    local function AddAccessory(host, ctorName, opts)
        opts = opts or {}
        if opts.Inline == false or opts.Standalone == true then
            return Controls[ctorName](host.Parent, opts)
        end
        local copy = {}
        for k, v in pairs(opts) do copy[k] = v end
        copy._Accessory = true
        local obj = Controls[ctorName](host.Parent, copy)
        host.Accessories = host.Accessories or {}
        host.Accessories[#host.Accessories + 1] = obj
        obj.Host = host
        return obj
    end

    Base.AddKeybind = function(self, opts)
        return AddAccessory(self, "Keybind", opts)
    end

    Base.AddColorPicker = function(self, opts)
        return AddAccessory(self, "ColorPicker", opts)
    end

    for _, ctrlName in ipairs({
        "Label", "Divider", "Toggle", "Radio", "Segmented", "Progress", "Status",
        "Slider", "RangeSlider", "Dropdown", "Keybind", "ColorPicker", "Button"
    }) do
        local ctor = Controls[ctrlName]
        if ctor and ctrlName ~= "Keybind" and ctrlName ~= "ColorPicker" then
            Base["Add" .. ctrlName] = function(self, opts)
                local obj = ctor(self.Parent, opts)
                return obj
            end
        end
    end
end

do
    local vp = Camera.ViewportSize
    State.X = math.floor((vp.X - State.W) / 2)
    State.Y = math.floor((vp.Y - State.H) / 2)
end

if RunService and RunService.RenderStepped then
    State.RenderConnection = RunService.RenderStepped:Connect(function()
        if not State.Alive then return end
        local ok, err = pcall(Render)
        if not ok then
            warn("[Library] render error:", tostring(err))
        end
    end)
else
    task.spawn(function()
        while State.Alive do
            local ok, err = pcall(Render)
            if not ok then
                warn("[Library] render error:", tostring(err))
            end
            task.wait()
        end
    end)
end

Library.Version = "1.7.15"

Nexa = Library
UI = Library
DrawingUI = Library

if type(getgenv) == "function" then
    local env = getgenv()
    env.Nexa = Library
    env.UI = Library
    env.DrawingUI = Library
end

if type(shared) == "table" then
    shared.Nexa = Library
    shared.UI = Library
    shared.DrawingUI = Library
end

return Library
