#!/bin/bash


set -e

# caso exista algum processo anterior, expurgue-o
EXPURGAR_PROC=true
# tempo para gerar warning, caso o teste demore mais q isso sera warning no Nagios
TEMPOMAXIMO=30
# seu comando para subir o jmeter
COMMANDOJMETER=jmeter
# caso o seu jmeter tenha outro nome informe aqui para q seja expurgado se necessario
COMMANDOJMETER_EXPURGO=jmeter

rm -rf errors.txt

if [ "$EXPURGAR_PROC" == "true" ]; then
	echo "Vamos tentar expurgar qualquer processo jmeter"
	set +e
	ps ax | grep $COMMANDOJMETER_EXPURGO | grep -v grep | awk '{print $1}' | xargs kill
	set -e
	echo "Expurgo ou tentativa finalizado"
fi

SECONDS=0
echo "Vamos rodar o teste no jmeter"
set +e
$COMMANDOJMETER -n -t TestDisponibilidadeCookies.jmx
ERROJMETER=$?
set -e
DURATION_IN_SECONDS=$SECONDS

echo "Error $ERROJMETER"
echo "Teste rodou em $DURATION_IN_SECONDS segundos"

ERROTESTE=$(wc -l < errors.txt | tr -d ' ')

echo "Error $ERROTESTE aaa"

if [ "$ERROTESTE" -gt "1" ]; then
	echo "Sair com critical. Erro no teste"
	exit 2
fi

if [ "$ERROJMETER" -gt "1" ]; then
	echo "Sair com critical. Erro no jmeter $ERROJMETER"
	exit 2
fi

if [ "$DURATION_IN_SECONDS" -gt "$TEMPOMAXIMO" ]; then
	echo "Sair com warning. Tempo maior q o esperado"
	exit 1
fi


echo "Sair com sucesso"
exit 0

