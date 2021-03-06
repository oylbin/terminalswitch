-- 启动或者切换Terminal 的applescript脚本
-- 当使用快捷键触发脚本时:
--      如果不存在已经启动的Terminal，那么新启动一个Terminal
--      如果有已经启动的Terminal，且当前窗口不是Terminal，那么切换到Terminal
--      如果有已经启动的Terminal，且当前窗口是Terminal，那么在多个Terminal中循环切换
-- 
-- 可以在用quicksilver、fastscript、Alfred Workflow等工具把这个脚本绑定到自己习惯的快捷键上面。
-- 我用的是 Option + c
--
-- 脚本能正常工作，需要以下设置
-- 1. 系统默认语言设置为英文或者中午。
-- 2. 系统设置中"Universal Access"中的"Enable access for assitive devices"需要被勾选上
-- 3. Terminal的设置里面，把window的title设置勾选上tty，这样可以保证每个terminal window的title都不一样




on array_search(arr, i)
	repeat with idx from 1 to count of arr
		if item idx of arr is i then
			return idx
		end if
	end repeat
	return -1
end array_search

on bring_to_front(window_menu_name, magic_index, window_index)
	tell application "System Events"
		click menu item (magic_index + window_index) of menu window_menu_name of menu bar 1 of process "Terminal"
		tell application "Terminal" to activate
	end tell
end bring_to_front

on get_terminal_list(window_menu_name, magic_index)
	tell application "System Events"
		-- 如果没有正在运行的terminal进程，那么需要先activate
		tell application "Terminal" to activate
		tell process "Terminal"
			tell menu bar 1
				tell menu window_menu_name
					set window_title_list to {}
					set menu_list to get menu items
					if menu_list's length > magic_index then
						set window_list to (items (magic_index + 1) through (menu_list's length) of menu_list)
						repeat with idx from 1 to count of window_list
							set window_title_list's end to value of attribute "AXTitle" of item idx of window_list
						end repeat
					end if
					return window_title_list
				end tell
			end tell
		end tell
	end tell
end get_terminal_list


on get_window_menu_name()
	set system_language to user locale of (get system info)
	if system_language = "zh_cn" then
		return "窗口"
	end if
	return "Window"

end get_window_menu_name

on get_magic_index()
	-- magic_index 的含义是  Terminal 的 Window菜单中 窗口列表项 的起始 index
	-- 即从Terminal Application的Window菜单从上往下数，对应到切换Terminal窗口的菜单项(⌘1, ⌘2 ...)的索引

	set magic_index to 21
	
	-- 如何找出这个数字？
	-- run_script 这个函数中有一个 all_terminal_window  变量，它的意思是当前已经打开的Terminal窗口数组。
	-- 把 run_script 函数中 debug_magic_index 设置为true
	-- 当脚本读出的 all_terminal_window 数组长度正确时，说明 magic_index 这个值就配置正确了。
	-- 如果读出的长度大于实际的窗口数量，说明 magic_index 配置小了
	-- 如果读出的长度小于实际的窗口数量，说明 magic_index 配置大了
	
	-- https://stackoverflow.com/questions/498323/find-mac-osx-version-installed-using-applescript/19595988#19595988
	set _major to system attribute "sys1"
	set _minor to system attribute "sys2"
	
	if _major = 10 then
		if _minor = 7 then
			-- 21 for mac os x 10.7 lion
			set magic_index to 21
		else if _minor = 8 then
			-- 19 for mac os x 10.8 mountain lion
			set magic_index to 19
		else if _minor ≤ 12 then
			-- 20 for mac os x 10.10, 10.11, 10.12
			set magic_index to 20
		else if _minor = 13 then
			-- 21 for mac os x 10.13 
			set magic_index to 21
		else if _minor = 14 then
			set magic_index to 21
		else if _minor = 15 then
			set magic_index to 24
		else
			say "You need set magic index number manually"
			return 0
		end if
	else
		say "You need set magic index number manually"
		return 0
	end if
	return magic_index
end get_magic_index

on run_script()
	
	set debug_magic_index to false
	
	

	set window_menu_name to get_window_menu_name()
	
	set magic_index to get_magic_index()
	if magic_index = 0 then
		return
	end if

	
	tell application "System Events"
		set app_before_activate to name of the first process whose frontmost is true
	end tell
	--say app_before_activate
	
	set all_terminal_window to get_terminal_list(window_menu_name, magic_index)
	
	
	if debug_magic_index then
		say "Increase magic index if your terminal windows count is less than " & all_terminal_window's length
		return
	end if
	
	if all_terminal_window's length = 0 then
		tell application "Terminal"
			do script ""
			activate
		end tell
	else
		-- window 0 是已经打开的所有Terminal窗口中最前面的一个
		set current_terminal_window to name of window 0 of application "Terminal"
		--say current_terminal_window
		set window_index to array_search(all_terminal_window, current_terminal_window)
		
		if app_before_activate is "Terminal" then
			set window_index to window_index + 1
			if window_index > all_terminal_window's length then
				set window_index to 1
			end if
			bring_to_front(window_menu_name, magic_index, window_index)
			--say "前台"
		else
			--say "后台"
			bring_to_front(window_menu_name, magic_index, window_index)
		end if
	end if
end run_script


on alfred_script(q)
	run_script()
end alfred_script
