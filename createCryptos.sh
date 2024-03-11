#!/bin/bash

. ./utils.sh

function createPeer() {
    org=$1
    caserver=$2
    caname=$3
    peerName=$4

    clear

    warnln "Insert password for CA Admin Server"
    read -s passwordAdmin

    warnln "Insert password for $peerName"
    read -s passwordPeer


    infoln "Enrolling the CA admin"
    export FABRIC_CA_CLIENT_HOME=$PWD/crypto-material/peerOrganizations/$org
    mkdir -p "$FABRIC_CA_CLIENT_HOME/msp/"
    cp ca-cert.pem $FABRIC_CA_CLIENT_HOME

    set -x
    fabric-ca-client enroll -u https://admin:$passwordAdmin@$caserver --caname $caname --tls.certfiles ca-cert.pem
    { set +x; } 2>/dev/null
    
    

    echo "NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/$(echo "$caserver" | sed 's/:/-/g')-$caname.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/$(echo "$caserver" | sed 's/:/-/g')-$caname.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/$(echo "$caserver" | sed 's/:/-/g')-$caname.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/$(echo "$caserver" | sed 's/:/-/g')-$caname.pem
    OrganizationalUnitIdentifier: orderer" > "$FABRIC_CA_CLIENT_HOME/msp/config.yaml"

    infoln "Copying ca-cert for the correct places\n"

    # Copy org1's CA cert to org1's /msp/tlscacerts directory (for use in the channel MSP definition)
    mkdir -p "$FABRIC_CA_CLIENT_HOME/msp/tlscacerts"
    cp ./ca-cert.pem "$FABRIC_CA_CLIENT_HOME/msp/tlscacerts/ca.crt"
    # Copy org1's CA cert to org1's /tlsca directory (for use by clients)
    mkdir -p "$FABRIC_CA_CLIENT_HOME/tlsca"
    cp ./ca-cert.pem "$FABRIC_CA_CLIENT_HOME/tlsca/tlsca.$org-cert.pem"
    # Copy org1's CA cert to org1's /ca directory (for use by clients)
    mkdir -p "$FABRIC_CA_CLIENT_HOME/ca"
    cp ./ca-cert.pem "$FABRIC_CA_CLIENT_HOME/ca/ca.$org-cert.pem"

    infoln "Registering $peerName"
    set -x
    fabric-ca-client register --caname $caname --id.name $peerName --id.secret $passwordPeer --id.type peer --tls.certfiles ca-cert.pem
    { set +x; } 2>/dev/null

    infoln "Generating the $peerName msp"
    set -x
    fabric-ca-client enroll -u https://$peerName:$passwordPeer@$caserver --caname $caname -M "$FABRIC_CA_CLIENT_HOME/peers/$peerName.$org/msp" --tls.certfiles ca-cert.pem
    { set +x; } 2>/dev/null

    cp "$FABRIC_CA_CLIENT_HOME/msp/config.yaml" "$FABRIC_CA_CLIENT_HOME/peers/$peerName.$org/msp/config.yaml"

    infoln "Generating the $peerName-tls certificates, using --csr.hosts to specify Subject Alternative Names"
    set -x
    fabric-ca-client enroll -u https://$peerName:$passwordPeer@$caserver --caname $caname -M "$FABRIC_CA_CLIENT_HOME/peers/$peerName.$org/tls" --enrollment.profile tls --csr.hosts $peerName.$org --csr.hosts localhost --tls.certfiles ca-cert.pem
    { set +x; } 2>/dev/null

    # Copying the tls CA cert, server cert, server keystore to well known file names in the peer's tls directory that are referenced by peer startup config
    cp "$FABRIC_CA_CLIENT_HOME/peers/$peerName.$org/tls/tlscacerts/"* "$FABRIC_CA_CLIENT_HOME/peers/$peerName.$org/tls/ca.crt"
    cp "$FABRIC_CA_CLIENT_HOME/peers/$peerName.$org/tls/signcerts/"* "$FABRIC_CA_CLIENT_HOME/peers/$peerName.$org/tls/server.crt"
    cp "$FABRIC_CA_CLIENT_HOME/peers/$peerName.$org/tls/keystore/"* "$FABRIC_CA_CLIENT_HOME/peers/$peerName.$org/tls/server.key"

    successln "\n\n\nPeer $peerName.$org with user $peerName created sucessfully at the server $caserver\n\n"

}

function createOrderer() {
    org=$1
    caserver=$2
    caname=$3
    ordererName=$4

    clear

    warnln "Insert password for CA Admin Server"
    read -s passwordAdmin

    warnln "Insert password for $ordererName"
    read -s passwordOrderer

    infoln "Enrolling the CA admin"
    export FABRIC_CA_CLIENT_HOME=$PWD/crypto-material/ordererOrganizations/$org
    mkdir -p "$FABRIC_CA_CLIENT_HOME/msp/"
    cp ca-cert.pem $FABRIC_CA_CLIENT_HOME

    set -x
    fabric-ca-client enroll -u https://admin:$passwordAdmin@$caserver --caname $caname --tls.certfiles ca-cert.pem
    { set +x; } 2>/dev/null
    
    

    echo "NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/$(echo "$caserver" | sed 's/:/-/g')-$caname.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/$(echo "$caserver" | sed 's/:/-/g')-$caname.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/$(echo "$caserver" | sed 's/:/-/g')-$caname.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/$(echo "$caserver" | sed 's/:/-/g')-$caname.pem
    OrganizationalUnitIdentifier: orderer" > "$FABRIC_CA_CLIENT_HOME/msp/config.yaml"

    infoln "Copying ca-cert for the correct places\n"

    # Copy org1's CA cert to org1's /msp/tlscacerts directory (for use in the channel MSP definition)
    mkdir -p "$FABRIC_CA_CLIENT_HOME/msp/tlscacerts"
    cp ./ca-cert.pem "$FABRIC_CA_CLIENT_HOME/msp/tlscacerts/ca.crt"
    # Copy org1's CA cert to org1's /tlsca directory (for use by clients)
    mkdir -p "$FABRIC_CA_CLIENT_HOME/tlsca"
    cp ./ca-cert.pem "$FABRIC_CA_CLIENT_HOME/tlsca/tlsca.$org-cert.pem"
    # Copy org1's CA cert to org1's /ca directory (for use by clients)
    mkdir -p "$FABRIC_CA_CLIENT_HOME/ca"
    cp ./ca-cert.pem "$FABRIC_CA_CLIENT_HOME/ca/ca.$org-cert.pem"

    infoln "Registering $ordererName"
    set -x
    fabric-ca-client register --caname $caname --id.name $ordererName --id.secret $passwordOrderer --id.type orderer --tls.certfiles ca-cert.pem
    { set +x; } 2>/dev/null


    infoln "Generating the $ordererName msp"
    set -x
    fabric-ca-client enroll -u https://$ordererName:$passwordOrderer@$caserver --caname $caname -M "$FABRIC_CA_CLIENT_HOME/orderers/$ordererName.$org/msp" --tls.certfiles ca-cert.pem
    { set +x; } 2>/dev/null
    cp "/home/ericluque/EcotrustNew/organizations/ordererOrganizations/ecotrust.solutions/msp/config.yaml" "/home/ericluque/EcotrustNew/organizations/ordererOrganizations/ecotrust.solutions/orderers/orderer1.ecotrust.solutions/msp/config.yaml"

    infoln "Generating the orderer-tls certificates, use --csr.hosts to specify Subject Alternative Names"
    set -x
    fabric-ca-client enroll -u https://$ordererName:$passwordOrderer@$caserver --caname $caname -M "$FABRIC_CA_CLIENT_HOME/orderers/$ordererName.$org/tls" --enrollment.profile tls --csr.hosts $ordererName.$org --csr.hosts localhost --tls.certfiles ca-cert.pem
    { set +x; } 2>/dev/null

    infoln "Copy the tls CA cert, server cert, server keystore to well known file names in the orderer's tls directory that are referenced by orderer startup config"
    cp "$FABRIC_CA_CLIENT_HOME/orderers/$ordererName.$org/tls/tlscacerts/"* "$FABRIC_CA_CLIENT_HOME/orderers/$ordererName.$org/tls/ca.crt"
    cp "$FABRIC_CA_CLIENT_HOME/orderers/$ordererName.$org/tls/signcerts/"* "$FABRIC_CA_CLIENT_HOME/orderers/$ordererName.$org/tls/server.crt"
    cp "$FABRIC_CA_CLIENT_HOME/orderers/$ordererName.$org/tls/keystore/"* "$FABRIC_CA_CLIENT_HOME/orderers/$ordererName.$org/tls/server.key"

    ########################################################################

    infoln "Copy orderer org's CA cert to orderer's /msp/tlscacerts directory (for use in the orderer MSP definition)"
    mkdir -p "$FABRIC_CA_CLIENT_HOME/orderers/$ordererName.$org/msp/tlscacerts"
    cp "$FABRIC_CA_CLIENT_HOME/orderers/$ordererName.$org/tls/tlscacerts/"* "$FABRIC_CA_CLIENT_HOME/orderers/$ordererName.$org/msp/tlscacerts/tlsca.ecotrust.solutions-cert.pem"

    successln "\n\n\nOrderer $ordererName.$org with user $ordererName created sucessfully at the server $caserver\n\n"
}

function enrollAdmin() {
    org=$1
    caserver=$2
    caname=$3

    clear

    warnln "Insert password for $(echo $org | cut -d'.' -f1)Admin"
    read -s passwordAdmin

    infoln "Enrolling the CA admin"
    export FABRIC_CA_CLIENT_HOME=$PWD/crypto-material/ordererOrganizations/$org/users/Admin@$org/msp
    mkdir -p "$FABRIC_CA_CLIENT_HOME"
    cp ca-cert.pem $FABRIC_CA_CLIENT_HOME

    echo "NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/$(echo "$caserver" | sed 's/:/-/g')-$caname.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/$(echo "$caserver" | sed 's/:/-/g')-$caname.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/$(echo "$caserver" | sed 's/:/-/g')-$caname.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/$(echo "$caserver" | sed 's/:/-/g')-$caname.pem
    OrganizationalUnitIdentifier: orderer" > "$FABRIC_CA_CLIENT_HOME/users/Admin@$org/msp/config.yaml"



    infoln "Generating the admin msp"
    set -x
    fabric-ca-client enroll -u https://$(echo "$org" | cut -d'.' -f1)Admin:$passwordAdmin@$caserver --caname $caname -M "$FABRIC_CA_CLIENT_HOME/users/Admin@$org/msp" --tls.certfiles "$FABRIC_CA_CLIENT_HOME/ca-cert.pem"
    { set +x; } 2>/dev/null

    successln "\n\n\nSuccessfully enrolled Admin User for $org\n\n"

}

function createUser() {
    echo $1
}

function enrollUser() {
    echo $1
}

case $1 in
   "orderer") 
        if [ "$#" -ne 5 ]; then
            warnln "Create crypto-material for new orderer"
            warnln "Use: $0 <type> <org name> <caserver uri> <caname> <new peer name>"
            infoln "  i.e: $0 orderer ecotrust.solution ca.ecotrust.solutions:1234 ca-ecotrust orderer1"
            infoln "  i.e: $0 orderer ecotrust.solution 192.168.15.11:1234 ca-ecotrust orderer1"
            exit 1
        fi
        ip=$(echo "$3" | cut -d':' -f1)
        if ping -c 1 "$ip" &> /dev/null; then
            createOrderer "$2" "$3" "$4" "$5"
        else
            warnln "ping $3"
            warnln "O servidor não está respondendo."
        fi
    ;;
   "peer") 
        if [ "$#" -ne 5 ]; then
            warnln "Create crypto-material for new peer"
            warnln "Use: $0 <type> <org name> <caserver uri> <caname> <new peer name>"
            infoln "  i.e: $0 peer ecotrace.solution ca.ecotrace.solutions:1234 ca-ecotrace peer1"
            infoln "  i.e: $0 peer ecotrace.solution 192.168.15.10:1234 ca-ecotrace peer1"
            exit 1
        fi
        ip=$(echo "$3" | cut -d':' -f1)
        if ping -c 1 "$ip" &> /dev/null; then
            createPeer "$2" "$3" "$4" "$5"
        else
            warnln "ping $3"
            warnln "O servidor não está respondendo."
        fi
        
    ;;
   "admin") 
        if [ "$#" -ne 4 ]; then
            warnln "Enrolling Admin"
            warnln "Use: $0 admin <org name> <caserver uri> <caname>"
            infoln "  i.e: $0 admin ecotrace.solution ca.ecotrace.solutions:1234"
            infoln "  i.e: $0 admin ecotrace.solution 192.168.15.10:1234 ca-ecotrace"
            exit 1
        fi
        ip=$(echo "$3" | cut -d':' -f1)
        if ping -c 1 "$ip" &> /dev/null; then
            enrollAdmin  "$2" "$3" "$4"
        else
            warnln "ping $3"
            warnln "O servidor não está respondendo."
        fi
   ;;
   *) errorln "You must choose between orderer, peer, user ou admin.\nType help for more";;
esac
