set hostnames to {"1.performance-test.vostoknodes.com", "2.performance-test.vostoknodes.com", "3.performance-test.vostoknodes.com","4.performance-test.vostoknodes.com","5.performance-test.vostoknodes.com","6.performance-test.vostoknodes.com","7.performance-test.vostoknodes.com","8.performance-test.vostoknodes.com","9.performance-test.vostoknodes.com","10.performance-test.vostoknodes.com"}
set num_hosts to count of hostnames

if application "iTerm" is running then
	tell application "iTerm"
		create window with default profile
		tell current tab of current window
			select
			tell current session
				
				-- make the window fullscreen
				tell application "System Events" to key code 36 using command down
				tell application "System Events" to keystroke "+" using command down
				tell application "System Events" to keystroke "+" using command down
				
				repeat with n from 1 to num_hosts
					if n > 1 then
						tell application "System Events" to keystroke "t" using command down
						tell application "System Events" to keystroke "+" using command down
						tell application "System Events" to keystroke "+" using command down
					end if
					delay 1
					write text "ssh " & (item n of hostnames)
				end repeat
			end tell
		end tell
	end tell
else
	activate application "iTerm"
	
end if