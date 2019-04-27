<p align="center">
  <img src="http://invoiceplane.com/content/logo/SVG/logo_small.svg">
</p>
<p>&nbsp;</p>

<p align="center" bgcolor="#429ae1"><b>InvoicePlane is a self-hosted open source application for managing your invoices, clients and payments.<br>
  For more information visit <a href="https://invoiceplane.com">InvoicePlane.com</a> or try the <a href="https://demo.invoiceplane.com">Demo</a>.</b></p>

---

## How to use this Docker image

### Mysql

Run a MySQL database, dedicated to phpipam

```bash
$ docker run --name phpipam-mysql -e MYSQL_ROOT_PASSWORD=my-secret-pw -v /my_dir/phpipam:/var/lib/mysql -d mysql:5.6
```

Here, we store data on the host system under `/my_dir/phpipam` and use a specific root password.

### Phpipam

```bash
$ docker run -ti -d -p 80:80 --name ipam --link phpipam-mysql:mysql mhzawadi/invoiceplane
```

We are linking the two containers and expose the HTTP port.
