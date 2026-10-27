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

### Upgrading

If you have a running container, you will need to set `DISABLE_SETUP` to false. Then goto `http://yourdomain.com/index.php/setup` and follow the instructions.

### Docker compose

You can get an all-in-one YAML deployment descriptor with Docker compose, like this :

```
curl https://raw.githubusercontent.com/mhzawadi/invoiceplane/blob/master/docker-compose.yml
docker-compose up -d
```

If your using docker swarm you can get a stack that has the same setup:

```
curl https://raw.githubusercontent.com/mhzawadi/invoiceplane/blob/master/stack-invoiceplane.yml
docker stack deploy --compose-file stack-invoiceplane.yml invoiceplane
```

#### Using the traefik proxy

If you use the above compose file, you will need to update your `/etc/hosts` file.
you will need to add `127.0.0.1 invoiceplane.docker.local` to it in order that traefik does its routing, else you will get a `404` error page.

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
      - SETUP_COMPLETED=true
      - ENCRYPTION_CIPHER=base64:LgrA+4Df/kJvZIx+GBech8PRTYuO+lbIoF5CgJ59iJM=
      - ENCRYPTION_CIPHER=AES-256
```

### Environment variables summary

- TZ: the timezone for PHP
- IP_URL: Public base URL without trailing slash, e.g. https://invoices.example.com
- ENABLE_DEBUG: Enable advanced debug logging
- DISABLE_SETUP: used to hide the setup page
- REMOVE_INDEXPHP: To remove index.php from the URL
  - the bundled nginx has the config to work with this set to `true`
- MYSQL_HOST: Database host
- MYSQL_USER: Database user
- MYSQL_PASSWORD: Database name
- MYSQL_DB: Database password
- MYSQL_PORT: Database port
- SESS_EXPIRATION: Session lifetime in seconds (0 = expire on browser close)
- SESS_MATCH_IP: Tie sessions to the client IP address
- ENABLE_INVOICE_DELETION: Allow invoices to be permanently deleted
- DISABLE_READ_ONLY: Disable the read-only mode for sent invoices
- CUSTOM_TEMPLATES_FOLDER: Absolute path to a directory of custom invoice/quote templates.
- CUSTOM_INVOICE_TEMPLATES_PDF: Comma-separated allowlist of custom PDF invoice template names (without .php). Quote the value if names contain spaces: "My Template,Another"
- CUSTOM_INVOICE_TEMPLATES_PUBLIC: Same, for public/web invoice templates
- CUSTOM_QUOTE_TEMPLATES_PDF: Same, for PDF quote templates
- CUSTOM_QUOTE_TEMPLATES_PUBLIC: Same, for public/web quote templates
- PROXY_IPS: Trusted proxy IP addresses
- ENCRYPTION_KEY: Secret key for encrypted data — generate with openssl rand -base64 32
- ENCRYPTION_CIPHER: Cipher used for encrypted settings


#### Reverse Proxy IPs

If your server is behind a reverse proxy, you must whitelist the proxy IP addresses from which CodeIgniter should trust headers such as HTTP_X_FORWARDED_FOR and HTTP_CLIENT_IP in order to properly identify the visitor's IP address.

You can use both an array or a comma-separated list of proxy addresses, as well as specifying whole subnets. Here are a few examples:

- Comma-separated:
  - `PROXY_IPS='10.0.1.200,192.168.5.0/24'`
- Array:		
  - `PROXY_IPS=array('10.0.1.200', '192.168.5.0/24')`

#### Explicit allowlist of custom template names (without .php extension).

> **Security note:** The filesystem is never scanned for templates. This prevents Remote Code
> Execution (RCE) attacks where an attacker writes a PHP file to the templates directory and
> then triggers it via the admin panel. This allowlist-based mechanism was introduced as part of
> the [1.7.2 security release](../CHANGELOG.md#172---2026-07-14) — see
> [SECURITY_ADVISORY_RCE_FIX.md](../security/SECURITY_ADVISORY_RCE_FIX.md) for the full advisory.

To add a custom template:

1. **Create the template `.php` file** inside `CUSTOM_TEMPLATES_FOLDER` under the appropriate sub-path:
   ```
   <CUSTOM_TEMPLATES_FOLDER>/invoice_templates/pdf/MyTemplate.php
   <CUSTOM_TEMPLATES_FOLDER>/invoice_templates/public/MyTemplate.php
   <CUSTOM_TEMPLATES_FOLDER>/quote_templates/pdf/MyTemplate.php
   <CUSTOM_TEMPLATES_FOLDER>/quote_templates/public/MyTemplate.php
   ```

2. **Add the template name** (without `.php`) to the matching allowlist key in `ipconfig.php`.
   Quote the value when names contain spaces or hyphens:
   ```
   CUSTOM_INVOICE_TEMPLATES_PDF="MyTemplate,Corporate - Modern"
   CUSTOM_INVOICE_TEMPLATES_PUBLIC="MyTemplate"
   CUSTOM_QUOTE_TEMPLATES_PDF="MyTemplate"
   CUSTOM_QUOTE_TEMPLATES_PUBLIC="MyTemplate"
   ```
   Template names may only contain letters, digits, spaces, hyphens (`-`), and underscores (`_`).

3. The template will appear in **Settings → Invoice / Quote** once it is listed.

> The filesystem is never scanned to build the selector. Built-in templates always appear in the
> selector, and custom templates appear **only** if you explicitly allowlist their names in step 2.
> `CUSTOM_TEMPLATES_FOLDER` is used only at render time to locate the file on disk, so setting the
> folder alone will not expose any custom templates. This is the RCE prevention mechanism.

For container deployments, `CUSTOM_TEMPLATES_FOLDER` and the allowlist variables above are set
as environment variables instead — see [CONTAINER_DEPLOYMENT.md](CONTAINER_DEPLOYMENT.md).

## Docker hub tags

You can use following tags on Docker hub:

* `latest` - latest stable release
* `v1.6.1.3` - latest stable release for the 1.6.1 version build number 3

### how to build

Latest is build from the docker hub once I push to the github repo, the arm versions are built from my mac with the below buildx tool

`docker build -t mhzawadi/invoiceplane:testing .`
