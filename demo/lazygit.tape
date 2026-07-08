# lazygit.hx demo
# Requirements: helix-steel with lazygit.hx loaded, lazygit on PATH
# Demonstrates the lazygit floating overlay (space g) from within helix.
# Run from this directory: vhs lazygit.tape

Output lazygit.gif

Set Shell "bash"
Set FontSize 14
Set Width 1400
Set Height 755
Set Theme "Catppuccin Mocha"
Set TypingSpeed 50ms

# Set up a disposable demo git repo
Type "rm -rf /tmp/hx-lazygit-demo && git init -q /tmp/hx-lazygit-demo && cd /tmp/hx-lazygit-demo"
Enter
Sleep 400ms
Type "git config user.email demo@demo.com && git config user.name Demo"
Enter
Sleep 200ms
Type "cp ~/projects/lazygit.hx/demo/main.rs . && git add main.rs && git commit -q -m add"
Enter
Sleep 500ms

# Introduce an uncommitted change so lazygit has something to show
Type "echo '    greet(helix);' >> main.rs"
Enter
Sleep 300ms

# Open helix on the changed file
Type "hx main.rs"
Enter
Sleep 2500ms
Type ":showkeys-toggle"
Enter
Sleep 200ms

# Open lazygit overlay — space g
Type " g"
Sleep 3s

# Hold on lazygit showing the changed file — any navigation causes PTY redraws
# that produce rendering artifacts outside tmux, so we end here
Sleep 4s
