#!/bin/bash

database_name=pandora
db_path="/tmp/${database_name}.sql"
uat_data_passwd=`cat ~/uat_dbpasswd`
prd_data_passwd=`cat ~/prd_dbpassword`
database_old="xxx.amazonaws.com"

##清除uat的库
mysql -uroot -p${uat_data_passwd} -D $database_name -e "drop database $database_name"
sleep 1
mysql -uroot -p${uat_data_passwd} -e  "create database  ${database_name}"


##删除之前的备份，重新备份
rm -rf ${db_path}
echo "--------->正在导出数据"
mysqldump -h ${database_old} -uroot -p$prd_data_passwd --opt --default-character-set=utf8 --hex-blob pandora --skip-triggers --skip-lock-tables > ${db_path}


##判断文件是否存在
if [ ! -d "$db_path" ]; then
    echo "--------->正在导入数据"
    mysql -uroot -p$uat_data_passwd ${database_name} < ${db_path}	##将数据导入uat的库
else
    echo "生产数据未导出，执行失败"
    exit 1
fi
