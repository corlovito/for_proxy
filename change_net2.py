import pandas as pd
from jinja2 import Template
import paramiko

# Чтение данных из файла Excel
df = pd.read_excel('change_net.xlsx', header=None, names=['network', 'ip', 'password'])

# Ваш шаблон
template = """#!/bin/bash
{% for i in range(0, 253) %}
ifconfig {{ interface }}:{{ 2+i }} {{ row.network.split('/')[0] | replace(".0", "."+ (2+i)|string) }} netmask 255.255.255.0 up{% endfor %}
"""

# Создание SSH клиента
ssh = paramiko.SSHClient()
ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())

for _, row in df.iterrows():
    ip = row['ip']
    password = row['password']

    # Подключение к серверу
    ssh.connect(ip, port=24442, username='root')

    # Выполнение команды и получение вывода
    cmd = "ip route show | awk '/default/ {print $5}'"
    stdin, stdout, stderr = ssh.exec_command(cmd)
    interface = stdout.read().decode().strip()

    # Создание экземпляра шаблона
    j2_template = Template(template)

    # Заполнение шаблона данными
    result = j2_template.render(row=row, interface=interface)

    # Отправка результата на сервер
    sftp = ssh.open_sftp()
    with sftp.file('/etc/network/ip-add-addresses', 'w') as f:
        f.write(result)

    # Закрытие подключения
    sftp.close()
    ssh.close()
