# Script de Criação de Materiais Criptográficos para Hyperledger Fabric

Este script em shell foi criado para facilitar a criação de peers e orderers em uma rede Hyperledger Fabric. Ele interage com um servidor de Autoridade de Certificação (CA) usando o `fabric-ca-client` para gerar os materiais criptográficos necessários.

## Funcionalidades

O script oferece as seguintes funcionalidades:

- **Criar Peer**: `createPeer` - Cria um novo peer na rede, inscrevendo-o no CA e gerando os certificados necessários.
- **Criar Orderer**: `createOrderer` - Cria um novo orderer na rede, inscrevendo-o no CA e gerando os certificados necessários.
- **Inscrever Administrador**: `enrollAdmin` - Faz o enroll de um administrador no CA para uma organização específica.

## Pré-requisitos

- O `fabric-ca-client` deve estar instalado e configurado corretamente.
- Acesso a um servidor de CA para interação (por exemplo, `ca.ecotrust.solutions:7054`).
- Acesso ao root cert (ca-cert.pem) da organização na pasta onde se encontra o script

## Como Usar

1. Clone este repositório em sua máquina local;
2. Certifique-se de que o `fabric-ca-client` está instalado e acessível;
3. Baixe o ca-cert.pem na mesma pasta do repositório (peça o arquivo ao sysadmin);
4. Execute o script com os parâmetros apropriados para criar pares, ordenadores ou inscrever administradores, conforme necessário.

## Exemplos de Uso

Criar um novo peer:

**./createCryptos.sh peer org caserveruri:porta caname nomepeer**

onde:
- `peer` é a ação de criar o material para um novo peer
- `org`  é a organização dona do novo peer
- `caserveruri:porta` é o endereço do CA Server da organização com porta
- `caname` é o nome amigável do CA Server da organização
- `nomepeer` é o nome que será dado ao novo peer
\`\`\`
./createCryptos.sh peer ecotrace.solutions ca.ecotrace.solutions:1234 ca-ecotrace peer1
\`\`\`

Criar um novo orderer:

**./createCryptos.sh orderer org caserveruri:porta caname nomeorderer**

onde:
- `orderer` é a ação de criar o material para um novo orderer
- `org`  é a organização dona do novo orderer
- `caserveruri:porta` é o endereço do CA Server da organização com porta
- `caname` é o nome amigável do CA Server da organização
- `nomeorderer` é o nome que será dado ao novo orderer
\`\`\`
./createCryptos.sh orderer ecotrust.solutions ca.ecotrust.solutions:1234 ca-ecotrust orderer1
\`\`\`

Fazer o enroll de um usuario Admin:

**./createCryptos.sh admin org caserveruri:porta caname**

onde:
- `admin` é a ação de criar o material para o admin
- `org`  é a organização do usuario admin
- `caserveruri:porta` é o endereço do CA Server da organização com porta
- `caname` é o nome amigável do CA Server da organização

\`\`\`
./createCryptos.sh admin ecotrust.solutions ca.ecotrust.solutions:1234 ca-ecotrust
\`\`\`

**Nota:** Certifique-se de substituir os valores de exemplo pelos valores reais de sua rede Hyperledger Fabric.
