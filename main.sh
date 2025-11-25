#!/bin/bash

source ./functions.sh

# Ensure database folder exists
mkdir -p DataBase

# Auto-create vault if missing
if [ ! -f DataBase/vault.db ]; then
    echo "Initializing new vault..."
    sqlite3 DataBase/vault.db < init.sql
fi

cat << "EOF"
 ____   __    ___  ___        _  _  __    __  __  __   ____ 
(  _ \ /__\  / __)/ __)      ( \/ )/__\  (  )(  )(  ) (_  _)
 )___//(__)\ \__ \\__ \       \  //(__)\  )(__)(  )(__  )(  
(__) (__)(__)(___/(___/        \/(__)(__)(______)(____)(__) 
EOF


run() {

    # Step 1: Check if master password exists
    check_master

    # If no master password, create one
    if [ "$master_exists" -eq 0 ]; then
        create_master
    fi

    # Step 2: Authenticate user
    vault_entry
    if [ "$entry" -ne 1 ]; then
        echo "Exiting..."
        exit 0
    fi

    # Step 3: Main loop
    while true; do

        main_menu

        case "$choice" in
            1)
                view_pass
                ;;
            2)
                manage_pass_menu
                case "$man_choice" in
                    1)
                        add_pass_menu
                        case "$add_choice" in
                            1) add_pass ;;
                            2) auto_gen_pass ;;
                            3) ;; # back
                        esac
                        ;;
                    2) delete_pass ;;
                    3) edit_pass ;;
                    4) ;; # back
                esac
                ;;
            3)
                change_master
                ;;
            4)
                echo "Goodbye!"
                exit 0
                ;;
            *)
                echo "Invalid choice."
                ;;
        esac

    done
}

run

