pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: root
    readonly property string time: {
        const fmt = ShellSettings.use24h ? "ddd dd MMM · HH:mm" : "ddd dd MMM · hh:mm AP";
        Qt.formatDateTime(clock.date, fmt);
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
}
