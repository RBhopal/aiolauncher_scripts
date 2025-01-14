# Introduction

Starting from version 4.0, AIO Launcher supports scripts, or rather special widgets written in the [Lua scripting language ](https://en.wikipedia.org/wiki/Lua_(programming_language)). Such widgets should be placed in the directory `/sdcard/Android/data/ru.execbit.aiolauncher/files/`. They can then be added to the screen using the "Scripts" section of the settings or using the side menu.

The possibilities of scripts are limited, but they can be used to expand the functionality of the application almost limitlessly (see examples in this repository).

# Lifecycle callbacks

The work of any script begins with one of the three described functions. Main work should be done in one of them.

* `on_resume()` - called every time you return to the desktop;
* `on_alarm()` - called when returning to the desktop, provided that more than 30 minutes have passed since the last call;
* `on_tick()` - called every second while the launcher is on the screen.

For most network scripts `on_alarm()` should be used.

# User Interface

* `ui:show_text(string, [no_html])` - displays plain text in widget, repeated call will erase previous text, if second argument is true HTML formatting will be disabled;
* `ui:show_lines(table, [table])` - displays a list of lines with the sender (in the manner of a mail widget), the second argument (optional) - the corresponding senders (formatting in the style of a mail widget);
* `ui:show_table(table, [main_column], [centering], [folded_string])` - displays table, first argument: table of tables, second argument: main column, it will be stretched, occupying main table space (if argument is zero or not specified all table elements will be stretched evenly), third argument: boolean value indicating whether table cells should be centered, fourth argument: row to be shown in folded mode;
* `ui:show_buttons(names, [colors])` - displays a list of buttons, the first argument is a table of strings, the second is an optional argument, a table of colors in the format #XXXXXX;
* `ui:show_progress_bar(text, current_value, max_value, [color])` - shows the progress bar;
* `ui:show_chart(points, [format], [title], [show_grid], [folded_string], [copyright])` - shows the chart, points - table of coordinate tables, format - data format (see below), title - chart name, show\_grid - grid display flag, folded\_string - string for the folded state (otherwise the name will be shown), copyright - string displayed in the lower right corner;
* `ui:show_toast(string)` - shows informational message in Android style;
* `ui:get_default_title()` - returns the standard widget title (set in the `name` metadata);
* `ui:set_title()` - changes the title of the widget, should be called before the data display function (empty line - reset to the standard title);
* `ui:set_folding_flag(boolean)` - sets the flag of the folded mode of the widget, the function should be called before the data display functions;
* `ui:get_folding_flag()` - returns folding flag;
* `ui:get_colors()` - returns table with current theme colors;

When you click on any element of the interface, the `on_click(number)` callback will be executed, where number is the ordinal number of the element. A long click calls `on_long_click(number)`. For example, if you use `ui:show_buttons` to show three buttons, then clicking the first button will call `on_click` with argument 1, the second with arguments 2, and so on. If there is only one element on the screen, the argument will always be equal to one and can be omitted.

The `ui:show_chart()` function takes a string as its third argument to format the x and y values on the screen. For example, the string `x: date y: number` means that the X-axis values should be formatted as dates, and the Y-values should be formatted as a regular number. There are four formats in total:

* `number` - an ordinary number with group separation;
* `float` - the same, but with two decimal places;
* `date` - date in day.month format;
* `time` - time in hours: minutes format.

The functions `ui:show_text()` and `ui:show_lines()` support many HTML tags. For example:

```
First line<br/> Second line
<b>Bold Line</b><br/><i>Oblique Line</i>
<font color="red">Red text</font>
<span style="background-color: #00FF00">Text on green background</span>
```

The `ui:show_buttons()` function supports Fontawesome icons. Simply specify `fa:icon_name` as the button name, for example: `fa:play`.

# Dialogs

* `ui:show_dialog(title, text, [button1_text], [button2_text])` - show dialog, the first argument is the title, the second is the text, button1\_text is the name of the first button, button2\_text is the name of the second button;
* `ui:show_edit_dialog(title, [text], [default_value])` - show the dialog with the input field: title - title, text - signature, default\_value - standard value of the input field;
* `ui:show_radio_dialog (title, lines, [index])` - show a dialog with a choice: title - title, lines - table of lines, index - index of the default value;
* `ui:show_checkbox_dialog(title, lines, [table])` - show dialog with selection of several elements: title - title, lines - table of lines, table - table default values.

Dialog button clicks should be handled in the `on_dialog_action(number)` callback, where 1 is the first button, 2 is the second button, and -1 is nothing (dialog just closed). `ui:show_radio_dialog()` returns the index of the selected item or -1 in case the cancel button was pressed. `ui:show_checkbox_dialog()` returns the table of indexes or -1. `ui:show_edit_dialog()` returns text or -1.

If the first argument of the dialog contains two lines separated by `\n`, the second line becomes a subheading.

# Context menu

* `ui:show_context_menu(table)` - function shows the context menu. Function takes a table of tables with icons and menu item names as its argument. For example, the following code will prepare a context menu of three items:

```
ui:show_context_menu({
    { "share", "Menu item 1" },
    { "copy",  "Menu item 2" },
    { "trash", "Menu item 3" },
})
```

Here `share`, `copy` and `trash` are the names of the icons, which can be found at [Fontawesome](https://fontawesome.com/).

When you click on any menu item, the collab `on_context_menu_click(item_idx)` will be called, where `item\_idx` is the index of the menu item.

# System

* `system:open_browser(url)` - opens the specified URL in a browser or application that can handle this type of URL;
* `system:exec(string)` - executes a shell command;
* `system:su(string)` - executes a shell command as root;
* `system:get_location()` - returns the location in the table with two values (location request is NOT executed, the value previously saved by the system is used);
* `system:copy_to_clipboard(string)` - copies the string to the clipboard;
* `system:get_from_clipboard()` - returns a string from the clipboard:
* `system:vibrate(milliseconds)` - vibrate;
* `system:alarm_sound(seconds)` - make alarm sound;
* `system:share_text(string)` - opens the "Share" system dialog;
* `system:get_lang()` - returns the language selected in the system;
* `system:get_tz_offset()` - returns TimeZone offset in seconds;
* `system:get_battery_info()` - returns table with battery info;
* `system:get_system_info()` - returns table with system info;

The result of executing a shell command is sent to the `on_shell_result(string)` callback.

# Launcher control

* `aio:do_action(string)` - performs an AIO action ([more](https://aiolauncher.app/api.html));
* `aio:add_widget(string)` - adds an embedded widget, script widget or clone of an existing widget to the screen;
* `aio:remove_widget(string)` - removes the built-in widget or script widget from the screen (note: additional widgets will also be removed);
* `aio:is_widget_added(string)` - checks if the widget is added to the screen;

# Application management

* `apps:get_list([sort_by], [no_hidden])` - returns the package table of all installed applications, `sort_by` - sort option (see below), `no_hidden` - true if no hidden applications are needed;
* `apps:get_name(package)` - returns application name;
* `apps:get_color(package)` - returns the color of the application in #XXXXXXXX format;
* `apps:launch(package)` - launches the application;
* `apps:show_edit_dialog(package)` - shows edit dialog of the application.

Sorting options:

* `abc` - alphabetical (default);
* `launch_count` - by number of launches;
* `launch_time` - by launch time;
* `install_time` - by installation time.

Any application-related events (installation, removal, name change, etc.) will call the `on_apps_changed()` callback.

# Network

* `http:get(url, [id])` - executes an HTTP GET request, id - the request identifier string (see below);
* `http:post(url, body, media_type, [id])` - executes an HTTP POST request;
* `http:put(url, body, media_type, [id])` - executes an HTTP request;
* `http:delete(url, [id])` - executes an HTTP DELETE request;
* `http:set_headers(table)` - sets the headers for **all** subsequent network requests; the argument is a table with strings like "Cache-Control: no-cache".

These functions do not return any value, but instead call the `on_network_result(string, [code])` callback. The first argument is the body of the response, the second (optional) is the code (200, 404, etc.).

If `id` was specified in the request, then the function will call `on_network_result_$id(string, [code])` instead of the callback described above. That is, if the id is "server1", then the callback will look like `on_network_result_server1(string, [code])`.

# Calendar

* `calendar:get_events([start_date], [end_date], [cal_table])` - returns table of event tables of all calendars, start\_date - event start date, end\_date - event end date, cal\_table - calendar ID table;
* `calendar:get_calendars()` - returns table of calendars tables;
* `calendar:show_event_dialog(id)` - opens an event in the system calendar.

Event table format:

* `id` - event ID;
* `calendar_id` - calendar ID;
* `title` - title of the event;
* `description` - description of the event;
* `location` - address of the event by string;
* `begin` - start time of the event (in seconds);
* `end` - time of the event end (in seconds);
* `all_day` - boolean value, which means that the event lasts all day.

Calendar table format:

* `id` - calendar identifier;
* `name` - name of the calendar;
* `color` - color of the calendar in the format #XXXXXXXX.

# Phone

* `phone:get_contacts()` - returns table of phone contacts;
* `phone:make_call(number)` - dial the number in the dialer;
* `phone:send_sms(number, [text])` - open SMS application and enter the number, optionally enter text;
* `phone:show_contact_dialog(id)` - open contact dialog;

Contacts table format:

* `id` - contact id;
* `lookup_key` - unique contact identifier;
* `name` - contact name;
* `number` - contact number.

# Settings

* `settings:get()` - returns the settings table in an array of words format;
* `settings:set(table)` - saves the settings table in an array of words format;
* `settings:get_kv()` - returns the settings table in `key=value` format;
* `settings:set_kv(table)` - saves settings table in the format `key=value`;
* `settings:show_dialog()` - show settings change dialog.

User can change settings through the dialog, which is available by clicking on the "gear" in the edit menu of the widget. If in the widget metadata there is a field `arguments_help`, its value will be shown in the edit dialog. If there is a field `arguments_default` - it will be used to get default arguments.

The standard edit dialog can be replaced by your own if you implement the `on_settings()` function.

# Data processing

* `ajson:get_value(string, string)` - gets the specified value from JSON; the first argument is a JSON string, the second is an instruction to get the value.

Unlike classic JSON parsers, this function is not intended for parsing, but for retrieving single values. For example, there is the following JSON:

```
{
  "type": "success",
  "value": {
    "id": 344,
    "joke": "Aliens DO indeed exist. They just know better than to visit a planet that Chuck Norris is on.",
    "categories": []
  }
}
```

We need to extract string "joke" from it. From the JSON text, you can see that this string is contained within the "value" object, and this object itself is inside the main JSON object. In other words, to retrieve the required string, we need to "open" the main JSON object, then "open" the "value" object and find the string "joke" in it. In code, it will look like this:

```
joke = ajson:get_value(result, "object object:value string:joke")
```

The full text of the script may look like this:

```
function on_alarm()
    net:get_text("http://api.icndb.com/jokes/random")
end

function on_network_result(result)
    local joke = ajson:get_value(result, "object object:value string:joke")
    aio:show_text(joke)
end
```

Please note that the last element of the line should always be an instruction for extracting primitive data types:

* `string:name`
* `int:name`
* `double:name`
* `boolean:name`

Also, instead of `object`, you can use `array` if the JSON contains an array.

To summarize: ajson works well (and very fast) when you need to retrieve one or two values. If you need to get a large amount of data (or all data) from JSON, then it is better to use the `json.lua` library (see below). It turns JSON into a set of easy-to-use nested Lua tables.

# Other

AIO Launcher includes the LuaJ 3.0.1 interpreter (compatible with Lua 5.2) with a standard set of modules: `bit32`, `coroutine`, `math`, `os`, `string`, `table`.

The modules `io` and `package` are excluded from the distribution for security reasons, the module `os` has been cut in functionality. Only the following functions are available: `os.clock()`, `os.date()`, `os.difftime()` and `os.time()`.

The standard Lua API is extended with the following features:

* `string:split(delimeter)` - splits the string using the specified delimiter and returns a table;
* `string:replace(regexp, string)` - replaces the text found by the regular expression with another text;
* `slice(table, start, end)` - returns the part of the table starting with the `start` index and ending with `end` index;
* `get_index(table, value)` - returns the index of the table element;
* `get_key(table, value)` - returns the key of the table element;
* `round(x, n)` - rounds the number;

The kit also includes:

* `md_colors` - Material Design color table module (source is in this repository, [help](https://materialui.co/colors));
* `url` - a module with functions for encoding / decoding a string in a URL from the Lua Penlight library;
* [utf8](https://gist.github.com/Stepets/3b4dbaf5e6e6a60f3862) - UTF-8 module from Lua 5.3;
* [luaDate](https://github.com/Tieske/date) - functions for working with time;
* [LuaFun](https://github.com/luafun/luafun) - high-performance functional programming library for Lua;
* [json.lua](https://github.com/rxi/json.lua) - JSON parser;
* [Lua-Simple-XML-Parser](https://github.com/Cluain/Lua-Simple-XML-Parser) - XML parser (see example `xml-test.lua`).

# Metadata

In order for AIO Launcher to correctly display information about the script in the script directory and correctly display the title, you must add metadata to the beginning of the script. For example:

```
- name = "Covid info"
- description = "Cases of illness and death from covid"
- data_source = "https://covid19api.com"
- arguments_help = "Specify the country code"
- arguments_default = "RU"
- type = "widget"
- author = "Evgeny Zobnin (zobnin@gmail.com)"
- version = "1.0"
```

# Contribution

If you want your scripts to be included in the repository and the official AIO Launcher kit - create a pull request or email me: zobnin@gmail.com. Also I am always ready to answer your questions and discuss extending the current API.
