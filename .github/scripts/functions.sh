#!/bin/bash

migrate() {
    local release_path=$1

    echo "Running migrations for $release_path"
    cd $release_path
    php artisan migrate --force --no-interaction --path=database/migrations/landlord --database=landlord
    php artisan migrate --force --no-interaction --path=database/migrations/monitor --database=monitor
    # php artisan tenant:migrate --force
    echo "Migrations complete for $release_path"
    cd -
}
