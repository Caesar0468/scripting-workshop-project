#NEED TO HANDLE EDGE CASES AND ADD MORE COMMENTS


#We execute the functions script to use its functions here
#!/bin/bash

source ./functions.sh

master_exists=0
entry=0
run(){
check_master
if [ "$master_exists" -eq 1 ]; then
    vault_entry
        if [ "$entry" -eq 1 ] ; then
                main_menu
                    if [ "$choice" -eq 1 ]; then
                        view_pass
                        main_menu
                    elif  [ "$choice" -eq 2 ]; then
                        manage_pass_menu
                            if [ "$man_choice" -eq 1 ]; then
                                add_pass_menu
                                    if [ "$add_choice" -eq 1 ]; then
                                        add_pass
                                    elif [ "$add_choice" -eq 2 ]; then
                                        auto_gen_pass
                                    fi
                            elif [ "$man_choice" -eq 2 ]; then
                                delete_pass
                            elif [ "$man_choice" -eq 3 ]; then
                                edit_pass
                            elif [ "$man_choice" -eq 4 ]; then
                                main_menu
                            fi
                    elif [ "$choice" -eq 3 ]; then
                        change_master
                        run
                    elif [ "$choice" -eq 4 ]; then
                        return 0
                    fi
        else
            echo "Exiting..."
            return 0
        fi
else
    create_master
    run
fi
}

run