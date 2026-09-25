#!/bin/bash

set -e

SEI_FONTES_LOCATION=$1
DIR_PROP=$2


if [ -d "${SEI_FONTES_LOCATION}/src" ]; then
    SEI_FONTES_LOCATION=${SEI_FONTES_LOCATION}/src
fi

v=$(grep -e "define('SEI_VERSAO'" -e "const SEI_VERSAO" ${SEI_FONTES_LOCATION}/sei/web/SEI.php)
v=$(echo ${v} | grep -e "define('SEI_VERSAO'" -e "const SEI_VERSAO" | grep -e "'4\\..*\\..*'" -e "'5\\..*\\..*'" -o)
v="${v:1:3}"

DIR_TESTE_EXE="$(dirname -- "${BASH_SOURCE[0]}")"
DIR_TESTE_EXE="${DIR_TESTE_EXE}/../../../v${v}.x/testes-de-carga-stress"

yes | cp ${DIR_PROP}/testProperties-test.prop ${DIR_TESTE_EXE}/testProperties-test.prop

rm -rf ${DIR_TESTE_EXE}/result-testes.jtl || true

docker run --name jmeter --rm --add-host=meusei.test:host-gateway \
    -i -v ${DIR_TESTE_EXE}:/t -w /t \
    alpine/jmeter:5.6.3 -n -t PreCargaTestPlan.jmx -p /t/testProperties-test.prop -l /t/result-testes.jtl

set +e
e=$(grep ",false," ${DIR_TESTE_EXE}/result-testes.jtl | wc -l)
set -e

if [ "$e" != "0" ]; then
    echo "Falha no pre-teste. Abandonando execucao. Verifique o arquivo result-testes.jtl"
    exit 1
fi

docker run --name jmeter --rm --add-host=meusei.test:host-gateway \
    -i -v ${DIR_TESTE_EXE}:/t -w /t \
    alpine/jmeter:5.6.3 -n -t CargaTestPlan.jmx -p /t/testProperties-test.prop -l /t/result-testes.jtl

rm -rf ${DIR_TESTE_EXE}/testProperties-test.prop || true

set +e
e=$(grep ",false," ${DIR_TESTE_EXE}/result-testes.jtl | wc -l)
set -e

if [ "$e" != "0" ]; then
    echo "Falha no teste de carga. Abandonando execucao. Verifique o arquivo result-testes.jtl"
    exit 1
fi

rm -rf ${DIR_TESTE_EXE}/testProperties-test.prop || true
rm -rf ${DIR_TESTE_EXE}/result-testes.jtl || true