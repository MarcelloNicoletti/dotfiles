#!/usr/bin/env bash
command -v osascript > /dev/null 2>&1  && osascript -e '
set track_name to ""
set artist_name to ""
set now_playing to false
if application "iTunes" is running then
  tell application "iTunes" to if player state is playing then
    set track_name to name of current track
    set artist_name to artist of current track
    set now_playing to true
  end if
end if

if application "Spotify" is running then
  tell application "Spotify" to if player state is playing then
    set track_name to name of current track
    set artist_name to artist of current track
    set now_playing to true
  end if
end if

if now_playing then
  repeat while length of ("♫ " & track_name & " ♪ " & artist_name & " ♫") > 50
    if length of track_name > length of artist_name then
      set track_name to (text 1 thru -3 of track_name) & "…"
    else
      set artist_name to (text 1 thru -3 of artist_name) & "…"
    end if
  end repeat
  "♫ " & track_name & " ♪ " & artist_name & " ♫"
end if
'
