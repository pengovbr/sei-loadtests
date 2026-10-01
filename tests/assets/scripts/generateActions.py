dbs = ["mysql"]
vers = ["4.0.9", "4.0.12", "4.0.12.15", "4.1.3", "4.1.4", "4.1.5", "5.0.1", "5.0.2", "5.0.3", "5.0.4", "5.0.5" ]


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

        v = v.replace("/", ".")
        print(f"Criando arquivo de carga {v} db: {db}")

        with open(f"generated/badge-sei{v}-carga-{db}.yml", "w", encoding="utf-8") as f:
            c = cont_carga.format(v, db, v, db)
            f.write(c)


for v in vers:

    body += f"| {v} "

    for db in dbs:

        img_carga = body_image_carga.format(v, db, v, db, v, db)
        body += '| ' + img_carga + ' '

    body += "|\n"

body = head + body

print(body)