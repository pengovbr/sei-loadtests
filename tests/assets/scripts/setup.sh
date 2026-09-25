#!/bin/bash

set -e

SEI_DOCKER_LOCATION_INFRA=$1
SEI_FONTES_LOCATION=$2
ENVS_DIR=$3
CHECKOUT_VERSION=$4

#git -C ${SEI_FONTES_LOCATION} checkout ${CHECKOUT_VERSION}

if [ -d "${SEI_FONTES_LOCATION}/src" ]; then
    SEI_FONTES_LOCATION=${SEI_FONTES_LOCATION}/src
fi

v=$(grep -e "define('SEI_VERSAO'" -e "const SEI_VERSAO" ${SEI_FONTES_LOCATION}/sei/web/SEI.php)
v=$(echo ${v} | grep -e "define('SEI_VERSAO'" -e "const SEI_VERSAO" | grep -e "'4\\..*\\..*'" -e "'5\\..*\\..*'" -o)
v="${v:1:3}"

echo "Versao ${v}"

cp ${SEI_DOCKER_LOCATION_INFRA}/envlocal-example-mysql-sei4.env ${SEI_DOCKER_LOCATION_INFRA}/envlocal.env

if [ "${v:0:1}" = "5" ]; then
    cat ${SEI_DOCKER_LOCATION_INFRA}/envlocal-example-mysql-sei5.env >> ${SEI_DOCKER_LOCATION_INFRA}/envlocal.env
fi

echo "export LOCALIZACAO_FONTES_SEI=${SEI_FONTES_LOCATION}" >> ${SEI_DOCKER_LOCATION_INFRA}/envlocal.env
cat ${ENVS_DIR}/envcomplemento.env >> ${SEI_DOCKER_LOCATION_INFRA}/envlocal.env

make -C ${SEI_DOCKER_LOCATION_INFRA} setup

echo "Vamos tentar acessar a pagina de login do SEI, vamos aguardar ate 95 segs."
for number in $(seq 1 18); do
    echo 'Tentando acessar...'
	set +e
	var=$(curl --resolve "meusei.test:443:127.0.0.1" -s -L -k https://meusei.test/sei | grep "txtUsuario")
	set -e
	if [ "$var" != "" ]; then
		echo 'Pagina respondeu com tela de login'
		break
	else
	    echo 'Aguardando resposta'
	fi
	sleep 5
done
set +e
var=$(curl --resolve "meusei.test:443:127.0.0.1" -s -L -k https://meusei.test/sei | grep "txtUsuario")
set -e
if [ "$var" = "" ]; then echo 'Pagina de login nao respondeu. Verifique. Abandonando execucao'; exit 1 ; fi