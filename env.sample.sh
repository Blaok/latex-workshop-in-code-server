ssh_ctrl_sock=/tmp/latex-workshop.sock
ssh_host=code.example.com
declare -a ssh_args
remote_port=8080  # code-server listens on this port on the server.
local_port=8080   # use this port on the client
ssh_args=(-i /path/to/vscode.key)
