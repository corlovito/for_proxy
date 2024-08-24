import pandas as pd
import subprocess
import paramiko
import os

df = pd.read_excel('change_net.xlsx', names=['network', 'ip', 'password'])
interface = subprocess.check_output("ip route show | awk '/default/ {print $5}'", shell=True).decode().strip()
print(interface)

public_key_path = '/root/.ssh/id_rsa.pub'

# for _, row in df.iterrows():
#     ip = row['ip']
#     username = 'root'
#     password = row['password']
#
# ssh = paramiko.SSHClient
# ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
# ssh.connect(ip, username=username, password=password)
#
# with open(public_key_path, 'r') as f:
#     public_key = f.read()
# ssh.exec_command('echo "{}" >> ~/.ssh/authorized_keys'.format(public_key))
#
# ssh.close()


# print(df.head())