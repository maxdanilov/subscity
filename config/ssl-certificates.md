SSL cert generation is done with [Letsencrypt](https://letsencrypt.org/)

## Cert Generation
```
sudo ./letsencrypt-auto certonly --webroot -w /var/www/subscity/public/ -d subscity.ru -d www.subscity.ru -d msk.subscity.ru -d spb.subscity.ru
```

## Cert Renewal
```
sudo ./letsencrypt-auto renew
```
After certs changes, Apache restart is required.
