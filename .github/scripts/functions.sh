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

rollback() {
    local from_path=$1
    local to_path=$2

    if [ -d "$from_path/database/migrations" ] && [ -d "$to_path/database/migrations" ]; then
        cd $from_path

        db_names=("monitor" "landlord")

        # for each db...
        for db_name in "${db_names[@]}"; do
            # list migrations in both directories...
            from_migrations=$(find $from_path/database/migrations/$db_name -type f -name "*.php" | sed "s|$from_path/||")
            to_migrations=$(find $to_path/database/migrations/$db_name -type f -name "*.php" | sed "s|$to_path/||")

            # if there are any migrations in the from directory...
            if [ ! -z "$from_migrations" ]; then

                # get migrations that are in the from directory but not in the to directory, and count them..
                migrations_count=$(comm -23 <(echo "$from_migrations" | sort) <(echo "$to_migrations" | sort) | wc -l)

                # rollback by the number of migrations found.
                if [ "$migrations_count" -gt 0 ]; then
                    echo "Rolling back migrations for $db_name, steps: $migrations_count"

                    if [ "$db_name" == "tenant" ]; then
                        php artisan tenant:migrate  --rollback true --step $migrations_count
                    else
                        php artisan migrate:rollback --database $db_name --path database/migrations/$db_name --step $migrations_count
                    fi
                fi
            fi
        done

        cd -
    fi
}
