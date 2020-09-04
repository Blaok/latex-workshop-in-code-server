# Run LaTeX Workshop in Code Server

## Motivation

[LaTeX Workshop][1] is awesome but due to [a recent upstream issue][2],
  it no longer works with [vscode-remote][3].
[code-server][4] can run on a remote server,
  but LaTeX Workshop relies on local port forwarding.
This script can automatically forward ports used by LaTeX Workshop and thus
  solve the problem (hopefully for good).

[1]: https://github.com/James-Yu/LaTeX-Workshop
[2]: https://github.com/microsoft/vscode/issues/102449
[3]: https://github.com/microsoft/vscode-remote-release
[4]: https://github.com/cdr/code-server

## Assumptions

+ A client to run the brower.
+ A server to run code-server and LaTeX Workshop.
+ `ssh` connection between the client and the server.
+ The `ssh` client supports `ControlMaster`.
  +. If the client runs Windows, use WSL.
+ `code-server` installed and running on the server.
+ `/usr/bin/python3` and `ss` executables available on the server.

## Usage

1. Create and edit `env.sh` based on `env.sample.sh`.
2. `sedsid ./daemon.sh` to run the daemon.
