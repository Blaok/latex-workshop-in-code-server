#!/usr/bin/python3
import subprocess
import sys
from typing import Iterator, Tuple

try:
  import psutil
except ImportError:
  subprocess.check_call([
      sys.executable, '-m', 'pip', 'install', '--user', '--no-cache', 'psutil'
  ])


def main():
  local_port = int(sys.argv[1])
  remote_port = int(sys.argv[2])

  # Generate (addr, port, program, pid) tuples of listened TCP ports.
  ss_output = []
  for line in subprocess.check_output(['ss', '-nltp'],
                                      universal_newlines=True).split('\n'):
    try:
      _, _, _, addr, _, users = line.split()
      addr, port = addr.split(':')
      program, pid, _ = users[len('users:(('):-len('))')].split(',')
      ss_output.append((addr, int(port), program[1:-1], int(pid[len('pid='):])))
    except ValueError:
      pass

  # Find all code server processes.
  code_server_procs = set()
  for _, port, _, pid in ss_output:
    if port == remote_port:
      code_server_procs.add(pid)
      for child in psutil.Process(pid=pid).children(recursive=True):
        code_server_procs.add(child.pid)
      break

  # Print port forwardings.
  for addr, port, program, pid in ss_output:
    if program == 'node' and pid in code_server_procs:
      if addr in ('0.0.0.0', '[::]', '*'):
        addr = 'localhost'
      print(f'{local_port if port == remote_port else port}:{addr}:{port}')


if __name__ == '__main__':
  main()
