<p align="center">
  <img src="https://github.com/InvoicePlane/InvoicePlane/raw/master/assets/core/img/logo_400x200.png">
</p>
<p>&nbsp;</p>
<p align="center">
  <img alt="Github Work flow" src="https://img.shields.io/github/workflow/status/mhzawadi/invoiceplane/build%20our%20image%20for%20latest?label=Docker%20Latest">
  <a href="https://hub.docker.com/r/mhzawadi/invoiceplane"><img alt="Docker Pulls" src="https://img.shields.io/docker/pulls/mhzawadi/invoiceplane.svg"></a>
</p>
<p align="center" bgcolor="#429ae1"><b>InvoicePlane is a self-hosted open source application for managing your invoices, clients and payments.<br>
  For more information visit <a href="https://invoiceplane.com">InvoicePlane.com</a> or try the <a href="https://demo.invoiceplane.com">Demo</a>.</b></p>

---

## How to use this Docker image

This image will export 3 directories, if you dont setup a volume for them Docker will.

- /var/www/html/uploads (Uploaded images)
- /var/www/html/assets/core/css (custom styles)
- /var/www/html/application/views (Customized templates)

### Mysql

Run a MySQL database, dedicated to invoiceplane

```bash
docker run --name invoiceplane-mysql -e MYSQL_ROOT_PASSWORD=my-secret-pw \
 -e MYSQL_DATABASE=invoiceplane \
 -e MYSQL_USER=invoiceplane \
 -e MYSQL_PASSWORD=my-secret-pw \
 -v /my_dir/invoiceplane:/var/lib/mysql -d mysql:5.7
```

This will start MySQL, set the root password and create a database for invoiceplane.
This does take some time, so dont try to get invoiceplane setup too quick

### InvoicePlane

```bash
docker run -ti -d -p 80:80 --name invoiceplane \
--link invoiceplane-mysql:mysql \
--volume "/your/path/to/invoiceplane/uploads:/var/www/html/uploads" \
--volume "/your/path/to/invoiceplane/assets:/var/www/html/assets/core/css" \
--volume "/your/path/to/invoiceplane/views:/var/www/html/application/views" \
mhzawadi/invoiceplane
```

We are linking the two containers and expose the HTTP port, once MySQL is up and running setup of invoiceplane should be quick.

This will also setup a database called invoiceplane with the invoiceplane user having superuser access to this database

### Docker compose

You can get an all-in-one YAML deployment descriptor with Docker compose, like this :

```
curl https://github.com/mhzawadi/invoiceplane/blob/master/docker-compose.yml
docker-compose up -d
```

If your using docker swarm you can get a stack that has the same setup:

```
curl https://github.com/mhzawadi/invoiceplane/blob/master/stack-invoiceplane.yml
docker stack deploy --compose-file stack-invoiceplane.yml invoiceplane
```

### persistent config

if you run docker swarm, you can add your config to docker swarm config and have it persist across containers.

Mount your config to `/var/www/html/ipconfig.php`

Or you can pass all the config via environment variables, see below for some of the basics.
Once you have your instance setup, you will want to collect the `ENCRYPTION_KEY` & `ENCRYPTION_CIPHER`. As that is used to store passwords.

The below commands will display the `ENCRYPTION_KEY` & `ENCRYPTION_CIPHER`

```
ID=$(docker ps | grep 'mhzawadi/invoiceplane' | awk '{print $1}');
docker exec -it "$ID" /bin/cat ipconfig.php | grep ENCRYPTION_KEY;
docker exec -it "$ID" /bin/cat ipconfig.php | grep ENCRYPTION_CIPHER;
```

Update your docker-compose file with them, also add `SETUP_COMPLETED=true`.

the `environment` section of your `docker-compose.yml` should have some like the below

```
      - TZ=utc
      - MYSQL_HOST=mariadb_10_4
      - MYSQL_USER=InvoicePlane
      - MYSQL_PASSWORD=invoiceplane
      - MYSQL_DB=InvoicePlane
      - IP_URL=http://invoiceplane.docker.local
      - DISABLE_SETUP=true
      - SETUP_COMPLETED=true
      - ENCRYPTION_CIPHER=base64:LgrA+4Df/kJvZIx+GBech8PRTYuO+lbIoF5CgJ59iJM=
      - ENCRYPTION_CIPHER=AES-256
```

### Environment variables summary

- TZ: the timezone for PHP
- IP_URL: This is the host that you will access the site on
- REMOVE_INDEXPHP: To remove index.php from the URL
  - the bundled nginx has the config to work with this set to `true`
- MYSQL_HOST: the MySQL server
- MYSQL_USER: the username for MySQL
- MYSQL_PASSWORD: the password for MySQL
- MYSQL_DB: the MySQL database
- MYSQL_PORT: the MySQL port, if not 3306
- DISABLE_SETUP: Have you run setup?

## Docker hub tags

You can use following tags on Docker hub:

* `latest` - latest stable release
* `v1.5.9.1` - latest stable release for the 1.5.9 version build number 1

### how to build

Latest is build from the docker hub once I push to the github repo, the arm versions are built from my mac with the below buildx tool

`docker buildx build --platform linux/amd64,linux/arm64,linux/arm/v7 -t mhzawadi/invoiceplane:v1.5.10.1 --push .`
