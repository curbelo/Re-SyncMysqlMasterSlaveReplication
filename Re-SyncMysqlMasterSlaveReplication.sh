#######################################################################
# Developer: Maykel Curbelo Pruna                                     #
# Email: mcurbelop@gmail.com                                          #
# Date: 03/02/2015, Version: 1.0                                      #
# Important:                                                          #
#   1) Use this code at your own risk                                 #
#   1) Test first on development environment                          #
#   2) Make a backup of your database before using this code          #
#######################################################################

############ Configuration section, change everything you need #########################

DB_NAME="db_name"

SLAVE="full_dns_or_IP_slave_server"
SLAVE_USER="mysql_user_slave_server"
SLAVE_PASS="mysql_password_slave_server"

MASTER="full_dns_or_IP_master_server"
MASTER_USER="mysql_user_master_server"
MASTER_PASS="mysql_password_master_server"

TEMPORAL_WORKING_PATH="/root"



############ I suggest you do not change anything after here #########################

DATE_TIME=`date +%Y-%m%-d-%H-%M-%S`
DUMPED_DB_PATH="$TEMPORAL_WORKING_PATH/$DB_NAME.sql_$DATE_TIME"

echo -e "\nMaking backup of db: $DB_NAME\n"
ssh $SLAVE "mysqldump -u $SLAVE_USER -p$SLAVE_PASS $DB_NAME > $DUMPED_DB_PATH"
echo "We make a backup of your database (DB_NAME) for security razon on $DUMPED_DB_PATH"

echo -e "\nStoping SLAVE ($SLAVE)\n"
ssh $SLAVE "mysql -u $SLAVE_USER -p$SLAVE_PASS -e 'STOP SLAVE;'"

echo -e "\nReset & Flush master\n"
mysql -u $MASTER_USER -p$MASTER_PASS -e 'RESET MASTER;'
mysql -u $MASTER_USER -p$MASTER_PASS -e 'FLUSH TABLES WITH READ LOCK;'

echo -e "\nDumping $DB_NAME on $MASTER\n"
mysqldump -u $MASTER_USER -p$MASTER_PASS $DB_NAME > /tmp/$DB_NAME.sql

echo -e "\nUnlock the tables at master ($MASTER)\n"
mysql -u $MASTER_USER -p$MASTER_PASS -e 'UNLOCK TABLES;'

echo -e "\nCopying dumped db to SLAVE ($SLAVE) \n"
rsync -avz /tmp/$DB_NAME.sql $SLAVE:/tmp/$DB_NAME.sql

echo -e "\nRestoring DB ($DB_NAME) on SLAVE ($SLAVE)\n"
ssh $SLAVE "/usr/bin/mysql -u $SLAVE_USER -p$SLAVE_PASS $DB_NAME < /tmp/$DB_NAME.sql"

echo -e "\nReset SLAVE & Change master_log_file to pos 1\n"
ssh $SLAVE "mysql -u $SLAVE_USER -p$SLAVE_PASS -e 'RESET SLAVE;'"
ssh $SLAVE "mysql -u $SLAVE_USER -p$SLAVE_PASS -e 'CHANGE MASTER TO MASTER_LOG_FILE='\''mysql-bin.000001'\'', MASTER_LOG_POS=1;'"
ssh $SLAVE "mysql -u $SLAVE_USER -p$SLAVE_PASS -e 'START SLAVE;'"

echo -e "\n\nAll Done !!\n\n"
