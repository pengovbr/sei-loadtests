#!/bin/bash

set -e

MODE=$1
SEI_FONTES_LOCATION=$2
DIR_PROP=$3

if [ -d "${SEI_FONTES_LOCATION}/src" ]; then
    SEI_FONTES_LOCATION=${SEI_FONTES_LOCATION}/src
fi

PROPS_FILE=${DIR_PROP}/testProperties-test.prop
if [[ "$DB" == "sqlserver" || "$DB" == "oracle" ]]; then
    PROPS_FILE=${DIR_PROP}/testProperties-test-sqlserver.prop
fi

v=$(grep -e "define('SEI_VERSAO'" -e "const SEI_VERSAO" ${SEI_FONTES_LOCATION}/sei/web/SEI.php)
v=$(echo ${v} | grep -e "define('SEI_VERSAO'" -e "const SEI_VERSAO" | grep -e "'4\\..*\\..*'" -e "'5\\..*\\..*'" -o)
v="${v:1:3}"

DIR_TESTE_EXE="$(dirname -- "${BASH_SOURCE[0]}")"
DIR_TESTE_EXE="${DIR_TESTE_EXE}/../../../v${v}.x/testes-de-carga-stress"

yes | cp ${PROPS_FILE} ${DIR_TESTE_EXE}/testProperties-test.prop

rm -rf ${DIR_TESTE_EXE}/result-test.jtl || true

if [ "${MODE}" = "preload" ]; then

    docker run --name jmeter --rm --add-host=meusei.test:host-gateway \
        -i -v ${DIR_TESTE_EXE}:/t -w /t \
        alpine/jmeter:5.6.3 -n -t PreCargaTestPlan.jmx -p /t/testProperties-test.prop -l /t/result-test.jtl \
            -Jjmeter.save.saveservice.response_data=true -Jjmeter.save.saveservice.output_format=xml

    set +e
    e=$(grep 's="false"' ${DIR_TESTE_EXE}/result-test.jtl | wc -l)
    set -e

    cp ${DIR_TESTE_EXE}/result-test.jtl ${DIR_TESTE_EXE}/../../tests/assets/testResults/result-test.jtl

    if [ "$e" != "0" ]; then
        echo "Falha no pre-teste. Abandonando execucao. Verifique o arquivo result-test.jtl"
        #exit 1
    fi

fi

if [ "${MODE}" = "load" ]; then

    yes | cp ${DIR_TESTE_EXE}/CargaTestPlan.jmx ${DIR_TESTE_EXE}/CargaTestPlan-test.jmx
    sed -i 's|<boolProp name="TestPlan.serialize_threadgroups">false</boolProp>||g' ${DIR_TESTE_EXE}/CargaTestPlan-test.jmx
    sed -i 's|<TestPlan guiclass="TestPlanGui" testclass="TestPlan" testname="Test Plan">|<TestPlan guiclass="TestPlanGui" testclass="TestPlan" testname="Test Plan"><boolProp name="TestPlan.serialize_threadgroups">true</boolProp>|g' ${DIR_TESTE_EXE}/CargaTestPlan-test.jmx
    #cat ${DIR_TESTE_EXE}/CargaTestPlan-test.jmx
    #exit 0

    docker run --name jmeter --rm --add-host=meusei.test:host-gateway \
        -i -v ${DIR_TESTE_EXE}:/t -w /t \
        alpine/jmeter:5.6.3 -n -t CargaTestPlan-test.jmx -p /t/testProperties-test.prop -l /t/result-test.jtl \
            -Jjmeter.save.saveservice.response_data=true -Jjmeter.save.saveservice.output_format=xml

    rm -rf ${DIR_TESTE_EXE}/testProperties-test.prop || true

    set +e
    e=$(grep 's="false"' ${DIR_TESTE_EXE}/result-test.jtl | wc -l)
    set -e

    cp ${DIR_TESTE_EXE}/result-test.jtl ${DIR_TESTE_EXE}/../../tests/assets/testResults/result-test.jtl

    if [ "$e" != "0" ]; then
        echo "Falha no teste de carga. Abandonando execucao. Verifique o arquivo result-test.jtl"
        exit 1
    fi

fi
