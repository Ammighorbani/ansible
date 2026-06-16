#!/bin/bash
set -e

SAMBA_REALM=${SAMBA_REALM:-"FPE.LOCAL"}
SAMBA_DOMAIN=${SAMBA_DOMAIN:-"FPE"}
SAMBA_ADMIN_PASSWORD=${SAMBA_ADMIN_PASSWORD:-"Admin@12345"}
SAMBA_DNS_FORWARDER=${SAMBA_DNS_FORWARDER:-"8.8.8.8"}

if [ ! -f /var/lib/samba/private/krb5.conf ]; then

    rm -f /etc/samba/smb.conf

    samba-tool domain provision \
	--server-role=dc \
	--use-rfc2307 \
	--dns-backend=SAMBA_INTERNAL \
	--realm="${SAMBA_REALM}" \
	--domain="${SAMBA_DOMAIN}" \
	--adminpass="${SAMBA_ADMIN_PASSWORD}"

    sed -i "/\[global\]/a\\\tdns forwarder = ${SAMBA_DNS_FORWARDER}" /etc/samba/smb.conf

    cp /var/lib/samba/private/krb5.conf /etc/krb5.conf
fi

if [ ! -f /etc/krb5.conf ] && [ -f /var/lib/samba/private/krb5.conf ]; then
    cp /var/lib/samba/private/krb5.conf /etc/krb5.conf
fi

exec samba --foreground --no-process-group
