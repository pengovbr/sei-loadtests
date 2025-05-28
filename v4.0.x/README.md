# Super Load Tests

Projeto com scripts no jmeter para testes de carga e stress no Super.

Testado em SEI 4.0.9 e Super 4.0.9.12
Pode ser que funcione para outras versões. Um aspecto importante a se levar em conta é que a instalação de módulos pode acarretar falha nos testes caso mude as chamadas das requisições.


## Divisão do Projeto

O projeto atualmente está dividido em 3 partes independentes. Ao entrar em cada pasta existe um README específico:

- **testes de carga e stress:** 
	aqui ficam os testes em jmeter para fazer carga e stress nos ambientes
	
- **testes de monitoramento:**
	aqui ficam testes em jmeter que ao implantar o sistema nos deparamos com alguma lentidão. Foram necessários para o profissional da sustentação identificar possíveis gargalos relacionados a nó de aplicação ou ingress.
	Apenas SEI4.

	- **monitoramento-cookies-nagios:**
		esse teste faz inicialmente um apanhado dos cookies ofertados pela url com o  intuito de levantar os possíveis nós(ou pods) de entrada possíveis. Depois disso faz uma chamada ao sistema, logando com o usuário robô disponibilizado, e faz algumas operações simples para informar se o sistema está no ar.
		Segue junto um script para ser disponibilizado no Nagios para monitorar a disponiblidade
	
	
	- **monitoramento-nodes-ingress:**
		nesse teste você informa os possíveis nós físicos onde residem seus ingress kubernetes (ou seus balanceadores cattle, ou até mesmo as vms internas q ofertam o tráfego http ou https para o sistema) e dispara uma chamada independente para cada um deles testando o login e pesquisa simples de processo e documentos. A execução do teste em loop vai mostrar possíveis erros aleatórios que possam acontecer e listá-los para análise
