#! /usr/bin/env python3

import subprocess
from time import sleep

# Start a napoca server on port 50001.
napoca_server = subprocess.Popen(["../target/debug/napoca", "50001"])

sleep(1)

napoca_client = subprocess.run(["node", "./connect_test.js", "50001"])

napoca_server.kill()

exit(napoca_client.returncode)
