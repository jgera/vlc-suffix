function descriptor()
	return {
		title = "VLC Add Suffix to File";
		version = "0.1";
		author = "Jatin Gera";
		url = "https://github.com/surrim/vlc-suffix/";
		shortdesc = "&Suffix File";
		description = [[
<h1>vlc-Suffix</h1>"
When you're playing a file, use VLC Suffix to
add ! to the current file from your playlist and <b>disk</b> with one click.<br>
This extension has been tested on windows only.
The author is not responsible for damage caused by this extension.
		]];
	}
end

function fileExists(file)
	return io.popen("if exist " .. file .. " (echo 1)") : read "*l" == "1"
end

function sleep(seconds)
	local t0 = os.clock()
	local tOriginal = t0
	while os.clock() - t0 <= seconds and os.clock() >= tOriginal do end
end

function windowsSuffix(file, trys, pause)
	if not fileExists("\"" .. file .. "\"") then return nil, "File does not exist" end
	for i = trys, 1, -1
	do
		path,filname,ext = string.match(file, "(.-)([^\\]-([^%.]+))$")
		vlc.msg.info("filename: " .. filname)

		-- vlc.msg.info("renameing: " .. filname .. "to !" .. filname)
		-- s = 'ren "' .. filname  .. '" "!' .. filname .. '"'
		
		-- vlc.msg.info(s)
		retval, err = os.rename(filname, "!" .. filname)
		-- retval, err = os.execute(s)
		
		if retval == true then
			return true
		end
		sleep(pause)
	end
	return {nil, "Unable to delete file"}
end

function removeItem()
	local id = vlc.playlist.current()
	vlc.playlist.delete(id)
	vlc.playlist.gotoitem(id + 1)
	vlc.deactivate()
end

function activate()
	local item = vlc.input.item()
	local uri = item:uri()
	uri = string.gsub(uri, "^file:///", "")
	uri = vlc.strings.decode_uri(uri)
	vlc.msg.info("[vlc-rename] renaming: " .. uri)

	if (package.config:sub(1, 1) == "/") then -- not windows
		-- TODO: add support for other platforms
		-- for linux this section will delete the file 
		-- for adding suffix to file please update here
		-- retval, err = os.execute("trash-put --help > /dev/null")
		-- if (retval ~= nil) then
		-- 	uri = "/" .. uri
		-- 	retval, err = os.execute("trash-put \"" .. uri .. "\"")
		-- else
		-- 	retval, err = os.execute("rm --help > /dev/null")
		-- 	if (retval ~= nil) then
		-- 		uri = "/" .. uri
		-- 		retval, err = os.execute("rm \"" .. uri .. "\"")
		-- 	end
		-- end
		-- if (retval ~= nil) then removeItem() end
	else -- windows
		removeItem() -- remove from playlist first so the file isnt locked by vlc
		uri = string.gsub(uri, "/", "\\")
		retval, err = windowsSuffix(uri, 3, 1)
		
	end

	if (retval == nil) then
		vlc.msg.info("[vlc-suffix] error: " .. err)
		d = vlc.dialog("VLC suffix")
		d:add_label("Could not rename \"" .. uri .. "\"", 1, 1, 1, 1)
		d:add_label(err, 1, 2, 1, 1)
		d:add_button("OK", click_ok, 1, 3, 1, 1)
		d:show()
	end
end

function click_ok()
	d:delete()
	vlc.deactivate()
end

function deactivate()
	vlc.deactivate()
end

function close()
	deactivate()
end

function meta_changed()
end
