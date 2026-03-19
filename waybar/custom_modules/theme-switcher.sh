#!/bin/bash

# Theme switcher script for Waybar, nvim, kitty, fastfetch, wofi, and Zen browser

WAYBAR_DIR="$HOME/.config/waybar"
NVIM_CHADRC="$HOME/.config/nvim/lua/chadrc.lua"
KITTY_DIR="$HOME/.config/kitty"
FASTFETCH_DIR="$HOME/.config/fastfetch"
LEGCORD_DIR="$HOME/.config/legcord"
STARSHIP_DIR="$HOME/.config"
WALLPAPER_DIR="$HOME/hyprlandNord/images"
HYPR_DIR="$HOME/.config/hypr"
ZEN_PROFILE_DIR="$HOME/.zen/hy1zcw38.Default (release)"
WOFI_DIR="$HOME/.config/wofi"
THEME_FILE="$HOME/.config/waybar/.current_theme"

# Function to switch Waybar theme
switch_waybar_theme() {
    local theme=$1
    if [ -f "$WAYBAR_DIR/style-$theme.css" ]; then
        ln -sf "$WAYBAR_DIR/style-$theme.css" "$WAYBAR_DIR/style.css"
        return 0
    fi
    return 1
}

# Function to switch nvim theme
switch_nvim_theme() {
    local theme=$1
    local nvim_theme_name=""

    case $theme in
        nord)
            nvim_theme_name="nord"
            ;;
        tokyonight)
            nvim_theme_name="tokyonight"
            ;;
    esac

    # Update chadrc.lua
    if [ -f "$NVIM_CHADRC" ]; then
        sed -i "s/theme = \".*\"/theme = \"$nvim_theme_name\"/" "$NVIM_CHADRC"

        # Regenerate NvChad theme cache (critical for theme to apply!)
        nvim --headless -c "lua require('base46').compile()" -c "qa" 2>/dev/null || true

        # Verify the change worked
        if grep -q "theme = \"$nvim_theme_name\"" "$NVIM_CHADRC"; then
            return 0
        fi
    fi
    return 1
}

# Function to switch kitty theme
switch_kitty_theme() {
    local theme=$1
    if [ -f "$KITTY_DIR/kitty-$theme.conf" ]; then
        ln -sf "$KITTY_DIR/kitty-$theme.conf" "$KITTY_DIR/kitty.conf"
        # Reload all kitty instances
        pkill -SIGUSR1 kitty 2>/dev/null || true
        return 0
    fi
    return 1
}

# Function to switch fastfetch theme
switch_fastfetch_theme() {
    local theme=$1
    if [ -f "$FASTFETCH_DIR/config-$theme.jsonc" ]; then
        ln -sf "$FASTFETCH_DIR/config-$theme.jsonc" "$FASTFETCH_DIR/config.jsonc"
        return 0
    fi
    return 1
}

# Function to switch legcord theme
switch_legcord_theme() {
    local theme=$1
    local css_source="$LEGCORD_DIR/themes/quickCss-$theme.css"
    local css_target="$LEGCORD_DIR/quickCss.css"

    if [ -f "$css_source" ]; then
        # Copy the theme file to quickCss.css (this is the file legcord reads)
        cp -f "$css_source" "$css_target" || return 1

        # Ensure proper permissions
        chmod 644 "$css_target"

        # Verify the copy worked
        if ! grep -q "@name.*$theme" "$css_target" 2>/dev/null; then
            return 1
        fi

        # Kill legcord to force reload (user must manually restart)
        pkill -9 legcord 2>/dev/null || true
        return 0
    fi
    return 1
}

# Function to switch starship theme
switch_starship_theme() {
    local theme=$1
    if [ -f "$STARSHIP_DIR/starship-$theme.toml" ]; then
        ln -sf "$STARSHIP_DIR/starship-$theme.toml" "$STARSHIP_DIR/starship.toml"
        return 0
    fi
    return 1
}

# Function to switch wallpaper
switch_wallpaper() {
    local theme=$1
    local wallpaper=""

    case $theme in
        nord)
            wallpaper="$WALLPAPER_DIR/murky_peaks.jpg"
            ;;
        tokyonight)
            wallpaper="$WALLPAPER_DIR/tnight.jpg"
            ;;
    esac

    if [ -f "$wallpaper" ] && command -v swww &> /dev/null; then
        swww img "$wallpaper" --transition-type fade --transition-duration 2
        return 0
    fi
    return 1
}

# Function to switch hyprland colors
switch_hyprland_colors() {
    local theme=$1

    if [ -f "$HYPR_DIR/colors-$theme.conf" ]; then
        ln -sf "$HYPR_DIR/colors-$theme.conf" "$HYPR_DIR/colors.conf"
        # Reload hyprland config
        hyprctl reload > /dev/null 2>&1
        return 0
    fi
    return 1
}

# Function to switch Zen browser color scheme
switch_zen_colors() {
    local theme=$1
    local chrome_dir="$ZEN_PROFILE_DIR/chrome"
    local userchrome="$chrome_dir/userChrome.css"
    local theme_css="$chrome_dir/userChrome-$theme.css"

    # Check if theme CSS file exists
    if [ ! -f "$theme_css" ]; then
        return 1
    fi

    # Create chrome directory if it doesn't exist
    mkdir -p "$chrome_dir"

    # Create or update symlink to theme CSS
    ln -sf "userChrome-$theme.css" "$userchrome"

    # Restart Zen browser to apply changes
    pkill -f zen-bin 2>/dev/null || true

    return 0
}

# Function to switch wofi theme
switch_wofi_theme() {
    local theme=$1
    if [ -f "$WOFI_DIR/style-$theme.css" ]; then
        ln -sf "style-$theme.css" "$WOFI_DIR/style.css"
        return 0
    fi
    return 1
}

# Function to show theme menu
show_menu() {
    local current_theme=$(cat "$THEME_FILE" 2>/dev/null || echo "nord")

    # Create menu options with current theme marked
    local nord_label="Nord"
    local tokyo_label="Tokyo Night"

    if [ "$current_theme" = "nord" ]; then
        nord_label="✓ Nord"
    elif [ "$current_theme" = "tokyonight" ]; then
        tokyo_label="✓ Tokyo Night"
    fi

    # Show wofi menu
    chosen=$(printf "%s\n%s" "$nord_label" "$tokyo_label" | wofi --dmenu --prompt "Select Theme" --width 250 --height 120)

    case $chosen in
        *"Nord"*)
            apply_theme "nord"
            ;;
        *"Tokyo Night"*)
            apply_theme "tokyonight"
            ;;
    esac
}

# Function to apply theme
apply_theme() {
    local theme=$1

    # Switch all application themes (order matters!)
    echo "Applying $theme theme..." > /tmp/theme-switch.log

    switch_waybar_theme "$theme" && echo "✓ Waybar" >> /tmp/theme-switch.log || echo "✗ Waybar" >> /tmp/theme-switch.log
    switch_nvim_theme "$theme" && echo "✓ nvim" >> /tmp/theme-switch.log || echo "✗ nvim" >> /tmp/theme-switch.log
    switch_kitty_theme "$theme" && echo "✓ Kitty" >> /tmp/theme-switch.log || echo "✗ Kitty" >> /tmp/theme-switch.log
    switch_fastfetch_theme "$theme" && echo "✓ Fastfetch" >> /tmp/theme-switch.log || echo "✗ Fastfetch" >> /tmp/theme-switch.log
    switch_legcord_theme "$theme" && echo "✓ Legcord" >> /tmp/theme-switch.log || echo "✗ Legcord" >> /tmp/theme-switch.log
    switch_starship_theme "$theme" && echo "✓ Starship" >> /tmp/theme-switch.log || echo "✗ Starship" >> /tmp/theme-switch.log
    switch_wallpaper "$theme" && echo "✓ Wallpaper" >> /tmp/theme-switch.log || echo "✗ Wallpaper" >> /tmp/theme-switch.log
    switch_hyprland_colors "$theme" && echo "✓ Hyprland" >> /tmp/theme-switch.log || echo "✗ Hyprland" >> /tmp/theme-switch.log
    switch_wofi_theme "$theme" && echo "✓ Wofi" >> /tmp/theme-switch.log || echo "✗ Wofi" >> /tmp/theme-switch.log
    switch_zen_colors "$theme" && echo "✓ Zen Browser" >> /tmp/theme-switch.log || echo "✗ Zen Browser" >> /tmp/theme-switch.log

    # Save current theme AFTER all switches complete
    echo "$theme" > "$THEME_FILE"

    # Reload applications
    pkill -SIGUSR2 waybar

    # Note: Legcord requires restart to apply theme
    # Starship theme will apply on next prompt
    # Wallpaper changes with smooth fade transition
    # Hyprland borders reload instantly
    # Zen browser will restart automatically to apply theme
}

# Main
case $1 in
    menu)
        show_menu
        ;;
    nord)
        apply_theme "nord"
        ;;
    tokyonight)
        apply_theme "tokyonight"
        ;;
    get-current)
        cat "$THEME_FILE" 2>/dev/null || echo "nord"
        ;;
    *)
        show_menu
        ;;
esac
