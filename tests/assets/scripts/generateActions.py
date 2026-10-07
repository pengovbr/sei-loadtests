from configparser import ConfigParser
import os

def get_repo_owner_and_name():

    config_path = os.path.join("../", "../", "../", ".git", "config")

    if not os.path.exists(config_path):
        raise FileNotFoundError("Not inside the root of a Git repository.")

    config = ConfigParser()
    config.read(config_path)

    # Extract the remote tracking URL (usually 'origin')
    if 'remote "origin"' in config:
        url = config['remote "origin"']['url']
        # URLs look like: https://github.com or git@github.com:owner/repo.git
        parts = url.replace(":", "/").split("/")
        owner = parts[-2]
        repo_name = parts[-1].replace(".git", "")
        return owner, repo_name

    return None, None

owner, repo = get_repo_owner_and_name()

dbs = ["mysql", "postgres", "sqlserver", "oracle"]
# dbs = ["mysql"]
vers = [
        {'nome': '4.0.9', 'checkout': '4.0.9'},
        {'nome': '4.0.12', 'checkout': '4.0.12'},
        {'nome': '4.0.12.15', 'checkout': '4.0.12.15'},
        {'nome': '4.1.5', 'checkout': '4.1.5'},
        {'nome': '5.0.1', 'checkout': '5.0.1'},
        {'nome': '5.0.2', 'checkout': '5.0.2'},
        {'nome': '5.0.3', 'checkout': '5.0.3'},
        {'nome': '5.0.4', 'checkout': '5.0.4'},
        {'nome': '5.0.5', 'checkout': '5.0.5'},
        {'nome': 'Release-5.1.0', 'checkout': 'release/5.1.0'} ]


cont_carga = """name: {}-{}

on:
  push:
  workflow_dispatch:

jobs:
  test:
    uses: ./.github/workflows/testCarga.yml
    secrets: inherit
    with:
      sei-version: {}
      db: {}
"""

head="""|Versão| Mysql | Postgres | SqlServer | Oracle
|--|--|--|--|--|
"""

#head="""|Versão| Resultado |
#|--|--|
#"""

body_image_carga="[![sei{}-carga-{}](https://github.com/{}/sei-loadtests/actions/workflows/badge-sei{}-carga-{}.yml/badge.svg)](https://github.com/{}/sei-loadtests/actions/workflows/badge-sei{}-carga-{}.yml)"

body = ""

for v in vers:
    for db in dbs:

        print(f"Criando arquivo de carga {v['nome']} db: {db}")

        with open(f"generated/badge-sei{v['nome']}-carga-{db}.yml", "w", encoding="utf-8") as f:
            c = cont_carga.format(db, v['nome'], v['checkout'], db)
            f.write(c)


for v in vers:

    body += f"| {v['nome']} "

    for db in dbs:

        img_carga = body_image_carga.format(v['nome'], db, owner, v['nome'], db, owner, v['nome'], db)
        body += '| ' + img_carga + ' '

    body += "|\n"

body = head + body

print(body)