## install postgress

## update listening Ip
- see image pg1

```
sudo vi  /var/lib/pgsql/data/postgressql.conf
  OR
sudo vi /etc/postgresql/16/main/postgresql.conf
```

- In that file, look for --> listen_addresses = 'localhost'
- update to --> listen_addresses = 'your-server-IP'
- In my case: update to --> listen_addresses = '192/168.0.115'

## update  Ipv4 local connection
- see image pg2
- OR  see image pg2.1

```
sudo vi  /var/lib/pgsql/data/pg_hba.conf
   OR
sudo vi /etc/postgresql/16/main/pg_hba.conf
```

## restart postgresql.service
```
restart postgresql.service
ss -nlt | grep 5432
```

## My existing Database for sonarqube
```
## I use this to connect to database, NOT REQUIRED HERE:
psql -h cafanwi-postgres.sosotech.io -U cafanwiiuser -d sonarqube
```

## Create a new database for jira using same user
```
psql -h cafanwi-postgres.sosotech.io -U cafanwiiuser -d jira
   OR
psql -h 10.0.0.36 -U cafanwiiuser -d jira
```

---------------------------------
10.0.0.36
## Getting started
suso su - OR sudo su - postgres
psql
\l

## Create password
echo thisissosotech | base64

suso su - OR sudo su - postgres
psql
\l
sudo systemctl restart postgres
ALTER USER postgres PASSWORD 'dG9tYXRvZXNmcnVpdHNhbGFKCg';

## Connect to PostgreSQL:
psql -h <your_postgres_host> -U <your_postgres_user> -d cafanwii-db1

## Create a Database:
CREATE DATABASE <your_database_name>;

## Create a User:
CREATE USER <your_user_name> WITH ENCRYPTED PASSWORD '<your_password>';

## Grant Permissions:
GRANT ALL PRIVILEGES ON DATABASE <your_database_name> TO <your_user_name>;

#### Execute PostgreSQL commands
\l            #  List databases
\c your_database_name   # Connect to a specific database
\dt           # List tables in the current database
SELECT current_user;    # Show current user
SELECT current_database();  # Show current database
SHOW search_path;        # Show search path
\du           # List users
\q            # Exit the psql shell

-------
10.0.0.36
## Getting started
suso su - OR sudo su - postgres
psql
\l

## Create password
echo thisissosotech | base64

suso su - OR sudo su - postgres
psql
\l
sudo systemctl restart postgres


## get host
postgres=# SELECT current_setting('listen_addresses') AS host;
## Get current database and user
postgres=# SELECT current_user AS user, current_database() AS database;
## Get hostname
SELECT boot_val,reset_val
FROM pg_settings
WHERE name='listen_addresses';;

## To change password
ALTER USER postgres PASSWORD 'D20$';

## connect to database, will require password
psql -h localhost -U postgres -d postgres
psql -h localhost -U postgres -d cafanwii-db1


kubectl port-forward service/sonarqube 9000:9000
