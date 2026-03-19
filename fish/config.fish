if status is-interactive
    # Commands to run in interactive sessions can go here
end

set -g fish_greeting '"don'\''t listen to everybody, you should pick very specific people that you listen to"
-diinki'


bind pagedown accept-autosuggestion
bind pageup accept-autosuggestion

starship init fish | source

fish_add_path /home/aval/.spicetify

# OpenClaw Completion
source "/home/aval/.openclaw/completions/openclaw.fish"
export PATH="$HOME/.local/bin:$PATH"
