-- name = "Widgets switcher"
-- description = "Turns screen widgets on and off when buttons are pressed"
-- type = "widget"
-- arguments_help = "Don't change the arguments directly, use the long click menu."
-- author = "Andrey Gavrilov"
-- version = "2.0"

--constants--

local widgets = {"weather","weatheronly","clock","alarm","worldclock","monitor","traffic","player","apps","appbox","applist","contacts","notify","dialer","timer","stopwatch","mail","notes","tasks","feed","telegram","twitter","calendar","exchange","finance","bitcoin","control","recorder","calculator","empty","bluetooth","map","remote"}

local icons = {"fa:user-clock","fa:sun-cloud","fa:clock","fa:alarm-clock","fa:business-time","fa:network-wired","fa:exchange","fa:play-circle","fa:robot","fa:th","fa:list","fa:address-card","fa:bell","fa:phone-alt","fa:chess-clock","fa:stopwatch","fa:at","fa:sticky-note","fa:calendar-check","fa:rss-square","fa:paper-plane","fa:dove","fa:calendar-alt","fa:euro-sign","fa:chart-line","fa:coins","fa:wifi","fa:microphone-alt","fa:calculator-alt","fa:eraser","fa:head-side-headphones","fa:map-marked-alt","fa:user-tag"}

local names = {"Clock & weather","Weather","Clock","Alarm","Worldclock","Monitor","Traffic","Player","Frequent apps","My apps","App list","Contacts","Notify","Dialer","Timer","Stopwatch","Mail","Notes","Tasks","Feed","Telegram","Twitter","Calendar","Exchange","Finance","Bitcoin","Control panel","Recorder","Calculator","Empty widget","Bluetooth","Map","User widget"}

local style = {"Icons", "Names"}

--variables--
local dialog_id = ""
local item_idx = 0

function on_resume()
  if next(settings:get()) == nil then
    set_default_args()
  end

  ui:set_folding_flag(true)

  local buttons,colors = get_buttons()
  ui:show_buttons(buttons, colors)
end

function on_click(idx)
  local buttons,colors = get_buttons()
  local checkbox_idx = get_checkbox_idx()
  local widget = widgets[checkbox_idx[idx]]

  if aio:is_widget_added(widget) then
    aio:remove_widget(widget)
    colors[idx] = "#909090"
  else
    aio:add_widget(widget)
    colors[idx] = "#1976d2"
  end

  ui:show_buttons(buttons, colors)
end

function on_long_click(idx)
  ui:show_toast(names[get_checkbox_idx()[idx]])
end

function on_dialog_action(data)
  if data == -1 then
    return
  end

  local radio_idx = get_radio_idx()
  local args = data
  table.insert(args, radio_idx)
  settings:set(args)

  on_resume()
end

function on_settings()
  ui:show_checkbox_dialog("Select widgets", names, get_checkbox_idx())
end

--utilities--

function set_default_args()
  local args = {}
  for i = 1, #widgets do
    table.insert(args, i)
  end
  table.insert(args, 1)
  settings:set(args)
end

function get_checkbox_idx()
  local tab = settings:get()
  table.remove(tab, #tab)
  for i = 1, #tab do
    tab[i] = tonumber(tab[i])
  end
  return tab
end

function get_radio_idx()
  local tab = settings:get()
  return tonumber(tab[#tab])
end

function get_buttons()
  local buttons,colors = {},{}
  local checkbox_idx = get_checkbox_idx()
  local radio_idx = get_radio_idx()

  for i = 1, #checkbox_idx do
    if radio_idx == 1 then
      table.insert(buttons, icons[checkbox_idx[i]])
    elseif radio_idx == 2 then
      table.insert(buttons, names[checkbox_idx[i]])
    end
    if aio:is_widget_added(widgets[checkbox_idx[i]]) then
      table.insert(colors, "#1976d2")
    else
      table.insert(colors, "#909090")
    end
  end

  return buttons,colors
end
