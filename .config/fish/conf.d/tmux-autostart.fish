# Auto-attach (or create) a tmux session named "main" when fish starts in a real terminal.
# Guards prevent firing inside an existing tmux, VSCode terminal, or Emacs shell.
# `isatty stdout` keeps it from firing during non-terminal probes (e.g. VS Code's
# shell-environment resolution) which would `exec tmux` with no TTY and exit 1.
# To disable: delete this file, or comment out the `exec` line.

if status is-interactive
    and isatty stdout
    and not set -q TMUX
    and not set -q VSCODE_INJECTION
    and not set -q VSCODE_RESOLVING_ENVIRONMENT
    and not set -q INSIDE_EMACS
    and command -q tmux
    exec tmux new-session -A -s main
end
