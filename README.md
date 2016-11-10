# mysqlproxy-docker
Docker container for MySQL Proxy

# Usage
/opt/main.lua script is executed in container

# Usage with docker-compose

    version: '2'
    
    services:
      db:
        image: "mysql:5.7.14"
        expose:
          - "3306"
        ports:
          - "3307:3306"
        volumes:
          - ./mysql/data:/var/lib/mysql
          - ./mysql/conf/mysqld.cnf:/etc/mysql/mysql.conf.d/mysqld.cnf
          - ./mysql/logs:/var/log/mysql
        restart: always
        environment:
          MYSQL_ROOT_PASSWORD: password
          MYSQL_DATABASE: dbuser
          MYSQL_USER: dbuser
          MYSQL_PASSWORD: password

      mysqlproxy:
        image: gediminaspuksmys/mysqlproxy-docker:0.8.5
        ports:
          - "3308:3306"
        restart: always
        volumes: 
          - ./mysqlproxy/main.lua:/opt/main.lua
        environment:
          PROXY_DB_PORT: 3306
          REMOTE_DB_HOST: db
          REMOTE_DB_PORT: 3306
        links:
          - db
