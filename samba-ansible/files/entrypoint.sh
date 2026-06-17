#!/bin/bash
set -e

SAMBA_REALM=${SAMBA_REALM:-"FPE.LOCAL"}
SAMBA_DOMAIN=${SAMBA_DOMAIN:-"FPE"}
SAMBA_ADMIN_PASSWORD=${SAMBA_ADMIN_PASSWORD:-"Admin@12345"}
SAMBA_DNS_FORWARDER=${SAMBA_DNS_FORWARDER:-"8.8.8.8"}

# First run (domain not provisioned yet)
if [ ! -f /var/lib/samba/private/krb5.conf ]; then

    echo "Provisioning Samba AD Domain Controller..."

    rm -f /etc/samba/smb.conf

    samba-tool domain provision \
        --server-role=dc \
        --use-rfc2307 \
        --dns-backend=SAMBA_INTERNAL \
        --realm="${SAMBA_REALM}" \
        --domain="${SAMBA_DOMAIN}" \
        --adminpass="${SAMBA_ADMIN_PASSWORD}"

    # Add DNS forwarder
    sed -i "/\[global\]/a\\\tdns forwarder = ${SAMBA_DNS_FORWARDER}" /etc/samba/smb.conf

    # Configure Kerberos
    cp /var/lib/samba/private/krb5.conf /etc/krb5.conf

    # Create share folders
    mkdir -p /shares/public
    mkdir -p /shares/fpe_group

    chmod 777 /shares/public
    chmod 770 /shares/fpe_group

    # Add shares to smb.conf
    cat <<EOF >> /etc/samba/smb.conf

[Public-Share]
   path = /shares/public
   browsable = yes
   read only = no
   guest ok = yes

[FPE-Only]
   path = /shares/fpe_group
   browsable = yes
   read only = no
   valid users = @FPE

EOF

fi

# Ensure kerberos config exists
if [ ! -f /etc/krb5.conf ] && [ -f /var/lib/samba/private/krb5.conf ]; then
    cp /var/lib/samba/private/krb5.conf /etc/krb5.conf
fi

exec samba --foreground --no-process-group