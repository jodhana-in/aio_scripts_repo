-- name = "Bookmarks"
-- description = "Simple bookmark manager"
-- type = "widget"
-- author = "OpenAI"
-- version = "0.1"

local json = require("json")
local md = require("md_colors")

local filename = "bookmarks.json"
local bookmarks = {}
local state = nil

local function load()
  local c = files:read(filename)
  if c then
    local ok,data = pcall(json.decode,c)
    if ok and data then bookmarks=data end
  end
end

local function save()
  files:write(filename,json.encode(bookmarks))
end

local function render()
  local names={"fa:plus"}
  local colors={aio:colors().button}
  for _,b in ipairs(bookmarks) do
    table.insert(names,b.title)
    table.insert(colors,b.color or md.blue_600)
  end
  ui:show_buttons(names,colors)
end

function on_resume()
  load()
  render()
end

function on_click(index)
  if index==1 then
    state={action="title"}
    dialogs:show_edit_dialog("New Bookmark","Title","")
    return
  end
  local b=bookmarks[index-1]
  if b then
    app:open_url(b.url)
  end
end

function on_long_click(index)
  if index<2 then return end
  state={action="menu",index=index-1}
  dialogs:show_dialog(bookmarks[index-1].title,"Choose action","Edit","Delete")
end

function on_dialog_action(value)
  if value==-1 then state=nil return end
  if not state then return end

  if state.action=="title" then
    state.title=value
    state.action="url"
    dialogs:show_edit_dialog("Bookmark URL","https://","https://")
  elseif state.action=="url" then
    table.insert(bookmarks,{
      title=state.title,
      url=value,
      color=md.blue_600
    })
    save()
    render()
    state=nil
  elseif state.action=="menu" then
    if value==1 then
      state.action="edit_title"
      dialogs:show_edit_dialog("Edit Title","",bookmarks[state.index].title)
    elseif value==2 then
      table.remove(bookmarks,state.index)
      save()
      render()
      state=nil
    end
  elseif state.action=="edit_title" then
    bookmarks[state.index].title=value
    state.action="edit_url"
    dialogs:show_edit_dialog("Edit URL","",bookmarks[state.index].url)
  elseif state.action=="edit_url" then
    bookmarks[state.index].url=value
    save()
    render()
    state=nil
  end
end
