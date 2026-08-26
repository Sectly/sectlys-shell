pragma Singleton

import Quickshell.Io

// Tomorrow Night
JsonObject {
    property Colors colors: Colors {}
    property Rounding rounding: Rounding {}
    property Spacing spacing: Spacing {}
    property Padding padding: Padding {}
    property FontFamily font: FontFamily {}
    property FontSize fontSize: FontSize {}
    property Anim anim: Anim {}
    property Transparency transparency: Transparency {}

    component Colors: JsonObject {
        property string background: "#1d1f21"
        property string error: "#cc6666"
        property string error_container: "#7a1a1a"
        property string inverse_on_surface: "#1d1f21"
        property string inverse_primary: "#c8a040"
        property string inverse_surface: "#c5c8c6"
        property string on_background: "#c5c8c6"
        property string on_error: "#1d1f21"
        property string on_error_container: "#f2b8b8"
        property string on_primary: "#1d1f21"
        property string on_primary_container: "#1d1f21"
        property string on_primary_fixed: "#1d1f21"
        property string on_primary_fixed_variant: "#282a2e"
        property string on_secondary: "#1d1f21"
        property string on_secondary_container: "#c5c8c6"
        property string on_secondary_fixed: "#1d1f21"
        property string on_secondary_fixed_variant: "#373b41"
        property string on_surface: "#c5c8c6"
        property string on_surface_variant: "#969896"
        property string on_tertiary: "#1d1f21"
        property string on_tertiary_container: "#c5c8c6"
        property string on_tertiary_fixed: "#1d1f21"
        property string on_tertiary_fixed_variant: "#373b41"
        property string outline: "#969896"
        property string outline_variant: "#373b41"
        property string primary: "#f0c674"
        property string primary_container: "#c8a040"
        property string primary_fixed: "#f5d58f"
        property string primary_fixed_dim: "#f0c674"
        property string scrim: "#000000"
        property string secondary: "#8abeb7"
        property string secondary_container: "#373b41"
        property string secondary_fixed: "#8abeb7"
        property string secondary_fixed_dim: "#6a9e97"
        property string shadow: "#000000"
        property string source_color: "#f0c674"
        property string surface: "#282a2e"
        property string surface_bright: "#4a4f59"
        property string surface_container: "#282a2e"
        property string surface_container_high: "#373b41"
        property string surface_container_highest: "#444851"
        property string surface_container_low: "#222427"
        property string surface_container_lowest: "#1d1f21"
        property string surface_dim: "#1d1f21"
        property string surface_tint: "#f0c674"
        property string surface_variant: "#373b41"
        property string tertiary: "#81a2be"
        property string tertiary_container: "#373b41"
        property string tertiary_fixed: "#81a2be"
        property string tertiary_fixed_dim: "#5f7fa0"
    }

    component Rounding: JsonObject {
        property real scale: 1
        property int small: 5 * scale
        property int normal: 10 * scale
        property int large: 20 * scale
        property int full: 1000 * scale
    }

    component Spacing: JsonObject {
        property real scale: 1
        property int small: 7 * scale
        property int smaller: 10 * scale
        property int normal: 12 * scale
        property int larger: 15 * scale
        property int large: 20 * scale
    }

    component Padding: JsonObject {
        property real scale: 1
        property int small: 5 * scale
        property int smaller: 7 * scale
        property int normal: 10 * scale
        property int larger: 12 * scale
        property int large: 15 * scale
    }

    component FontFamily: JsonObject {
        property string sans: "Noto Sans"
        property string mono: "JetBrainsMono Nerd Font"
    }

    component FontSize: JsonObject {
        property real scale: 1
        property int xs: 12 * scale
        property int sm: 14 * scale
        property int base: 16 * scale
        property int lg: 18 * scale
        property int xl: 20 * scale
        property int xxl: 24 * scale
        property int xxxl: 30 * scale
    }

    component FontStuff: JsonObject {
        property FontFamily family: FontFamily {}
        property FontSize size: FontSize {}
    }

    component AnimCurves: JsonObject {
        property list<real> emphasized: [0.05, 0, 2 / 15, 0.06, 1 / 6, 0.4, 5 / 24, 0.82, 0.25, 1, 1, 1]
        property list<real> emphasizedAccel: [0.3, 0, 0.8, 0.15, 1, 1]
        property list<real> emphasizedDecel: [0.05, 0.7, 0.1, 1, 1, 1]
        property list<real> standard: [0.2, 0, 0, 1, 1, 1]
        property list<real> standardAccel: [0.3, 0, 1, 1, 1, 1]
        property list<real> standardDecel: [0, 0, 0, 1, 1, 1]
        property list<real> expressiveFastSpatial: [0.42, 1.67, 0.21, 0.9, 1, 1]
        property list<real> expressiveDefaultSpatial: [0.38, 1.21, 0.22, 1, 1, 1]
        property list<real> expressiveEffects: [0.34, 0.8, 0.34, 1, 1, 1]
    }

    component AnimDurations: JsonObject {
        property real scale: 1
        property int small: 200 * scale
        property int normal: 400 * scale
        property int large: 600 * scale
        property int extraLarge: 1000 * scale
        property int expressiveFastSpatial: 350 * scale
        property int expressiveDefaultSpatial: 500 * scale
        property int expressiveEffects: 200 * scale
    }

    component Anim: JsonObject {
        property AnimCurves curves: AnimCurves {}
        property AnimDurations durations: AnimDurations {}
    }

    component Transparency: JsonObject {
        property bool enabled: false
        property real base: 0.85
        property real layers: 0.4
    }
}
