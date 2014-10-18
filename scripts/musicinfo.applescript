on run argv
	set _name to ""
	set _artist to ""
	set _album to ""
	tell application "System Events"
		if (name of processes) contains "iTunes" then
			tell application "iTunes"
				if player state is playing then
					set _name to name of current track
					set _artist to artist of current track
					set _album to album of current track
				end if
			end tell
		end if
		if (name of processes) contains "Radium" then
			tell application "Radium"
				if playing of player is true then
					set title to song title of player
					-- parse annoying "artist - name (album)" format
					set infoString to do shell script "perl -e '$_=$ARGV[0];s/(.*?) - (.*?)(?: \\(([^\\(]*?)\\))?$/\\1\\t\\2\\t\\3/g;print' " & quoted form of title
					set oldDelim to AppleScript's text item delimiters
					set AppleScript's text item delimiters to "	"
					
					set _name to text item 2 of infoString
					set _artist to text item 1 of infoString
					set _album to text item 3 of infoString
					
					set AppleScript's text item delimiters to oldDelim
				end if
			end tell
		end if
		if (name of processes) contains "VLC" then
			tell application "VLC"
				if playing is true then
					set infoString to name of current item
					set oldDelim to AppleScript's text item delimiters
					set AppleScript's text item delimiters to " - "
					set _name to text item 2 of infoString
					set _artist to text item 1 of infoString
					
					set AppleScript's text item delimiters to oldDelim
				end if
			end tell
		end if
	end tell
	if item 1 of argv = "name" then
		return _name
	else if item 1 of argv = "artist" then
		return _artist
	else if item 1 of argv = "album" then
		return _album
	end if
end run
