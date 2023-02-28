#!/bin/bash
DOMAIN=$(curl icanhazip.com)
SSLIP="$DOMAIN.sslip.io"
sudo yum update -y
sudo yum install -y wget zip unzip docker git jq
sudo amazon-linux-extras install nginx1 java-openjdk11 -y 
sudo amazon-linux-extras install epel -y
sudo systemctl enable nginx
sudo systemctl start nginx
sudo service docker start
sudo usermod -aG docker ec2-user 
DC_VERSION=$(curl -L -s -H 'Accept: application/json' https://github.com/docker/compose/releases/latest | sed -e 's/.*"tag_name":"\([^"]*\)".*/\1/')
sudo curl -L "https://github.com/docker/compose/releases/download/$DC_VERSION/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo service docker restart
cat > jenkins <<EOF
server {
        listen 80;
        listen [::]:80;
        root /var/www/jenkins/html;
        index index.html index.htm index.nginx-debian.html;
        server_name $SSLIP www.$SSLIP;
        location / {
                #try_files $uri $uri/ =404;
                proxy_set_header Host \$host;
                proxy_set_header X-Real-IP \$remote_addr;
                proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Proto \$scheme;
                proxy_pass    http://$SSLIP:8080;
                proxy_read_timeout  90s;
        }
}
EOF
sudo mv jenkins /etc/nginx/conf.d/jenkins.conf 
sudo systemctl restart nginx
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
sudo wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
sudo yum install jenkins -y
sudo service jenkins start
sudo yum install -y certbot python2-certbot-nginx
sudo certbot --nginx --register-unsafely-without-email --agree-tos -d "${SSLIP}" --cert-name jenkins
sudo usermod -aG docker jenkins
sudo service docker restart
sudo service jenkins restart
echo "Installation is complete."

echo "# Open the URL for this server in a browser and log in with the following credentials:"
echo
echo "    URL: https://${SSLIP}"
echo "    Username: admin"
echo "    Password: $(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)"
echo
echo