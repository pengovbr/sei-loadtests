# Monitoramento via Nodes

Este teste é mais para um profissional da sustentação rodar em momentos oportunos no intuito de mapear problemas relatados de indisponibilidade que não são muito bem definidos.

Nele vc informa no aquivo assets/meusips.csv a lista com os ips dos kubernetes nodes onde há ingress; ou suas vms onde recebem o tráfego dos balanceadores ou proxyes.

Para cada um desses ips informados o jMeter vai mandar um usuário fazer o login, pesquisar processo e documento interno e externo. Isso fica em loop por um período definido pelo usuário e os erros aparecem no componente "View Results Tree" do teste. Analisando os erros informados vc verá de quais nós eles estão vindo e que tipo de erro acontece. Isso pode ser útil por ex para mostrar a anomalia de algum ingress ou node mais propenso a erros.

## Como rodar

1. Abra o projeto no jMeter
2. Abra o arquivo assets/meusips.csv no editor de texto
3. Informe os ips dos nós nesse arquivo e salve
4. Informe as variáveis do seu ambiente no componente User Defined Variables do Teste
5. Salve o teste
6. Defina no componente Cenario002... as variáveis Number of Threads (qtd de usuários simultâneos). Aqui defina o mesmo tanto de ips que vc escreveu no arquivo meusips.csv
7. Note que o teste está definido para rodar em loop infinito
8. Defina a variável "Duration (seconds)" de quanto tempo vc quer deixar o teste rodando, verificando que a var "Specify Thread lifetime" esteja marcada
9. Agora é só rodar e acompanhar. Eventuais erros quando forem acontecendo irão aparecer no componente View Results Tree do teste. O ip; a operação que deu problema bem como todo o stack http do erro estará disponível
10. O componente Summary Report vai informar o andamento de cada requisição bem como o resultado. Atenção a coluna Error que vai indicar a porcentagem de erros encontrados 

