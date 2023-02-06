#!/bin/bash

file="./playlists.txt"
declare -A playlists

# Lees bestand en sla gegevens op in associatieve array
while read line; do
  name=$(echo $line | cut -d '|' -f1 | tr -cd '[:alnum:]')
  url=$(echo $line | cut -d '|' -f2)
  playlists["$name"]="$url"
done < $file

function add_playlist {
  read -p "Enter a name for the playlist: " name
  name="$(echo "$name" | tr -cd '[:alnum:]')"
  read -p "Enter the URL for the playlist: " url
  playlists["$name"]="$url"
  echo "$name|$url" >> $file
  exit 0
}

function delete_playlist {
  echo "Select a playlist to delete:"
  select choice in "${!playlists[@]}"; do
    if [ -n "$choice" ]; then
      unset playlists["$choice"]
      temp_file="./temp_file.txt"
      > $temp_file
      for name in "${!playlists[@]}"; do
        echo "$name|${playlists[$name]}" >> $temp_file
      done
      mv $temp_file $file
      break
    else
      echo "Invalid option. Select a playlist:"
    fi
  done
  exit 0
}

echo "Select an option:"
select choice in "${!playlists[@]}" "Add a new playlist" "Delete a playlist"; do
  if [ -n "$choice" ]; then
    if [ "$choice" == "Add a new playlist" ]; then
      add_playlist
    elif [ "$choice" == "Delete a playlist" ]; then
      delete_playlist
    else
      spotdl download "${playlists[$choice]}" --m3u
      break
    fi
  else
    echo "Invalid option. Select an option:"
  fi
done

