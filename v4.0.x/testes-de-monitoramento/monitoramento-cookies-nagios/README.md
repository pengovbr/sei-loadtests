
# Monitoramento via Cookies

Esse teste faz um monitoramento do ambiente logando em cada nó (pod) possível quando o seu sistema estiver com o sticksession ativado via cookies.

Opcionalmente antes de rodar ele faz um levantamento dos cookies possíveis e salva um arquivo com os mesmos. Usa-os por uma hora e depois disso novo levantamento é feito.

Também há a possibilidade do teste pular essa etapa e vc já informar o arquivo com os valores de cookies possíveis para ele usar.

O teste roda uma vez consumindo o arquivo servercookies.csv do diretório assets. Depois morre. Foi feito assim para alguma ferramenta de monitoramento acioná-lo sempre que precisar verificar a disponibilidade. Sendo assim o Nagios, por exemplo pode usar o script disponível para chamar o teste e informar o resultado no painel de monitoramento.

## O que ele testa

Para cada valor do cookie sticksession informado ele cria uma thread (usuário web) e testa:
- login
- consulta em um número de processo
- consulta em um número de documento interno
- consulta em um número de documento externo

Todos esses valores são definidos no componente User Defined Variables do Plano de Teste no jMeter

## Como rodar

 1. Abra o teste no jMeter
 2. Defina cada variável no primeiro componente User Defined Variables
	 - host
	 - userLogin
	 - userPass
	 - etc; cada variavel tem uma descrição do que significa no próprio componente
 3. Salve o projeto jMeter
 4. Defina quantas threads vc vai querer rodar em paralelo no componente Cenario002-Pesquisar na Unidade
 5. Defina quantas repetições
 6. Salve o projeto
 7. Agora pode rodar

Depois de levantar os cookies, caso tenha sido configurado para isso, o teste vai consumir o arquivo servercookies.csv e enviar na sequencia uma série de requisições para cada cookie que está definido no arquivo. Consumindo todo o arquivo o teste vai se auto desligar.

Atenção o teste só vai consumir todo o arquivo se a multiplicação dos atributos "Number f Threads" e "Loop Count" do componente "Cenario002-Pesquisar na Unidade" for maior que a quantidade de cookies listados no arquivo servercookies.csv

## Como rodar com Nagios

1. Prepare o projeto como informado acima
2. Posicione o projeto no servidor Nagios ou agente escolhido
3. jMeter 5.5 precisa estar instalado no Nagios
4. Abra o arquivo nagios_disponibilidade.sh e altere os parametros iniciais como:
	- EXPURGAR_PROC
	- TEMPOMAXIMO
	- COMMANDOJMETER
	- COMMANDOJMETER_EXPURGO
	As explicações de cada parâmetro estão no próprio script
5. Adicione permissão de execução ao script
6. Teste uma chamada rodando o comando: ./nagios_disponibilidade.sh
7. Agende o script no Nagios na periodicidade desejada

Atenção: o parâmetro TEMPOMAXIMO vai ser medido durante o teste e caso o script demore mais do que esse tempo para rodar, o Nagios vai ser acionado como Warning no serviço. Caso o teste retorne algum erro em qualquer chamada o Nagios vai alarmar com Critical.