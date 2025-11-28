from goad.provider.terraform.terraform import TerraformProvider
from goad.utils import *
from goad.log import Log

from ssclient.http_client_factory import SSClientFactory

import types
from typing import Any, Dict, Optional
import asyncio


class ServerSpaceProvider(TerraformProvider):

    provider_name = SERVERSPACE
    default_provisioner = PROVISIONING_REMOTE
    allowed_provisioners = [PROVISIONING_REMOTE]

    def __init__(self, lab_name, config):
        super().__init__(lab_name)
        api_key = config.get_value('serverspace', 'api_token', 'API-TOKEN')
        self.ss_client = SSClientFactory.create(apikey = api_key)
        self.resource_group = lab_name
        self.jumpbox_setup_script = 'setup_serverspace.sh'

    def check(self):
        # check terraform bin
        check = super().check()
        check_serverspace = self.command.check_serverspace()
        check = check and check_serverspace

        try:
            project = self.ss_client.project()

            response = asyncio.run(
                project.get(),
            )

            Log.info("User Information:")
            Log.info(f"  Account: {response['id']}")
            Log.info(f"  Balance: {response['balance']}")
            Log.info(f"  Currency: {response['currency']}")
            Log.info(f"  State: {response['state']}")
            Log.info(f"  Created: {response['created']}")
            check = check and True
        except Exception as e:
            Log.error(f"An error occurred: {e}")
            check = False
        return check

    def start(self):
        # TODO
        pass

    def stop(self):
        # TODO
        pass

    def status(self):
        # TODO
        pass

    def start_vm(self, vm_name):
        # TODO
        pass

    def stop_vm(self, vm_name):
        # TODO
        pass

    def destroy_vm(self, vm_name):
        # TODO
        pass

    def ssh_jumpbox(self):
        # TODO
        pass

    def get_jumpbox_ip(self, ip_range=''):
        jumpbox_ip = self.command.run_terraform_output(['ubuntu-jumpbox-ip'], self.path)
        if jumpbox_ip is None:
            Log.error('Jump box ip not found')
            return None
        if not Utils.is_valid_ipv4(jumpbox_ip):
            Log.error('Invalid IP')
            return None
        return jumpbox_ip