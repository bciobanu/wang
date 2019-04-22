#! /usr/bin/env python3

from time import sleep
from subprocess import Popen, run

# Start a napoca server on port 50001.
napoca_server = Popen(["../target/debug/napoca", "50001"])

sleep(1)

napoca_client = run(["node", "./connect_test.js", "50001"])

napoca_server.kill()

exit(napoca_client.returncode)
