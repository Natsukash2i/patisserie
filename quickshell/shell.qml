import Quickshell
import "Widgets"

ShellRoot {
    id: shellRoot
    settings.watchFiles: true

    property bool showPowerMenu: false

    WallpaperBackground {}

    TopBar {}
    VolumeOSD {}
    PowerMenu {}

}
