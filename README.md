# Redash on Heroku

Dockerfiles for hosting redash on heroku

## How to create

```sh
git clone git@github.com:willnet/redash-on-heroku.git
cd redash-on-heroku
app_name=foodyssey-redash-staging

heroku create --stack=container $app_name
```

## How to setup

### Add Addons

Add following addons on heroku dashboard.

- heroku postgres
- Redis Cloud(or something)
- sendgrid (or something)

```sh
app_name=foodyssey-redash-staging
heroku addons:create heroku-postgresql:essential-1 --app $app_name
heroku addons:create heroku-redis:mini --app $app_name
```


Choose redis addon allow more than or equal 30 connections. Otherwise you will get connection errors frequently.

### Add environment variables

Add environment variables like following.

```sh
# Fill these variables 
app_name=foodyssey-redash-staging
domain=dash-staging.foodyssey.co
REDIS_URL=redis://XXXX
POSTGRES_URL=postgres://XXXX
# ---

SECRET_TOKEN=$(openssl rand -base64 20)
SECRET_KEY=$(openssl rand -base64 20)

heroku config:set PYTHONUNBUFFERED=0 --app $app_name
heroku config:set QUEUES=queries,scheduled_queries,celery --app $app_name
heroku config:set REDASH_COOKIE_SECRET=$SECRET_TOKEN --app $app_name
heroku config:set REDASH_SECRET_KEY=$SECRET_KEY --app $app_name
heroku config:set REDASH_LOG_LEVEL=INFO --app $app_name
heroku config:set REDASH_HOST=$domain --app $app_name
heroku config:set REDASH_MAIL_PORT=587 --app $app_name

# We do not setup email here
heroku config:set REDASH_MAIL_PASSWORD=YOUR_ADDON_PASSWORD --app $app_name
heroku config:set REDASH_MAIL_SERVER=YOUR_ADDON_DOMAIN --app $app_name
heroku config:set REDASH_MAIL_USERNAME=YOUR_ADDON_USERNAME --app $app_name
heroku config:set REDASH_MAIL_USE_TLS=true --app $app_name
heroku config:set REDASH_MAIL_DEFAULT_SENDER=YOUR_MAIL_ADDRESS --app $app_name
heroku config:set REDASH_REDIS_URL=$REDIS_URL --app $app_name
heroku config:set REDASH_DATABASE_URL=$POSTGRES_URL --app $app_name
```

See also https://redash.io/help/open-source/setup#-setup

### Release container

```sh
git push heroku main
```

### Create database

After deploy and add postgres addon, create database like following.

```sh
heroku run /app/manage.py database create_tables --app $app_name
```

### Enable worker dyno

```sh
heroku ps:scale worker=1 --app $app_name
```

## How to upgrade

```sh
app_name=foodyssey-redash
heroku ps:scale web=0 worker=0  --app $app_name
git push heroku main

heroku ps:scale web=1 worker=1 scheduler=1 --app $app_name
heroku ps:type worker=standard-2x scheduler=standard-2x web=standard-2x --app $app_name

heroku run manage db upgrade --app $app_name --size=performance-m
```


# Change Redis url to use TLS

```shell
REDIS_URL=rediss://xxx?ssl_cert_reqs=none
```


See also https://redash.io/help/open-source/admin-guide/how-to-upgrade
