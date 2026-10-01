#!/bin/bash

set -e

DB=$1
if [ "${DB}" = "" ]; then
    DB="mysql"
fi
SEI_DOCKER_LOCATION_INFRA=$2
SEI_FONTES_LOCATION=$3
ENVS_DIR=$4

if [ -d "${SEI_FONTES_LOCATION}/src" ]; then
    SEI_FONTES_LOCATION=${SEI_FONTES_LOCATION}/src
fi

SEI_DOCKER_LOCATION_COMPOSE=${SEI_DOCKER_LOCATION_INFRA}/orquestrators/docker-compose

v=$(grep -e "define('SEI_VERSAO'" -e "const SEI_VERSAO" ${SEI_FONTES_LOCATION}/sei/web/SEI.php)
v=$(echo ${v} | grep -e "define('SEI_VERSAO'" -e "const SEI_VERSAO" | grep -e "'4\\..*\\..*'" -e "'5\\..*\\..*'" -o)
v="${v:1:3}"

echo "Versao ${v}"

cp ${SEI_DOCKER_LOCATION_INFRA}/envlocal-example-mysql-sei4.env ${SEI_DOCKER_LOCATION_INFRA}/envlocal.env
cat ${SEI_DOCKER_LOCATION_INFRA}/envlocal-example-${DB}-sei4.env >> ${SEI_DOCKER_LOCATION_INFRA}/envlocal.env

if [ "${v:0:1}" = "5" ]; then
    cat ${SEI_DOCKER_LOCATION_INFRA}/envlocal-example-${DB}-sei5.env >> ${SEI_DOCKER_LOCATION_INFRA}/envlocal.env
fi

echo "" >> ${SEI_DOCKER_LOCATION_INFRA}/envlocal.env
echo "export LOCALIZACAO_FONTES_SEI=${SEI_FONTES_LOCATION}" >> ${SEI_DOCKER_LOCATION_INFRA}/envlocal.env
echo "" >> ${SEI_DOCKER_LOCATION_INFRA}/envlocal.env
cat ${ENVS_DIR}/envcomplemento.env >> ${SEI_DOCKER_LOCATION_INFRA}/envlocal.env

make -C ${SEI_DOCKER_LOCATION_INFRA} setup

docker compose -f ${SEI_DOCKER_LOCATION_COMPOSE}/docker-compose.yml down app-agendador

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