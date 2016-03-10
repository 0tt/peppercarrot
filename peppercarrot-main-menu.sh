#!/bin/bash

#: Title       : Pepper&Carrot Main Menu
#: Author      : David REVOY < info@davidrevoy.com >
#: License     : GPL

scriptversion="1.0b"

# DEPENDENCIES :
# * Zenity (for GUI interface)
# * Gnome-terminal ( for launching task )

# Custom preferences
export texteditor="geany"
export filebrowser="nemo"

# Utils
export scriptpath="`dirname \"$0\"`"
export projectname="${PWD##*/}"
export workingpath="${PWD}"
export isodate=$(date +%Y-%m-%d)
export version=$(date +%Y-%m-%d_%Hh%M)
export versiondaily=$(date +%Y%m%d)
export Off=$'\e[0m'
export Purple=$'\e[1;35m'
export Blue=$'\e[1;34m'
export Green=$'\e[1;32m'
export Red=$'\e[1;31m'
export Yellow=$'\e[1;33m'
export White=$'\e[1;37m'
export BlueBG=$'\e[1;44m'
export RedBG=$'\e[1;41m'
export PurpleBG=$'\e[1;45m'
export Black=$'\e[1;30m'

# Config.sh external file (gitignored)
if [ -f "$scriptpath"/config.sh ]; then
  source "$scriptpath"/config.sh
  echo "${Green}* config.sh found${Off}"
  echo "* Welcome $configuser"
else
  echo "${Red}* config.sh not found, creating it${Off}"
  # Write file
  echo '#!/bin/bash' > "$scriptpath"/config.sh
  echo '' >> "$scriptpath"/config.sh
  echo '# Global config' >> "$scriptpath"/config.sh
  echo 'export projectroot="/home/username/peppercarrot"' >> "$scriptpath"/config.sh
  echo '' >> "$scriptpath"/config.sh
  echo '# Uploaders' >> "$scriptpath"/config.sh
  echo 'confighost="ftp.yourhostname.net"' >> "$scriptpath"/config.sh
  echo 'configuser="username"' >> "$scriptpath"/config.sh
  echo 'configpass="password"' >> "$scriptpath"/config.sh
  # Verbose
  echo "${Yellow} ==> done${Off}"
  echo "* please configure your config.sh file now"
  echo "* and launch this script again"
  exit
fi

# Define absolute path to folders in usage
export folder_webcomics="$projectroot"/webcomics
export folder_scripts="$projectroot"/scripts
export folder_wiki="$projectroot"/wiki

# Move folder cursor to webcomic
# zenity --info --text="Debug 1: $folder_webcomics"
cd "$folder_webcomics"

_main_menu()
{
  # Populate the menu with all webcomic folder found
  for directories in $(find $folder_webcomics -maxdepth 1 -type d -printf '%f\n' | sort ); do
    episodefolder=$directories
    if [[ $episodefolder == "ep"* ]]; then
      items+=( "$episodefolder"* )
    fi
  done

  if [ -d "$folder_webcomics/New" ]; then
    items+=( "New"* )
  fi
  items+=( "+ Add a new episode" )
  items+=( " " )
  items+=( "Edit All README.md" )
  items+=( "Upload FTP (low)" )
  items+=( "Upload FTP (hi)" )
  items+=( "Update Wiki" )
  items+=( "Run Filewalker" )
  items+=( "Update .episodes-list.md" )
  items+=( "Render all episodes" )

  menuchoice=$(zenity --list --title='Pepper&Carrot Main Menu' \
              --width=400 --height=570 --window-icon="$folder_scripts/lib/peppercarrot_icon.png" \
              --text='Select an episode or an action' \
              --column='menu' "${items[@]}");

  clear
  
  # Avoid Zenity bug with trailing | on option selected
  menuchoicecleaned=${menuchoice%|*}
}


_sub_menu() 
{
  echo "=> rendering script"
  echo "$folder_webcomics"/"$menuchoicecleaned"/
  
  subitems+=( "★ Render $menuchoicecleaned" )
  subitems+=( " " )
  subitems+=( "Open $menuchoicecleaned folder with $filebrowser" )
  subitems+=( "Open lang folder with $filebrowser" )
  subitems+=( "Open lang folder in a terminal" )
  subitems+=( "Edit README.md" )
  subitems+=( " " )
  subitems+=( "Upload FTP (low)" )
  subitems+=( "Upload FTP (hi)" )
  subitems+=( " " )
  subitems+=( "← Back" )
  
  while :
  do
    submenuchoice=$(zenity --list --title=''$menuchoicecleaned'' \
              --width=400 --height=450 --window-icon="$folder_scripts/lib/peppercarrot_icon.png" \
              --text='Select an action' \
              --column='menu' "${subitems[@]}");
    clear
    submenuchoicecleaned=${submenuchoice%|*}
    
    if [ "$submenuchoicecleaned" = "★ Render $menuchoicecleaned" ]; then
      cd "$folder_webcomics"/"$menuchoicecleaned"/
      gnome-terminal --command="$folder_scripts"/renderfarm.sh &
      
    elif [ "$menuchoicecleaned" = " " ]; then
      echo "${Green}* mistake!!  ${Off}"
      zenity --error --text "You selected a spacer, try again."; echo $?
      # reload homepage
      bash "$folder_scripts"/peppercarrot-main-menu.sh
      
    elif [ "$submenuchoicecleaned" = "Open $menuchoicecleaned folder with $filebrowser" ]; then
      "$filebrowser" "$folder_webcomics"/"$menuchoicecleaned"/ &
    
    elif [ "$submenuchoicecleaned" = "Open lang folder with $filebrowser" ]; then
      "$filebrowser" "$folder_webcomics"/"$menuchoicecleaned"/lang/ &
      
    elif [ "$submenuchoicecleaned" = "Open lang folder in a terminal" ]; then
      gnome-terminal --working-directory="$folder_webcomics"/"$menuchoicecleaned"/lang/ &
      
    elif [ "$submenuchoicecleaned" = "Edit README.md" ]; then
      "$texteditor" "$folder_webcomics"/"$menuchoicecleaned"/lang/README.md &
      
    elif [ "$submenuchoicecleaned" = "Upload FTP (low)" ]; then
      cd $folder_webcomics
      gnome-terminal --command="$folder_scripts"/lowres_uploader.sh
        
    elif [ "$submenuchoicecleaned" = "Upload FTP (hi)" ]; then
      cd $folder_webcomics
      gnome-terminal --command="$folder_scripts"/hires_uploader.sh
      
    else 
    
    # reload homepage
    bash "$folder_scripts"/peppercarrot-main-menu.sh
    break
    exit
    
    fi
  done
}

# Execute
_main_menu

# Filter answers
if [ "$menuchoicecleaned" = " " ]; then
  echo "${Green}* mistake!!  ${Off}"
  zenity --error --text "You selected a spacer, try again."; echo $?
  # reload homepage
  bash "$folder_scripts"/peppercarrot-main-menu.sh
    
elif [ "$menuchoicecleaned" = "" ]; then
  # OK or Cancel is pressed without selection, we exit.
  exit
    
elif [ "$menuchoicecleaned" = "Edit All README.md" ]; then
  # Loop on all episode folder
  for directories in $(find $folder_webcomics -maxdepth 1 -type d -printf '%f\n' | sort ); do
    episodefolder=$directories
    if [[ $episodefolder == "ep"* ]]; then
      # Then open README.md in text-editor
      "$texteditor" "$folder_webcomics"/"$episodefolder"/lang/README.md &
    fi
  done
  # Reload homepage
  bash "$folder_scripts"/peppercarrot-main-menu.sh

elif [ "$menuchoicecleaned" = "Render all episodes" ]; then
  # loop on episode
  for directories in $(find $folder_webcomics -maxdepth 1 -type d -printf '%f\n' | sort ); do
    episodefolder=$directories
    if [[ $episodefolder == *"ep"* ]]; then
      cd "$folder_webcomics"/"$episodefolder"/
      gnome-terminal --command="$folder_scripts"/renderfarm.sh &
      # wait 5sec before executing another render, for CPU friendlyness
      sleep 5
    fi
  done
    
elif [ "$menuchoicecleaned" = "Update .episodes-list.md" ]; then
  # Clean old version
  rm "$folder_webcomics"/.episodes-list.md
  
  # Loop on episodes and output a sort of listing of episode names.
  for directories in $(find $folder_webcomics -maxdepth 1 -type d -printf '%f\n' | sort ); do
    episodefolder=$directories
    if [[ $episodefolder == *"ep"* ]]; then
      cd "$folder_webcomics"
      echo "$episodefolder" >> "$folder_webcomics"/.episodes-list.md
    fi
  done
  
elif [ "$menuchoicecleaned" = "Upload FTP (low)" ]; then
  cd "$folder_webcomics"
  gnome-terminal --command="$folder_scripts"/lowres_uploader.sh
    
elif [ "$menuchoicecleaned" = "Upload FTP (hi)" ]; then
  cd "$folder_webcomics"
  gnome-terminal --command="$folder_scripts"/hires_uploader.sh
  
elif [ "$menuchoicecleaned" = "Update Wiki" ]; then
  cd "$folder_wiki"
  gnome-terminal --command="$folder_scripts"/wiki_uploader.sh
  
elif [ "$menuchoicecleaned" = "Run Filewalker" ]; then
  cd "$projectroot"
  gnome-terminal --command="$folder_scripts"/filewalker.sh
      
elif [ "$menuchoicecleaned" = "+ Add a new episode" ]; then
  cd "$folder_webcomics"
  gnome-terminal --command="$folder_scripts"/episode-creator.sh

else 
  # we got an episode, not an action.
  # execute submenu!
  _sub_menu
fi
