#!/bin/bash

#################################################################################
# Bash script to setup the LAMP Stack on CentOS & Ubuntu               		#
# Written by: Alok				                                #
# Description: Install Linux + Apache + MySQL/MariaDB + PHP + Magento  		#
# Caution: Don't change anything without any basic knowledge of Linux & Bash.   #
#################################################################################

#################################################################################
#COLORS
Color_Off='\033[0m'       # Text Reset

#Regular Color Codes
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
#################################################################################

#Clear the terminal screen
printf "\033c"

#Checking for root User
if [ "$(id -u)" != "0" ]; then  
echo "=============================================================================="
echo -e "$Cyan This script must be run as root. $Red Don't Use sudo <yourscriptname.sh> $Color_Off"
echo "=============================================================================="
exit 1  
fi
echo ""

echo
echo -e "$Purple################################################################################$Color_Off"
echo -e "$Cyan Setup the LAMP Stack on CentOS & Ubuntu Servers $Color_Off"    
echo -e "$Cyan Author: Alok                        				     $Color_Off"
echo -e "$Purple################################################################################$Color_Off"
echo
echo ""

echo -e "$Red Detecting your Linux OS $Color_Off"
Linux_OS_Type=$(cat /etc/*release | awk -F '=' '/^NAME/{print $2}' | awk '{print $1}' | tr -d '"')

if [ "$Linux_OS_Type" == "Ubuntu" ] ;then
        echo -e "$Red Your OS : $Green $Linux_OS_Type $Color_Off"

  elif [ "$Linux_OS_Type" == "CentOS" ]; then
        echo -e "$Red Your OS : $Green $Linux_OS_Type $Color_Off"

        echo ""
  else
        echo "I am not able to Detect Your OS, Couldn't Install Packages".
        exit 1
fi
echo ""

echo -e "$Yellow Please sit back and relax while LAMP + Magento configures on your server, this may take several minutes $Color_Off"
echo ""

# If your VM or Server is having CentOS then; 
if [[ "$Linux_OS_Type" == "CentOS" ]]; then
echo "==============================================="
echo -e "$Yellow Installing System packages on your CentOS $Color_Off"
echo "==============================================="
yum install -y https://rpms.remirepo.net/enterprise/remi-release-7.rpm
CentOS_PACKAGE_NAME="epel-release gcc libssh2 libssh2-devel make bind-utils wget vim htop net-tools httpd git yum-utils certbot python-certbot-apache sudo"
yum update -y ; yum install -y $CentOS_PACKAGE_NAME

# Install PHP
while true
do
echo "====================================="
echo -e "$Cyan Installing PHP on your CentOS $Color_Off"
echo "====================================="

echo "Please choose a version of the PHP:"
echo -e "\t\033[32m1\033[0m. Install PHP-7.4"
echo -e "\t\033[32m2\033[0m. Install PHP-8.0"
echo -e "\t\033[32m3\033[0m. Install PHP-8.1"
read -p "Please input a number:" PHP_version

[ -z "$PHP_version" ] && PHP_version=1
case $PHP_version in
    1|2|3)
    echo
    echo "---------------------------"
    echo "You choose PHP = $PHP_version"
    echo "---------------------------"
    echo
    break
    ;;
    *)
    echo "Input error! Please only input number 1,2,3"
esac
done

if [ $PHP_version -eq 1 ]; then
	yum-config-manager --enable remi-php74
	yum update -y
    yum -y install php74-php php74-php-mcrypt php74-php-cli php74-php-intl php74-php-imagick php74-php-gd php74-php-pdo php74-php-xml php74-php-curl php74-php-soap php74-php-mysql php74-php-ldap php74-php-zip php74-php-fileinfo php74-php-opcache php74-php-fpm php74-php-gd php74-php-json php74-php-mbstring php74-php-mysqlnd php74-php-xml php74-php-xmlrpc php74-php-opcache php74-php-pecl-zip php74-php-bcmath php74-php-sodium
    yum install ImageMagick ImageMagick-devel ImageMagick-perl php-pecl-apcu phpmyadmin -y 
    systemctl restart php74-php-fpm
fi

if [ $PHP_version -eq 2 ]; then
	yum-config-manager --disable 'remi-php*'
	yum-config-manager --enable remi-php80
    yum -y install php80-php php80-php-mcrypt php80-php-cli php80-php-intl php80-php-imagick php80-php-gd php80-php-pdo php80-php-xml php80-php-curl php80-php-soap php80-php-mysql php80-php-ldap php80-php-zip php80-php-fileinfo php80-php-opcache php80-php-fpm php80-php-gd php80-php-json php80-php-mbstring php80-php-mysqlnd php80-php-xml php80-php-xmlrpc php80-php-opcache php80-php-pecl-zip php80-php-bcmath php80-php-sodium
    yum install ImageMagick ImageMagick-devel ImageMagick-perl php-pecl-apcu phpmyadmin -y
    systemctl restart php80-php-fpm
fi

if [ $PHP_version -eq 3 ]; then
	yum-config-manager --disable 'remi-php*'
	yum-config-manager --enable   remi-php81
    yum -y install php81-php php81-php-mcrypt php81-php-cli php81-php-intl php81-php-imagick php81-php-gd php81-php-pdo php81-php-xml php81-php-curl php81-php-soap php81-php-mysql php81-php-ldap php81-php-zip php81-php-fileinfo php81-php-opcache php81-php-fpm php81-php-gd php81-php-json php81-php-mbstring php81-php-mysqlnd php81-php-xml php81-php-xmlrpc php81-php-opcache php81-php-pecl-zip php81-php-bcmath php81-php-sodium
    yum install ImageMagick ImageMagick-devel ImageMagick-perl php-pecl-apcu phpmyadmin -y
    systemctl restart php81-php-fpm

fi

	echo "============================="
	echo -e "$Cyan Configuring Your php.ini $Color_Off"
	echo "============================="
	sed -i 's/memory_limit = 128M/memory_limit = 1024M/g' /etc/php.ini
	sed -i 's/max_execution_time = 30/max_execution_time = 60000/g' /etc/php.ini
	sed -i 's/max_input_time = 60/max_input_time = 12000/g' /etc/php.ini
	sed -i 's/output_buffering = 4096/output_buffering = 8096/g' /etc/php.ini
	sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 200M/g' /etc/php.ini
	sed -i 's/short_open_tag = Off/short_open_tag = On/g' /etc/php.ini
	sed -i 's/; max_input_vars = 1000/max_input_vars = 50000/g' /etc/php.ini
	sed -i 's/post_max_size = 8M/post_max_size = 500M/g' /etc/php.ini
	sed -i 's/expose_php = On/expose_php = Off/g' /etc/php.ini
	sed -i '19i Require all granted' /etc/httpd/conf.d/phpMyAdmin.conf
echo "PHP Install Completed and Configured!"
echo ""


echo "====================================="
echo -e "$Cyan Installing HTTPD Web Server on your CentOS $Color_Off"
echo "====================================="

# Install Apache
  echo "Start Installing Apache..."
  yum -y install httpd

# Add apache virtualhost
    #Define domain name
    read -p "(Please input domains such as: example.com):" domain
    if [ "$domain" = "" ]; then
        echo "You need input a domain."
        exit 1
    fi

    domains="echo $domain | awk '{ print $1 }'"
    if [ -f "/etc/httpd/conf.d/$domains.conf" ]; then
        echo "$domain is exist!"
        exit 1
    fi

    #Define Website Dir
    webdir="/var/www/html/$domain"
    DocumentRoot="$webdir/live"
    logsdir="$webdir/logs"
    mkdir -p $DocumentRoot $logsdir
    #Create vhost configuration file
    cat >/etc/httpd/conf.d/$domain.conf<<EOF
<Virtualhost *:80>
	ServerName www.$domain
	ServerAlias $domain
	DocumentRoot $DocumentRoot
	CustomLog $logsdir/access.log combined
	DirectoryIndex index.php index.html
	<Directory $DocumentRoot>
	Options +Includes -Indexes
	AllowOverride All
	Order Deny,Allow
	Allow from All
	</Directory>
</virtualhost>
EOF
    systemctl restart httpd > /dev/null 2>&1
    echo "Successfully configured your $domain in webserver vhost"

	#Installing SSL on your active domain
	echo -e "\t\033[32m\033[0m Installing SSL on Your Domain: $domain"
	echo ""
	echo -e "$Red Have you Created A Name Record for your $domain on our all-inkl's DNS (Y/N)? $Color_Off"
	read answer
	if [ "$answer" != "${answer#[Yy]}" ] ;then
		certbot --apache -d $domain
		echo "SSL active now"
	else
    echo -e "$Red ERROR: Not Able to active the SSL. Please do it Manually, Once your setup is done. $Color_Off"
	fi
	echo ""

# Database Option
while true
do

echo "Please choose a version of the Database:"
echo -e "\t\033[32m1\033[0m. Install MariaDB-10.x (recommend)"
echo -e "\t\033[32m2\033[0m. Install MySQL-8.x"
read -p "Please input a number: " DB_version
[ -z "$DB_version" ] && DB_version=1
case $DB_version in
    1|2)
    echo
    echo "---------------------------"
    echo "You have Chosen = $DB_version"
    echo "---------------------------"
    echo
    break
    ;;
    *)
    echo "Input error! Please only input number 1,2"
esac
done

# Choose database
    if [ $DB_version -eq 1 ]; then
    # Install MariaDB
    echo "Start Installing MariaDB..."
    cat <<EOF >> /etc/yum.repos.d/mariadb.repo
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.4/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
EOF
	yum install -y mariadb-server mariadb
	# Starting MariaDB Service
	systemctl enable mariadb
	systemctl start mariadb
	mysql_secure_installation

    echo "MariaDB Install completed!"

    elif [ $DB_version -eq 2 ]; then
    # Install MySQL
    echo "Start Installing MySQL..."
    rpm -Uvh https://repo.mysql.com/mysql80-community-release-el7-3.noarch.rpm
    rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2022
    sed -i 's/enabled=1/enabled=0/' /etc/yum.repos.d/mysql-community.repo
    yum --enablerepo=mysql80-community install mysql-community-server -y
    systemctl enable mysqld
    # ReStart mysqld service
    systemctl restart mysqld
    # Show the default password for root user
    echo "==========================="
	echo -e "$Red Your New Root Password $Color_Off"
    grep "A temporary password" /var/log/mysqld.log
    echo "==========================="
    # MySQL Secure Installation
    mysql_secure_installation

    echo "MySQL Install completed!"
    fi

echo "==========================="
echo -e "$Cyan Elasticsearch Installation $Color_Off"
echo "==========================="
echo -e "$Red You want to Install Elasticsearch 7.x (Y/N)? $Color_Off"
read answer
if [ "$answer" != "${answer#[Yy]}" ] ;then
	rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
	cat <<EOF >> /etc/yum.repos.d/elasticsearch.repo
[elasticsearch]
name=Elasticsearch repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=0
autorefresh=1
type=rpm-md
EOF
yum install --enablerepo=elasticsearch elasticsearch -y
systemctl enable elasticsearch.service
systemctl daemon-reload
systemctl start elasticsearch.service

else
    echo -e "$Red ERROR: Not Installed Successfully. Please do it manually. $Color_Off"
fi
echo ""

echo "==========================="
echo -e "$Cyan PHP Composer - 2.x.x Installation $Color_Off"
echo "==========================="
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('sha384', 'composer-setup.php') === '55ce33d7678c5a611085589f1f3ddf8b3c52d662cd01d4ba75c0ee0459970c2200a51f492d557530c71c15d8dba01eae') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php
php -r "unlink('composer-setup.php');"
mv composer.phar /usr/local/bin/composer

# Choose Magento Version
    while true
    do
    echo "Please choose a version of the Magneto:"
    echo -e "\t\033[32m1\033[0m. Install Community Edition"
    echo -e "\t\033[32m2\033[0m. Install Enterprise Edition"
    read -p "Please input a number:" Magento_version
    [ -z "$Magento_version" ] && Magento_version=1
    case $Magento_version in
        1|2)
        echo
        echo "---------------------------"
        echo "You choose = $Magento_version"
        echo "---------------------------"
        echo
        break
        ;;
        *)
        echo "Input error! Please only input number 1,2"
    esac
    done

    # Creating MySQL Database for the Magento
  if [ $DB_version -eq 1 ]; then
	echo "Please enter root user MySQL password!"
	echo "Note: password will be hidden when typing"
	read -s rootpasswd
	echo "Please enter the NAME of the new MySQL database! (example: database1)"
	read dbname
	echo "Please enter the MySQL database CHARACTER SET! (example: latin1, utf8, ...)"
	echo "Enter utf8 if you don't know what you are doing"
	read charset
	echo "Creating new MySQL database..."
	mysql -uroot -p${rootpasswd} -e "CREATE DATABASE ${dbname} /*\!40100 DEFAULT CHARACTER SET ${charset} */;"
	echo "Database successfully created!"
	echo "Showing existing databases..."
	mysql -uroot -p${rootpasswd} -e "show databases;"
	echo ""
	echo "Please enter the NAME of the new MySQL database user! (example: user1)"
	read username
	echo "Please enter the PASSWORD for the new MySQL database user!"
	echo "Note: password will be hidden when typing"
	read -s userpass
	echo "Creating new user..."
	mysql -uroot -p${rootpasswd} -e "CREATE USER ${username}@localhost IDENTIFIED BY '${userpass}';"
	echo "User successfully created!"
	echo ""
	echo "Granting ALL privileges on ${dbname} to ${username}!"
	mysql -uroot -p${rootpasswd} -e "GRANT ALL PRIVILEGES ON ${dbname}.* TO '${username}'@'localhost';"
	mysql -uroot -p${rootpasswd} -e "FLUSH PRIVILEGES;"
	echo "You're good now :)"

fi

# Creating MySQL 8.x Database for the Magento
 if [ $DB_version -eq 2 ]; then
	read -p "Enter your MySQL root password: " rootpass
	echo "UNINSTALL COMPONENT 'file://component_validate_password';" | mysql -u root -p$rootpass
	read -p "New Database name: " dbname
	read -p "New Database username: " username
	read -p "Enter a password for user $username: " userpass
	echo "CREATE DATABASE $dbname;" | mysql -u root -p$rootpass
	echo "CREATE USER '$dbuser'@'localhost' IDENTIFIED BY '$userpass';" | mysql -u root -p$rootpass
	echo "GRANT ALL PRIVILEGES ON $dbname.* TO '$dbuser'@'localhost';" | mysql -u root -p$rootpass
	echo "FLUSH PRIVILEGES;" | mysql -u root -p$rootpass
	echo "New MySQL Database is successfully created"
	echo "You're good now :)"
fi
echo ""

    # Installing Magento
    if [ $Magento_version -eq 1 ]; then
    	 echo -e "$Green Start Installing Magneto...$Color_Off"
    	 composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition $DocumentRoot
    	 cd $DocumentRoot
        php -dmemory_limit=6G bin/magento setup:install \
		--base-url=https://$domain \
		--db-host=localhost \
		--db-name=${dbname} \
		--db-user=${username} \
		--db-password=${userpass} \
		--admin-firstname=admin \
		--admin-lastname=admin \
		--admin-email=admin@admin.com \
		--admin-user=admin \
		--admin-password=admin123 \
		--language=en_US \
		--currency=USD \
		--timezone=America/Chicago \
		--use-rewrites=1 \
		--search-engine=elasticsearch7 \
		--elasticsearch-host=localhost \
		--elasticsearch-port=9200 \
		--elasticsearch-index-prefix=magento2 \
		--elasticsearch-timeout=15
		echo "Disabling Two Factor Auth (2FA)"
		bin/magento module:disable Magento_TwoFactorAuth
		echo ""
		echo "Compiling & Deployment of the Magneto"
		rm -rf generated/* && php -dmemory_limit=6G bin/magento setup:upgrade && php -dmemory_limit=6G bin/magento setup:di:compile && chmod -R 777 var generated pub/static && rm -rf pub/static/frontend/ && rm -rf pub/static/adminhtml/ && rm -rf var/view_preprocessed/ && php -dmemory_limit=6G bin/magento setup:static-content:deploy de_DE en_US -f && php -dmemory_limit=6G bin/magento cache:flush && chmod -R 777 var generated pub/static
    fi

    if [ $Magento_version -eq 2 ]; then
    	 echo -e "$Green Start Installing Magneto...$Color_Off"
        composer create-project --repository-url=https://repo.magento.com/ magento/project-enterprise-edition $DocumentRoot
        cd $DocumentRoot
        php -dmemory_limit=6G bin/magento setup:install \
		--base-url=https://$domain \
		--db-host=localhost \
		--db-name=${dbname} \
		--db-user=${username} \
		--db-password=${userpass} \
		--admin-firstname=admin \
		--admin-lastname=admin \
		--admin-email=admin@admin.com \
		--admin-user=admin \
		--admin-password=admin123 \
		--language=en_US \
		--currency=USD \
		--timezone=America/Chicago \
		--use-rewrites=1 \
		--search-engine=elasticsearch7 \
		--elasticsearch-host=localhost \
		--elasticsearch-port=9200 \
		--elasticsearch-index-prefix=magento2 \
		--elasticsearch-timeout=15
		echo "Disabling Two Factor Auth (2FA)"
		bin/magento module:disable Magento_TwoFactorAuth
		echo ""
		echo "Compiling & Deployment of the Magneto"
		rm -rf generated/* && php -dmemory_limit=6G bin/magento setup:upgrade && php -dmemory_limit=6G bin/magento setup:di:compile && chmod -R 777 var generated pub/static && rm -rf pub/static/frontend/ && rm -rf pub/static/adminhtml/ && rm -rf var/view_preprocessed/ && php -dmemory_limit=6G bin/magento setup:static-content:deploy de_DE en_US -f && php -dmemory_limit=6G bin/magento cache:flush && chmod -R 777 var generated pub/static
	fi

echo "==========================="
echo -e "$Cyan Restaring HTTPD $Color_Off"
echo "==========================="
# HTTPD Restart
systemctl restart httpd

fi

# If your VM or Server is having Ubuntu then; 

if [[ "$Linux_OS_Type" == "Ubuntu" ]]; then
echo "==============================================="
echo "Installing initial packages for Ubuntu"
echo "==============================================="
apt update -y && apt upgrade -y
PCKGS=("apache2" "curl" "vim" "git" "htop" "zip" "unzip" "build-essential" "software-properties-common" "certbot python3-certbot-apache")

for PCKG in "${PCKGS[@]}"
do
	apt -y install ${PCKG}
done

add-apt-repository ppa:ondrej/php
apt update -y

echo "Enabling Apache modules"
echo ''
a2enmod rewrite  &>/dev/null

while true
do

# Install PHP
echo "====================================="
echo -e "$Cyan Installing PHP on your CentOS $Color_Off"
echo "====================================="

echo "Please choose a version of the PHP:"
echo -e "\t\033[32m1\033[0m. Install PHP-7.4"
echo -e "\t\033[32m2\033[0m. Install PHP-8.0"
echo -e "\t\033[32m3\033[0m. Install PHP-8.1"
read -p "Please input a number:" PHP_version

[ -z "$PHP_version" ] && PHP_version=1
case $PHP_version in
    1|2|3)
    echo
    echo "---------------------------"
    echo "You have Chosen = $PHP_version"
    echo "---------------------------"
    echo
    break
    ;;
    *)
    echo "Input error! Please only input number 1,2,3"
esac
done

if [ $PHP_version -eq 1 ]; then
	apt install -y php7.4 php7.4-common libapache2-mod-php7.4 php7.4-cli php7.4-fpm php7.4-common libapache2-mod-fcgid php7.4-cli php7.4-curl php7.4-mysqlnd php7.4-gd php7.4-opcache php7.4-zip php7.4-intl php7.4-common php7.4-bcmath php7.4-imap php7.4-imagick php7.4-xmlrpc php7.4-readline php7.4-memcached php7.4-redis php7.4-mbstring php7.4-apcu php7.4-xml php7.4-dom php7.4-redis php7.4-memcached php7.4-memcache php7.4-soap
	a2enmod proxy_fcgi setenvif && a2enconf php7.4-fpm

	echo "============================="
	echo -e "$Cyan Configuring Your php.ini $Color_Off"
	echo "============================="
	sed -i 's/memory_limit = 128M/memory_limit = 1024M/g' /etc/php/7.4/fpm/php.ini
	sed -i 's/max_execution_time = 30/max_execution_time = 60000/g' /etc/php/7.4/fpm/php.ini
	sed -i 's/max_input_time = 60/max_input_time = 12000/g' /etc/php/7.4/fpm/php.ini
	sed -i 's/output_buffering = 4096/output_buffering = 8096/g' /etc/php/7.4/fpm/php.ini
	sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 200M/g' /etc/php/7.4/fpm/php.ini
	sed -i 's/short_open_tag = Off/short_open_tag = On/g' /etc/php/7.4/fpm/php.ini
	sed -i 's/; max_input_vars = 1000/max_input_vars = 50000/g' /etc/php/7.4/fpm/php.ini
	sed -i 's/post_max_size = 8M/post_max_size = 500M/g' /etc/php/7.4/fpm/php.ini
	sed -i 's/expose_php = On/expose_php = Off/g' /etc/php/7.4/fpm/php.ini
	echo ""
	systemctl restart apache2
	systemctl restart php7.4-fpm
fi

if [ $PHP_version -eq 2 ]; then
	apt install -y php8.0 php8.0-common libapache2-mod-php8.0 php8.0-cli php8.0-fpm php8.0-common libapache2-mod-fcgid php8.0-cli php8.0-curl php8.0-mysqlnd php8.0-gd php8.0-opcache php8.0-zip php8.0-intl php8.0-common php8.0-bcmath php8.0-imap php8.0-imagick php8.0-xmlrpc php8.0-readline php8.0-memcached php8.0-redis php8.0-mbstring php8.0-apcu php8.0-xml php8.0-dom php8.0-redis php8.0-memcached php8.0-memcache php8.0-soap
	a2enmod proxy_fcgi setenvif && a2enconf php8.0-fpm

	echo "============================="
	echo -e "$Cyan Configuring Your php.ini $Color_Off"
	echo "============================="
	sed -i 's/memory_limit = 128M/memory_limit = 1024M/g' /etc/php/8.0/fpm/php.ini
	sed -i 's/max_execution_time = 30/max_execution_time = 60000/g' /etc/php/8.0/fpm/php.ini
	sed -i 's/max_input_time = 60/max_input_time = 12000/g' /etc/php/8.0/fpm/php.ini
	sed -i 's/output_buffering = 4096/output_buffering = 8096/g' /etc/php/8.0/fpm/php.ini
	sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 200M/g' /etc/php/8.0/fpm/php.ini
	sed -i 's/short_open_tag = Off/short_open_tag = On/g' /etc/php/8.0/fpm/php.ini
	sed -i 's/; max_input_vars = 1000/max_input_vars = 50000/g' /etc/php/8.0/fpm/php.ini
	sed -i 's/post_max_size = 8M/post_max_size = 500M/g' /etc/php/8.0/fpm/php.ini
	sed -i 's/expose_php = On/expose_php = Off/g' /etc/php/8.0/fpm/php.ini
	echo ""
	systemctl restart apache2
	systemctl restart php8.0-fpm
fi

if [ $PHP_version -eq 3 ]; then
	apt install -y php8.1 php8.1-common libapache2-mod-php8.1 php8.1-cli php8.1-fpm php8.1-common libapache2-mod-fcgid php8.1-cli php8.1-curl php8.1-mysqlnd php8.1-gd php8.1-opcache php8.1-zip php8.1-intl php8.1-common php8.1-bcmath php8.1-imap php8.1-imagick php8.1-xmlrpc php8.1-readline php8.1-memcached php8.1-redis php8.1-mbstring php8.1-apcu php8.1-xml php8.1-dom php8.1-redis php8.1-memcached php8.1-memcache php8.1-soap
	a2enmod proxy_fcgi setenvif && a2enconf php8.1-fpm

	echo "============================="
	echo -e "$Cyan Configuring Your php.ini $Color_Off"
	echo "============================="
	sed -i 's/memory_limit = 128M/memory_limit = 1024M/g' /etc/php/8.1/fpm/php.ini
	sed -i 's/max_execution_time = 30/max_execution_time = 60000/g' /etc/php/8.1/fpm/php.ini
	sed -i 's/max_input_time = 60/max_input_time = 12000/g' /etc/php/8.1/fpm/php.ini
	sed -i 's/output_buffering = 4096/output_buffering = 8096/g' /etc/php/8.1/fpm/php.ini
	sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 200M/g' /etc/php/8.1/fpm/php.ini
	sed -i 's/short_open_tag = Off/short_open_tag = On/g' /etc/php/8.1/fpm/php.ini
	sed -i 's/; max_input_vars = 1000/max_input_vars = 50000/g' /etc/php/8.1/fpm/php.ini
	sed -i 's/post_max_size = 8M/post_max_size = 500M/g' /etc/php/8.1/fpm/php.ini
	sed -i 's/expose_php = On/expose_php = Off/g' /etc/php/8.1/fpm/php.ini
	echo ""
	systemctl restart apache2
	systemctl restart php8.1-fpm

EOF
fi

echo "PHP Install Completed!"

# Choose databese
    while true
    do
    echo "Please choose a version of the Database:"
    echo -e "\t\033[32m1\033[0m. Install MariaDB 10.x(recommend)"
    echo -e "\t\033[32m2\033[0m. Install Mysql 8.x"
    read -p "Please input a number:" DB_version
    [ -z "$DB_version" ] && DB_version=1
    case $DB_version in
        1|2)
        echo
        echo "---------------------------"
        echo "You choose = $DB_version"
        echo "---------------------------"
        echo
        break
        ;;
        *)
        echo "Input error! Please only input number 1,2"
    esac
    done

# Install database
    if [ $DB_version -eq 1 ]; then
    	# Install MariaDB
    	echo "Start Installing MariaDB..."
    	apt -y install mariadb-server
    	mysql_secure_installation
    	# ReStart mysqld service
    	systemctl restart mariadb.service
    echo "MariaDB Install completed!"

    elif [ $DB_version -eq 2 ]; then
            # Install MySQL
    	echo "Start Installing MySQL..."
    	wget https://dev.mysql.com/get/mysql-apt-config_0.8.22-1_all.deb
    	dpkg -i mysql-apt-config_0.8.22-1_all.deb
    	apt update
    	apt -y install mysql-client mysql-community-server mysql-server
    	mysql_secure_installation
    	# ReStart mysqld service
    	systemctl restart mysql
    	echo "MySQL Install completed!"
    fi


echo "==========================="
echo -e "$Cyan Elasticsearch Installation $Color_Off"
echo "==========================="
echo -e "$Red You want to Install Elasticsearch 7.x (Y/N)? $Color_Off"
read answer
if [ "$answer" != "${answer#[Yy]}" ] ;then
	curl -fsSL https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
	echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-7.x.list
	apt update
	apt install elasticsearch
	systemctl enable elasticsearch
	systemctl restart elasticsearch
else
    echo -e "$Red ERROR: Not Installed Successfully. Please do it manually. $Color_Off"
fi
echo ""

echo "====================================="
echo -e "$Cyan Installing HTTPD Web Server on your CentOS $Color_Off"
echo "====================================="
# Add apache virtualhost
    #Define domain name
    read -p "(Please input domains such as: example.com):" domain
    if [ "$domain" = "" ]; then
        echo "You need input a domain."
        exit 1
    fi

    domains="echo $domain | awk '{ print $1 }'"
    if [ -f "/etc/apache2/sites-available/$domains.conf" ]; then
        echo "$domain is exist!"
        exit 1
    fi

    #Define Website Dir
    webdir="/var/www/html/$domain"
    DocumentRoot="$webdir/live"
    logsdir="$webdir/logs"
    mkdir -p $DocumentRoot $logsdir
    #Create vhost configuration file
    cat >/etc/apache2/sites-available/$domain.conf<<EOF
<Virtualhost *:80>
	ServerName www.$domain
	ServerAlias $domain
	DocumentRoot $DocumentRoot
	CustomLog $logsdir/access.log combined
	DirectoryIndex index.php index.html
	<Directory $DocumentRoot>
	Options +Includes -Indexes
	AllowOverride All
	Order Deny,Allow
	Allow from All
	</Directory>
</virtualhost>
EOF
    a2ensite $domain.conf > /dev/null 2>&1
    systemctl restart apache2
    echo "Successfully configured your $domain in webserver apache2 vhost"

	#Installing SSL on your active domain
	echo -e "\t\033[32m1\033[0m. Installing SSL on Your Domain: $domain"
	echo -e "$Red Have you Created A Name Record for your $domain on our all-inkl's DNS (Y/N)? $Color_Off"
	read answer
	if [ "$answer" != "${answer#[Yy]}" ] ;then
		certbot --apache -d $domain
		echo "SSL active now"
	else
    echo -e "$Red ERROR: Not Able to active the SSL. Please do it Manually, Once your setup is done. $Color_Off"
	fi
	echo ""

echo "==========================="
echo -e "$Cyan PHP Composer - 2.x.x Installation $Color_Off"
echo "==========================="
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('sha384', 'composer-setup.php') === '55ce33d7678c5a611085589f1f3ddf8b3c52d662cd01d4ba75c0ee0459970c2200a51f492d557530c71c15d8dba01eae') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php
php -r "unlink('composer-setup.php');"
mv composer.phar /usr/local/bin/composer

# Choose Magento Version
    while true
    do
    echo "Please choose a version of the Magneto:"
    echo -e "\t\033[32m1\033[0m. Install Community Edition"
    echo -e "\t\033[32m2\033[0m. Install Enterprise Edition"
    read -p "Please input a number:" Magento_version
    [ -z "$Magento_version" ] && Magento_version=1
    case $Magento_version in
        1|2)
        echo
        echo "---------------------------"
        echo "You choose = $Magento_version"
        echo "---------------------------"
        echo
        break
        ;;
        *)
        echo "Input error! Please only input number 1,2"
    esac
    done

    # Creating MySQL 8.x Database for the Magento
    if [ $DB_version -eq 2 ]; then
	read -p "Enter your MySQL root password: " rootpass
	echo "UNINSTALL COMPONENT 'file://component_validate_password';" | mysql -u root -p$rootpass
	read -p "New Database name: " dbname
	read -p "New Database username: " dbuser
	read -p "Enter a password for user $username: " userpass
	echo "CREATE DATABASE $dbname;" | mysql -u root -p$rootpass
	echo "CREATE USER '$dbuser'@'localhost' IDENTIFIED BY '$userpass';" | mysql -u root -p$rootpass
	echo "GRANT ALL PRIVILEGES ON $dbname.* TO '$dbuser'@'localhost';" | mysql -u root -p$rootpass
	echo "FLUSH PRIVILEGES;" | mysql -u root -p$rootpass
	echo "New MySQL Database is successfully created"
	echo "You're good now :)"
fi
echo ""

   if [ $DB_version -eq 1 ]; then
    # Creating MySQL Database for the Magento
	echo "Please enter root user MySQL password!"
	echo "Note: password will be hidden when typing"
	read -s rootpasswd
	echo "Please enter the NAME of the new MySQL database! (example: database1)"
	read dbname
	echo "Please enter the MySQL database CHARACTER SET! (example: latin1, utf8, ...)"
	echo "Enter utf8 if you don't know what you are doing"
	read charset
	echo "Creating new MySQL database..."
	mysql -uroot -p${rootpasswd} -e "CREATE DATABASE ${dbname} /*\!40100 DEFAULT CHARACTER SET ${charset} */;"
	echo "Database successfully created!"
	echo "Showing existing databases..."
	mysql -uroot -p${rootpasswd} -e "show databases;"
	echo ""
	echo "Please enter the NAME of the new MySQL database user! (example: user1)"
	read username
	echo "Please enter the PASSWORD for the new MySQL database user!"
	echo "Note: password will be hidden when typing"
	read -s userpass
	echo "Creating new user..."
	mysql -uroot -p${rootpasswd} -e "CREATE USER ${username}@localhost IDENTIFIED BY '${userpass}';"
	echo "User successfully created!"
	echo ""
	echo "Granting ALL privileges on ${dbname} to ${username}!"
	mysql -uroot -p${rootpasswd} -e "GRANT ALL PRIVILEGES ON ${dbname}.* TO '${username}'@'localhost';"
	mysql -uroot -p${rootpasswd} -e "FLUSH PRIVILEGES;"
	echo "You're good now :)"
fi
echo ""

    # Installing Magento
    if [ $Magento_version -eq 1 ]; then
    	 echo -e "$Green Start Installing Magneto...$Color_Off"
    	 composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition $DocumentRoot
    	 cd $DocumentRoot
        php -dmemory_limit=6G bin/magento setup:install \
		--base-url=https://$domain \
		--db-host=localhost \
		--db-name=${dbname} \
		--db-user=${username} \
		--db-password=${userpass} \
		--admin-firstname=admin \
		--admin-lastname=admin \
		--admin-email=admin@admin.com \
		--admin-user=admin \
		--admin-password=admin123 \
		--language=en_US \
		--currency=USD \
		--timezone=America/Chicago \
		--use-rewrites=1 \
		--search-engine=elasticsearch7 \
		--elasticsearch-host=localhost \
		--elasticsearch-port=9200 \
		--elasticsearch-index-prefix=magento2 \
		--elasticsearch-timeout=15
		echo "Disabling Two Factor Auth (2FA)"
		bin/magento module:disable Magento_TwoFactorAuth
		echo ""
		echo "Compiling & Deployment of the Magneto"
		rm -rf generated/* && php -dmemory_limit=6G bin/magento setup:upgrade && php -dmemory_limit=6G bin/magento setup:di:compile && chmod -R 777 var generated pub/static && rm -rf pub/static/frontend/ && rm -rf pub/static/adminhtml/ && rm -rf var/view_preprocessed/ && php -dmemory_limit=6G bin/magento setup:static-content:deploy de_DE en_US -f && php -dmemory_limit=6G bin/magento cache:flush && chmod -R 777 var generated pub/static
    fi

    if [ $Magento_version -eq 2 ]; then
    	 echo -e "$Green Start Installing Magneto...$Color_Off"
        composer create-project --repository-url=https://repo.magento.com/ magento/project-enterprise-edition $DocumentRoot
        cd $DocumentRoot
        php -dmemory_limit=6G bin/magento setup:install \
		--base-url=https://$domain \
		--db-host=localhost \
		--db-name=${dbname} \
		--db-user=${dbuser} \
		--db-password=${userpass} \
		--admin-firstname=admin \
		--admin-lastname=admin \
		--admin-email=admin@admin.com \
		--admin-user=admin \
		--admin-password=admin123 \
		--language=en_US \
		--currency=USD \
		--timezone=America/Chicago \
		--use-rewrites=1 \
		--search-engine=elasticsearch7 \
		--elasticsearch-host=localhost \
		--elasticsearch-port=9200 \
		--elasticsearch-index-prefix=magento2 \
		--elasticsearch-timeout=15
		echo "Disabling Two Factor Auth (2FA)"
		bin/magento module:disable Magento_TwoFactorAuth
		echo ""
		echo "Compiling & Deployment of the Magneto"
		rm -rf generated/* && php -dmemory_limit=6G bin/magento setup:upgrade && php -dmemory_limit=6G bin/magento setup:di:compile && chmod -R 777 var generated pub/static && rm -rf pub/static/frontend/ && rm -rf pub/static/adminhtml/ && rm -rf var/view_preprocessed/ && php -dmemory_limit=6G bin/magento setup:static-content:deploy de_DE en_US -f && php -dmemory_limit=6G bin/magento cache:flush && chmod -R 777 var generated pub/static
	fi
echo ""
echo -e "$Green Enjoy! LAMP + Magneto Installed Successfully on your VM/Server.$Color_Off"
fi
echo ""

echo "====================================="
echo -e "$Cyan Setting up Security Rules $Color_Off"
echo "====================================="
sed -i -e 's/#Port 22/Port 2105/g' /etc/ssh/sshd_config
sed -i -e 's/#PermitRootLogin yes/PermitRootLogin yes/g' /etc/ssh/sshd_config
systemctl reload sshd
iptables -F
echo "Done!"
echo ""

echo -e "$Yellow######################### IMP! Information about your Server ############################$Color_Off"
echo -e "Your Working Directory is: $DocumentRoot"
IP=$(hostname -I | awk '{ print $2 }')
echo -e "Your VM/Server IP Address: $IP"
echo -e "Your New SSH Port is: 215"
mg_backend="$(grep -m1 frontName "$DocumentRoot/app/etc/env.php" | cut -d "'" -f 4)"
echo -e "Your Magento Backend URL:-" http://"$domain/$mg_backend"
Username: admin
Password: admin123
echo -e "$Red Note:Color_Off" Please change your password on your first login!
echo -e "$Yellow#########################################################################################$Color_Off"
echo ""

echo -e "$Red Rebooting your server after 10sec., Please wait... $Color_Off"
sleep 10;
reboot
