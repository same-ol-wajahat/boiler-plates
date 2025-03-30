#!/usr/bin/env bash

set -e

php artisan config:cache
php artisan cache:clear
php artisan view:cache
php artisan route:clear

npm run watch &
php artisan serve --host=0.0.0.0 --port=8000 &

wait
