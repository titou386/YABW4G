# YABW4G
Yet Another Bing's Wallpaper For Gnome

One script to download and set the wallpaper in gnome.

## Usage
Download the script and set on execution flag :
```bash
$ wget https://raw.githubusercontent.com/titou386/YABW4G/main/bing-wallpaper.sh
$ chmod +x bing-wallpaper.sh
```

Add the script in 'Startup Apllications' and restart your session or execute the script. That's all.

```
Usage: bing-wallpaper.sh [OPTION]
  -1              Run once & quit
  -d  DIRECTORY   Destination directory of images
                    Default: /home/$USER/Images
  -h              Display this help message
  -r              Enable high resolution
  -x              Daemon mode
```
> **Note:** Tested on Ubuntu 18.04.5
