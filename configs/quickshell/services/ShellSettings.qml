pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool use24h: false
    property string currentTheme: "tomorrow-night-eighties"
    property string currentWallpaper: "/usr/share/sectlys-shell/wallpapers/default.png"

    readonly property string configDir: StandardPaths.writableLocation(StandardPaths.HomeLocation) + "/.config/sectlys-shell"
    readonly property string version: "1.0.0"

    readonly property list<string> themes: [
        "tomorrow-night-eighties",
        "tomorrow-night",
        "tomorrow-night-blue",
        "tomorrow-night-bright",
        "tomorrow"
    ]

    property list<var> availableWallpapers: []

    function _writeKey(key, value) {
        const file = root.configDir + "/" + key;
        writeProc.exec(["sh", "-c",
            "mkdir -p '" + root.configDir + "' && printf '%s' '" + String(value).replace(/'/g, "'\\''") + "' > '" + file + "'"
        ]);
    }

    function setTheme(name) {
        root.currentTheme = name;
        root._writeKey("theme", name);
        themeProc.exec(["set-theme", name]);
    }

    function setWallpaper(path) {
        root.currentWallpaper = path;
        root._writeKey("wallpaper", path);
        wallpaperProc.exec(["sh", "-c",
            "pkill swaybg; sleep 0.1; swaybg -m fill -i '" + path.replace(/'/g, "'\\''") + "' &"
        ]);
    }

    function toggle24h() {
        root.use24h = !root.use24h;
        root._writeKey("use24h", root.use24h ? "1" : "0");
    }

    Process { id: writeProc }
    Process { id: themeProc }
    Process { id: wallpaperProc }

    // Load wallpapers from ~/Pictures/Wallpapers/
    Process {
        id: listWallpapers
        command: ["sh", "-c", "ls -1 ~/Pictures/Wallpapers/ 2>/dev/null | grep -iE '\\.(png|jpg|jpeg|webp)$'"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = this.text.trim().split("\n").filter(l => l.length > 0);
                const home = StandardPaths.writableLocation(StandardPaths.HomeLocation);
                root.availableWallpapers = lines.map(f => ({
                    name: f.replace(/\.[^.]+$/, "").replace(/[-_]/g, " "),
                    path: home + "/Pictures/Wallpapers/" + f
                }));
            }
        }
    }

    // Load persisted settings
    Process {
        id: load24h
        command: ["sh", "-c", "cat ~/.config/sectlys-shell/use24h 2>/dev/null || echo 0"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: { root.use24h = this.text.trim() === "1"; }
        }
    }

    Process {
        id: loadTheme
        command: ["sh", "-c", "cat ~/.config/sectlys-shell/theme 2>/dev/null || echo tomorrow-night-eighties"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const t = this.text.trim();
                if (t.length > 0) root.currentTheme = t;
            }
        }
    }

    Process {
        id: loadWallpaper
        command: ["sh", "-c", "cat ~/.config/sectlys-shell/wallpaper 2>/dev/null || echo /usr/share/sectlys-shell/wallpapers/default.png"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const p = this.text.trim();
                if (p.length > 0) root.currentWallpaper = p;
            }
        }
    }
}
