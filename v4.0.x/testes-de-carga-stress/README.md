# Super Load Tests

## Divisão

Temos 3 Planos de Teste:

- **CargaTestPlan-Assets.jmx**

	Ignore-o pois vai ter que aguardar definição entre SEI vs Super

- **CargaTestPlan.jmx**

	Teste de Carga com 6 Cenários. Obrigatório rodar o teste de PreCarga antes

- **PreCargaTestPlan.jmx**

	Teste preparatório que vai fazer uma carga inicial no ambiente com usuários, unidades e configurar o acesso para que o teste de carga seja possível


## Cenários Implementados

Os cenários foram escolhidos analisando as operações mais usadas e também aquelas que requerem maior esforço do sistema para gerar um resultado (caso da geracao de pdf).
Caso identifiquem necessidade de novos cenários nos avisem através das issues do projeto no github.

### Carga Inicial Preparatória

Arquivo jmeter: PreCargaTestPlan.jmx

- Cria unidades (unidade00001, unidade00002, etc). A quantidade é informada no início do teste
- Cria usuários (usuario00001, etc). A quantidae é 20x a de unidades
- Cadastra Hierarquia das Unidades
- Cadastra as Permissoes de Usuários - Cada unidade vai ter 20 usuários
- Configura Endereço das Unidades
- Configura Num SEI p Unidades
- Configura Cargos de Assinatura para as Novas Unidades

**Atenção, ao rodar o teste de carga (depois do pré-teste) o jmeter vai usar como senha o nome dos usuários criados (usuario00001, usuario00002, etc), portanto ao rodar o teste, desligue seu AD/Ldap ou crie em um AD/Ldap alternativo para esses usuários com as respectivas senhas**

**Atenção, o teste vai criar unidades e usuários com a nomenclatua acima na base de dados. Tenha isso em mente**

**Atenção, a configuracao de unidades no SEI requer que o usuário informado na carga tenha permissão para alterar contatos das unidades**
```
Verifique isso no SEI em Administracao -> Unidades -> Listar. Selecione uma unidade e verifique se ao clicar em alterar contato, os campos de endereço estão habilitados

Verifique no SEI em Administração -> Contatos -> Tipo -> Listar se a unidade que o usuário está logado corresponde a alguma das unidades informadas no campo "Unidades administradoras deste tipo"

Caso o usuário informado não tenha permissão para alterar os contatos das unidades, ou se ele estiver logado em uma unidade sem permissão de alterar as outras (ver parágrafo acima), então o teste falhará.
```


### Teste de Carga

Arquivo jmeter: CargaTestPlan.jmx

Cada cenário deve rodar simultaneamente.
Defina por cenário a qtde de usuarios simultaneos e as repetições dos cenários
O teste vai randomizar uma unidade e usuário para fazer o flood a cada repetição das threads.
Sendo assim vai criar processos em varias unidades.

- **Cenario 1 - Cadastrar Processos e Docs Internos e Externos**
	
	- Login
	- Novo Processo (tipo aleatorio)
	- Assunto aleatorio
	- Contato Fixo
	- Loop Cadastra Docs Internos
		- cria novo doc com tipo randomizado pre informado 
		- salva doc
		- edita 1a vez doc com centenas de linhas aleatorias
		- edita 2a vez doc com frase aleatoria para servir de pesquisa posterior com solr
		- assina o documento
	- Loop Cadastra Docs Externos
		- cria doc externo do tipo abaixo assinado
		- randomiza o upload com algum pdf q esteja disponivel no dir upload_files
		- salva
	
	Diversos aspectos sao definidos via config file, por ex, vc pode informar qts docs internos e externos cada proc vai ter. Você também pode definir no diretório vários pdfs com tamanhos diferentes para upload, o teste vai aleatorizar entre eles para criar os documentos anexos.
		
	Este cenário gera insumo para os cenários posteriores.

- **Cenario 2 - Pesquisar Proc e Docs pelo Número**
	
	Inicia 180s após o primeiro. Vc pode definir esse delay.
	
	- Login
	- Seleciona aleatoriamente um processo cadastrado anteriormente
	- Seleciona aleatoriamente um usuário da unidade daquele processo
	- pesquisa pelo número do protocolo
	- para cada documento do protocolo, pesquisa individualmente usando o seu número

- **Cenários 3 - Atribuir Processo**

	- Login com usuario aleatorio
	- Pesquisa processo cadastrado anteriormente
	- Atribui o processo de forma aleatória

- **Cenário 4 - Gerar PDF**

	- Login com usuario aleatorio
	- Pesquisa processo cadastrado anteriormente
	- Gera o PDF desse processo.
	Cuidado com exagero no teste. Essa operação gera forte gargalo

- **Cenário 005 - Anotação Registrar**

	- Login com usuario aleatorio
	- Pesquisa processo cadastrado anteriormente
	- Efetua uma anotação no processo

- **Cenário 006 - Pesquisar via Solr**

	- Login  com usuario aleatorio
	- Seleciona aleatoriamente um processo cadastrado anteriormente
	- Para cada doc interno:
		- Pesquisa pelo termo (texto dentro do documento)

## Parâmetros do Teste

Estamos adotando a execução dos testes calibrando o jmeter usando um arquivo de configuração. 
Vc deve subir o jmeter com essas propriedades ingeridas.
Ex.: ao subir o jmeter ou rodar o teste vc deve informar esse arquivo de propriedades:
```
jmeter -p testProperties.prop
```
Nesse arquivo vai ficar todos os parametros do teste, por ex, qual o ambiente vai apontar, usuário de admin para carga inicial, qde de usuarios simultaneamente rodando o cenário1, qtd de users rodando o cenario2, qual a janela de tempo randômico que um usuário espera depois de cadastrar um doc, etc

Vc pode rodar o teste bypassando esse arquivo, nesse caso use dentro do teste o primeiro elemento jmeter chamado "user Defined Variables" para cada plano. Para facilidade recomendamos fortemente o uso do arquivo testProperties.prop

Faça uma leitura do arquivo testProperties.prop.example pois lá tem as informações de cada parâmetro. O sucesso de um bom teste passa por uma boa calibragem. Você consegue facilmente derrubar qualquer SEI ou SUPER, mas na vida real os usuários pensam de forma humana, com espaço de tempo entre uma requisição e outra.


## Instruções Básicas

### Pré-teste

1. Vá até a pasta testes-de-carga-stress

2. Copie o arquivo testProperties.prop.example para testProperties.prop

4. Abra o arquivo e altere os parâmetros de conexão desejados

5. Abra o teste PreCarga (não esqueça que ao subir o jmeter passe o arquivo properties ingestando-o)

7. Rode o pré-teste. Esse teste irá fazer a pré carga no ambiente com as unidades, usuários e configs necessárias para o teste rodar

8. O pré-teste é feito para rodar apenas 1x, mas pode rodar novamente se quiser, ele já está preparado para tratar caso já exista cadastro prévio

9. Caso o teste falhe, por alguma falha na infra, basta rodar novamente que ao rodar ele irá completar o cadastro. O teste de pré-carga deve chegar até o final, caso contrário o teste de carga não vai funcionar adequadamente

10. Vc sabe q ele chegou ao final olhando o "View Results Tree" da última thread. Ela deve finalizar sem requisicoes vemelhas

11. Agora q vc rodou o pré-teste pode rodar o teste de carga de várias formas analisando a carga
 

### Teste de carga

1. Abra o jmeter com o arquivo .prop ingestado (ver acima)

2. Na primeira execução vamos rodar bem leve apenas para certificar que o teste está rodando no seu ambiente, portanto pode usar a interface gráfica

3. Rode o teste. O cenário1 vai iniciar e depois do delay definido no plano de teste cada novo cenário vai iniciar no seu tempo

4. Para cada cenário acompanhe o resultado no componente "View Results Tree" ou "Summary Report"

5. Vai rodar por alguns minutos e ao final o teste deve finalizar sem erro. Caso haja erro tem que analisar a causa

6. Agora que passou na execução leve vamos jogar uma carga maior e ir analisando os resultados pelos relatórios. O teste de carga na vera não deve ser rodado usando a interface do jmeter. Você deve rodar usando a linha de comando. Aspectos como memória, largura de banda não serão discutidos aqui, portanto faça uma pesquisa prévia em jmeter

7. Defina os parametros no arquivo de propriedade (aumentando um pouco a carga)

8. Rode o jmeter via linha de comando gerando um relatório web pós execução
	``` 
	jmeter -n -t CargaTestPlan.jmx -p testProperties.prop -l resultado.csv -e -o resultadoweb
	```
	
	Importante: defina a quantidade de memória que o jmeter vai usar. Caso você aumente a carga precisará aumentar a memória destinada ao jmeter.

9. Enquanto o teste roda navegue em um browser pelo sistema e veja a responsividade geral
 
10. O arquivo resultado.csv vai conter as estatísticas do teste

11. No diretório resultadoweb será criado um relatorio detalhado com as estatísticas levantadas durante o teste

12. Caso o teste precise ser interrompido no meio do caminho, pode gerar o relatório com esse comando:
	```
	jmeter -e -g resultado.csv -o resultadoweb
	```
 
13. Os resultados devem ser coletados e analisados a luz da filosofia jmeter e tb levando em consideração o que vc deseja medir





## Dúvidas ou Sugestões

Pode usar a parte de issue aqui do projeto no github.
Contribuição pode enviar pull-requests

