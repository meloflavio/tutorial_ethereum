# Instalando Ethereum Blockchain em container docker

A seguir uma sequência de passos que podem ser utilizados para iniciar uma cadeia Ethereum Blockchain dentro de um container docker.

1. Criando o arquivo genesis.json.

Com o docker instalado, para iniciar uma nova cadeia de blocos crie um arquivo chamado &#39;genesis.json&#39;. Este arquivo é usado para criar o primeiro bloco da cadeia. Nesse exemplo criamos o diretório &quot;$HOME/ethereum&quot; para armazenar estes arquivos.

**Exemplo de genesis.json :**
  <pre>
  {
  "config":{
      "chainId": 13
  },
  "coinbase"   : "0x0000000000000000000000000000000000000000",
  "difficulty" : "0x200",
  "extraData"  : "",
  "gasLimit"   : "0x2fefd8",
  "nonce"      : "0x0000000000000042",
  "mixhash"    : "0x0000000000000000000000000000000000000000000000000000000000000000",
  "parentHash" : "0x0000000000000000000000000000000000000000000000000000000000000000",
  "timestamp"  : "0x00",
  "alloc": {}
}
   </pre>
Para entendermos:

1.  &quot; **config**&quot;: a configuração da blockchain.
  1. &quot;chainId&quot;: proteção do ataque de repetição . Por exemplo, se uma ação é validada combinando certo valor que depende do ID da cadeia, os atacantes não podem obter facilmente o mesmo valor com um ID diferente.
2. &quot; **coinbase&quot;:** é um endereço onde todas as recompensas coletadas com a validação de bloco bem-sucedida serão transferidas. Uma recompensa é uma soma da recompensa de mineração e dos reembolsos da execução de transações de contrato. Como é um bloco de gênese, o valor desse bloco pode ser qualquer coisa. Para todos os próximos blocos, o valor será um endereço definido pelo mineiro que validou esse bloco.
3. &quot; **difficulty**&quot;: dificuldade de mineração, para desenvolvimento e testes defina esse valor baixo para que você não precise esperar muito pelos blocos de mineração.
4. **&quot;extraData&quot;** - Uma matriz de bytes arbitrária contendo dados relevantes para este bloco. Além disso, é um parâmetro opcional que não pode ser maior que 32 bytes.
5. &quot; **gasLimit**&quot;: o limite do custo do gás por bloco.
6. **&quot;nonce&quot;** -  O nonce é o número de transações enviadas de um determinado endereço. É usado em combinação com **mixhash** para provar que uma quantidade suficiente de computação foi realizada neste bloco.
7. **&quot;mixHash&quot;** - Um hash de 256 bits que, combinado com o **nonce** , prova que uma quantidade suficiente de computação foi realizada no bloco. A combinação de nonce e mixhash deve satisfazer uma condição matemática
8. **&quot;parentHash&quot;** - O hash do cabeçalho do bloco pai. Isso é meio que um ponteiro para o bloco pai necessário para formar uma cadeia real de blocos. Um bloco de gênese não possui um bloco pai, portanto, o resultado será apenas neste caso igual a 0.
9. **&quot;timestamp&quot;** - define a hora de criação do bloco, é usado para modificar a dificuldade, se necessário.
10. **&quot;alloc&quot;** : esse parâmetro é usado para pré-financiar alguns endereços com ether. Ele contém dois parâmetros, o endereço que deve ser um hash de 160 bits e o número de ether com o qual uma conta deve ser financiada.

1. Criando o arquivo  Dockerfile.

No mesmo diretório, criei um &#39;Dockerfile&#39; que iniciará uma imagem do Ubuntu e começará a instalar o Ethereum e as dependências necessárias.

O arquivo contém o seguinte conteúdo:

<pre>
FROM ubuntu:18.04

RUN apt-get update && apt-get install -y software-properties-common net-tools
RUN add-apt-repository -y ppa:ethereum/ethereum && apt-get update
RUN apt-get -y install ethereum

ADD ./genesis.json /root/genesis.json

EXPOSE 8545 30303 30303/udp
RUN mkdir -p /root/datadir

ENTRYPOINT "bash"

</pre>
1. Criando imagem Docker e iniciar um nó

Com o Dockerfile e o arquivo genesis, posso criar a imagem do Docker executando:
<pre>
docker build -t  docker/ether-node .
</pre>

Com a imagem montada, podemos iniciar nosso primeiro nó. Precisamos definir as portas que serão utilizadas e um diretório para manter os dados entres as execuções do container Docker. O comando para iniciar o primeiro nó é:
<pre>
docker run -it -p 8545:8545 -p 30303:30303 -v $HOME/ethereum/datadir:/root/datadir docker/ether-node /bin/bash
</pre>

 O diretório &quot;$HOME/ethereum/datadir&quot; pode ser alterado para qualquer outro que venha a utilizar.

1. Iniciando rede privada

Agora que o nó está em execução, dentro do container iniciamos uma nova blockchain com &#39;geth&#39;. No nó que acabamos de criar, executamos o seguinte comando:
<pre>
geth --datadir=/root/datadir/ init /root/genesis.json 
</pre>

 Com isso, o bloco inicial é criado (a cadeia de blocos está configurada). Posteriormente, iniciar a cadeia de blocos executando:
 <pre>
geth --datadir /root/datadir/ --port 30303 --rpcport 8545 --rpc --rpcapi eth,web3,personal,net --rpcaddr 0.0.0.0 console
</pre>

 A rede privada Ethereum agora está funcional e pode ser acessada dentro do container ou através de um terminal em seu computador ou qualquer outro que esteja conectado a ele. Podemos usar o console &#39;geth em nossa máquina para conectarmos a rede e executar os comandos para criar contas e fazer alguma mineração para criar éter para a conta.

1. Testando conexão com a rede através do geth

Caso queira poderá acessar a cadeia de sua propria máquina, para isso, certifique-se de ter o geth instalado em sua máquina. A maneira mais simples de instalar o go-ethereum nas distribuições do Ubuntu é através dos PPAs.

Para ativar o repositório PPA, execute:
<pre>
sudo add-apt-repository -y ppa:ethereum/ethereum
.
</pre>

Depois disso, você pode instalar a versão estável do Go Ethereum:
<pre>
sudo apt-get update sudo apt-get install ethereum
</pre>


Para acessar a rede privada em seu computador utilize o comando:
<pre>
geth attach http://localhost:8545
</pre>

Troque localhost pelo IP da máquina que está rodando o container, caso esteja utilizando um computador diferente.
