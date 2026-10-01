dbs = ["mysql"]
vers = [
        {'nome': '4.0.9', 'checkout': '4.0.9'},
        {'nome': '4.0.12', 'checkout': '4.0.12'},
        {'nome': '4.0.12.15', 'checkout': '4.0.12.15'},
        {'nome': '4.1.3', 'checkout': '4.1.3'},
        {'nome': '4.1.4', 'checkout': '4.1.4'},
        {'nome': '4.1.5', 'checkout': '4.1.5'},
        {'nome': '5.0.1', 'checkout': '5.0.1'},
        {'nome': '5.0.2', 'checkout': '5.0.2'},
        {'nome': '5.0.3', 'checkout': '5.0.3'},
        {'nome': '5.0.4', 'checkout': '5.0.4'},
        {'nome': '5.0.5', 'checkout': '5.0.5'},
        {'nome': 'Release-5.1.0', 'checkout': 'release/5.1.0'} ]


cont_carga = """name: sei{}-carga-{}

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

head="""|Versão| Resultado |
|--|--|
"""

body_image_carga="[![sei{}-carga-{}](https://github.com/marlinhares/sei-loadtests/actions/workflows/badge-sei{}-carga-{}.yml/badge.svg)](https://github.com/marlinhares/sei-loadtests/actions/workflows/badge-sei{}-carga-{}.yml)"

body = ""

for v in vers:
    for db in dbs:

        print(f"Criando arquivo de carga {v['nome']} db: {db}")

        with open(f"generated/badge-sei{v['nome']}-carga-{db}.yml", "w", encoding="utf-8") as f:
            c = cont_carga.format(v['nome'], db, v['checkout'], db)
            f.write(c)


for v in vers:

    body += f"| {v['nome']} "

    for db in dbs:

        img_carga = body_image_carga.format(v['nome'], db, v['nome'], db, v['nome'], db)
        body += '| ' + img_carga + ' '

    body += "|\n"

body = head + body

print(body)