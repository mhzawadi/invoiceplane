<p align="center">
  <img src="http://invoiceplane.com/content/logo/SVG/logo_small.svg">
</p>
<p>&nbsp;</p>

<p align="center">
<a href="https://github.com/InvoicePlane/InvoicePlane/releases"><img src="https://img.shields.io/badge/dynamic/json.svg?label=Current%20Version&url=https%3A%2F%2Fapi.github.com%2Frepos%2FInvoicePlane%2FInvoicePlane%2Freleases%2Flatest&query=%24.name&colorB=%23429ae1"></a>
<a href="https://github.com/InvoicePlane/InvoicePlane/releases"><img src="https://img.shields.io/badge/dynamic/json.svg?label=Downloads&url=https%3A%2F%2Fids.invoiceplane.com%2Fapi%2Fget-stats&query=downloads.total_readable&colorB=429ae1&suffix=%20total"></a>
<a href="https://translations.invoiceplane.com/project/fusioninvoice"><img src="https://img.shields.io/badge/dynamic/json.svg?label=Localization%20Progress&url=https%3A%2F%2Fids.invoiceplane.com%2Fapi%2Fget-stats&query=%24.localization.details.total_progress&colorB=429ae1&suffix=%25"></a>
</p>

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
