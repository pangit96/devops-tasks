openssl rand -base64 741 > /etc/mongo-keyfile
chown 999:999 /etc/mongo-keyfile
chmod 600 /etc/mongo-keyfile
