# ~/.config/fish/config.fish — runs on every interactive fish shell

if status is-interactive
    # Starship prompt
    starship init fish | source

    # Disable fish's built-in greeting; we use fastfetch instead (see fish_greeting function)
    # To silence fastfetch, replace the fish_greeting function with: function fish_greeting; end

    bind \b backward-kill-word
    bind \e\[3\;5~ kill-word
end
