#! /usr/bin/env python3

import subprocess
from time import sleep

# Start a napoca server on port 50001.
napoca_server = subprocess.Popen(["../target/debug/napoca", "3001"])

sleep(1)

napoca_client_ret_code = subprocess.call(["node", "./connect_test.js", "3001"])

napoca_server.kill()

exit(napoca_client_ret_code)
