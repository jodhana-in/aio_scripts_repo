-- name = "Bookmarks"
-- description = "Bookmark manager with preferred browser"
-- type = "widget"
-- author = "Ravindra Bhardwaj"
-- version = "1.0"

local json=require("json")
local md=require("md_colors")

local DB="bookmarks.json"
local data={browser_package="",home_page="",bookmarks={}}
local state=nil

local function load()
  local c=files:read(DB)
  if c then local ok,d=pcall(json.decode,c); if ok and d then data=d end end
  data.bookmarks=data.bookmarks or {}
  data.browser_package=data.browser_package or ""
  data.home_page=data.home_page or ""
end

local function save() files:write(DB,json.encode(data)) end

local function open_url(url)
  local i={action="android.intent.action.VIEW",data=url}
  if data.browser_package~="" then i.package=data.browser_package end
  intent:start_activity(i)
end

local function render()
  local n={"fa:globe","fa:plus"}
  local c={aio:colors().button,aio:colors().button}
  for _,b in ipairs(data.bookmarks) do
    table.insert(n,b.title)
    table.insert(c,b.color or md.blue_600)
  end
  ui:show_buttons(n,c)
end

function on_resume() load(); render() end

function on_click(idx)
  if idx==1 then
    if data.browser_package=="" then
      state={a="browser"}
      dialogs:show_edit_dialog("Preferred Browser","Package name","com.android.chrome")
    else
      if data.home_page~="" then
        open_url(data.home_page)
      else
        apps:launch(data.browser_package)
      end
    end
    return
  end

  if idx==2 then
    state={a="title"}
    dialogs:show_edit_dialog("Bookmark Title","Title","")
    return
  end

  local b=data.bookmarks[idx-2]
  if b then open_url(b.url) end
end

function on_long_click(idx)
  if idx==1 then
    state={a="browser"}
    dialogs:show_edit_dialog("Preferred Browser","Package name",data.browser_package)
    return
  end
  if idx<3 then return end
  state={a="menu",i=idx-2}
  dialogs:show_dialog(data.bookmarks[idx-2].title,"Choose action","Edit","Delete")
end

function on_dialog_action(v)
  if v==-1 or not state then state=nil return end
  if state.a=="browser" then
    data.browser_package=tostring(v)
    save()
    ui:show_toast("Browser saved")
    state=nil
  elseif state.a=="title" then
    state.title=tostring(v); state.a="url"
    dialogs:show_edit_dialog("Bookmark URL","https://","https://")
  elseif state.a=="url" then
    local u=tostring(v)
    if not u:match("^https?://") then u="https://"..u end
    table.insert(data.bookmarks,{title=state.title,url=u,color=md.blue_600})
    save(); render(); state=nil
  elseif state.a=="menu" then
    if v==1 then
      state.a="edit_title"
      dialogs:show_edit_dialog("Edit Title","",data.bookmarks[state.i].title)
    else
      table.remove(data.bookmarks,state.i)
      save(); render(); state=nil
    end
  elseif state.a=="edit_title" then
    data.bookmarks[state.i].title=tostring(v)
    state.a="edit_url"
    dialogs:show_edit_dialog("Edit URL","",data.bookmarks[state.i].url)
  elseif state.a=="edit_url" then
    local u=tostring(v)
    if not u:match("^https?://") then u="https://"..u end
    data.bookmarks[state.i].url=u
    save(); render(); state=nil
  end
end
