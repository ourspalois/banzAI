SESSION=banzai_session

# Start a new tmux session
tmux new-session -d -s $SESSION

# Create a horizontal split
tmux split-window -v -t $SESSION:0

# In the bottom pane, launch htop
tmux send-keys -t $SESSION:0.1 'htop' C-m

# Create a new window for gtkwave
tmux new-window -t $SESSION -n gtkwave
tmux send-keys -t $SESSION:1 'gtkwave' C-m

# Return to the first window
tmux select-window -t $SESSION:0

# Attach the session
tmux attach-session -t $SESSION

