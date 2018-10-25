#!/usr/bin/env bash
command -v osascript > /dev/null 2>&1  && osascript <<SCPT
#!/usr/bin/env osascript

set track_name to ""
set artist_name to ""
set now_playing to false
set extra_length to 7

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
  set track_length to length of track_name
  set artist_length to length of artist_name
  repeat while (extra_length + track_length + artist_length) > 47
    if track_length > artist_length then
      set track_length to track_length - 1
    else
      set artist_length to artist_length - 1
    end if
  end repeat

  if track_length < length of track_name then
    log track_length - 1
    log length of track_name
    set track_name to (text 1 thru (track_length - 1) of track_name) & "…"
  end if

  if artist_length < length of artist_name then
    set artist_name to (text 1 thru (artist_length - 1) of artist_name) & "…"
  end if

  "♫ " & track_name & " ♪ " & artist_name & " ♫"
end if
SCPT
