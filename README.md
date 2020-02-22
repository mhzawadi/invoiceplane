<p align="center">
  <img src="https://github.com/InvoicePlane/InvoicePlane/raw/master/assets/core/img/logo_400x200.png">
</p>
<p>&nbsp;</p>
<p align="center"><a href="https://hub.docker.com/r/mhzawadi/invoiceplane"><img alt="Docker Pulls" src="https://img.shields.io/docker/pulls/mhzawadi/invoiceplane.svg"></a></p>
<p align="center" bgcolor="#429ae1"><b>InvoicePlane is a self-hosted open source application for managing your invoices, clients and payments.<br>
  For more information visit <a href="https://invoiceplane.com">InvoicePlane.com</a> or try the <a href="https://demo.invoiceplane.com">Demo</a>.</b></p>

---

## How to use this Docker image

### Mysql

Run a MySQL database, dedicated to invoiceplane

```bash
$ docker run --name invoiceplane-mysql -e MYSQL_ROOT_PASSWORD=my-secret-pw -v /my_dir/invoiceplane:/var/lib/mysql -d mysql:5.6
```

Here, we store data on the host system under `/my_dir/invoiceplane` and use a specific root password.

### InvoicePlane

```bash
$ docker run -ti -d -p 80:80 --name invoiceplane --link invoiceplane-mysql:mysql mhzawadi/invoiceplane
```

We are linking the two containers and expose the HTTP port with a host URL of 127.0.0.1, you need to set the HOST_URL as nginx uses this to accept incoming requests.

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

### Environment variables summary

- TZ: the timezone for PHP
- MYSQL_HOST: the MySQL server
- MYSQL_USER: the username for MySQL
- MYSQL_PASSWORD: the password for MySQL
- MYSQL_DB: the MySQL database
- MYSQL_PORT: the MySQL port, if not 3306
- IP_URL: This is the host that you will access the site on
- DISABLE_SETUP: Have you run setup?

## Docker hub tags

You can use following tags on Docker hub:

* `latest` - latest stable release
* `v1.5.9.1` - latest stable release for the 1.5.9 version build number 1

### how to build

Latest is build from the docker hub once I push to the github repo, the arm versions are built from my mac with the below buildx tool

`docker buildx build --platform linux/amd64,linux/arm64,linux/arm/v7 -t mhzawadi/invoiceplane:v1.5.10.1 --push .`
