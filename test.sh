#!/bin/bash

# Start a new tmux session named "my_session"
tmux new-session -d -s dev-session

# Rename the first window
tmux rename-window -t dev-session:0 "Main"

# Run each opencode command in one window in separate splits

tmux split-window -t dev-session:0 -h

# Send commands to the first window
tmux send-keys -t dev-session:0.0 "cd ~/workspace/worktrees/my-new-feature-a" C-m
tmux send-keys -t dev-session:0.0 "opencode" C-m

tmux send-keys -t dev-session:0.1 "cd ~/workspace/worktrees/my-new-feature-a" C-m
tmux send-keys -t dev-session:0.1 "opencode" C-m

# OR run each feature in a separate window

# Create a new window for editing
# tmux new-window -t dev-session:1 -n "feature-a"
# tmux new-window -t dev-session:0 -n "feature-b"

# Send commands to the second window
# tmux send-keys -t dev-session:1 "opencode" C-m
# tmux send-keys -t dev-session:0 "opencode" C-m

# Attach to the session
tmux attach-session -t dev-session
