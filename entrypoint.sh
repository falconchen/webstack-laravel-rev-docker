#!/bin/sh
set -eu

if [ -n "${LOGIN_CAPTCHA}" ]; then
#if [ -n "${LOGIN_CAPTCHA+x}" ]; then
    sed -i "/login-captcha/{n;s/'enable.*/'enable' => ${LOGIN_CAPTCHA}/}" config/admin.php
fi
cd $WEBSTACK_DIR

# 如果 $DB_DATABASE 为sqlite并且$DB_DATABASE不为空时
# 如果$DB_DATABASE 定义的路径如/db/database.sqlite 不存在时，创建$DB_DATABASE位置的文件夹及文件

# 检查是否是 SQLite 数据库，并且 $DB_DATABASE 不为空
if [ "$DB_CONNECTION" == "sqlite" ] && [ -n "$DB_DATABASE" ]; then
    # 提取目录部分
    db_directory=$(dirname "$DB_DATABASE")

    # 检查目录是否存在
    if [ ! -d "$db_directory" ]; then
        echo "Creating directory: $db_directory"
        mkdir -p "$db_directory"
    fi

    # 检查文件是否存在且不为空
    if [ ! -s "$DB_DATABASE" ]; then
        echo "Creating SQLite database file: $DB_DATABASE"
        touch "$DB_DATABASE"        
        php artisan key:generate 
        php artisan migrate:refresh --seed 
    fi

    echo "SQLite setup completed."

fi

uploads_dir="$WEBSTACK_DIR/public/uploads"
tgz_file="$WEBSTACK_DIR/uploads.tgz"

# 检查 $uploads_dir 是否为空
if [ ! "$(ls -A $uploads_dir)" ] && [ -f "$tgz_file" ]; then
    echo "No files or directories in $uploads_dir, and $tgz_file exists."

    # 解压 $tgz_file 到 $uploads_dir
    tar -zxvf "$tgz_file" -C "$uploads_dir"
    echo "Files extracted to $uploads_dir."

fi


chown -R apache:apache /var/www/html
chown -R apache:apache /db
chmod -R 755 /var/www/html/ /db

exec "$@"
