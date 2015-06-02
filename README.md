# nmfnms
Alienesque icon theme originally shipped with bespin

## Requirements
* Inkscape (to render the png's from the svg's)
* Imagemagick (to postprocess the icons colors, halo, shadow etc.)

## Create the theme
Edit a "config" file (for an easy start, "cp config.example config", then adjust "config") and run "./generate_kde_icons.sh" (this may initially take some time)

NOTICE that on further runs, only new/updated icons are regenerated, so do yourself a favor and do not remove the git repository or the created icon theme subdiretory in it.

## Contribute
Since multiple icons may be represented by the same image, the build script generates a pool of png's and symlinks the icons. This relation is controlled by the file alias.txt where you want to enlist your new icon. See alias.README for more details.

Run "./check_missing.sh" for a (pretty vast) list of so far not represented icons.

./dumb_icon_generator.sh just creates png's for every svg in all icon sizes without resolving proper icon names