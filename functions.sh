# functions are defined in this file

#!/bin/bash

# Function to check if master password file exists

DB="DataBase/vault.db"
check_master(){
    if [ ! -f master.pass ]; then
        master_exists=0
    else
        master_exists=1
    fi
}

# Function to create a new master password
    create_master(){
    read -s -p "Create your master password:" pw_c
    echo ""
    if [ -z "$pw_c" ]; then
        echo "Password cannot be empty. Please try again."
        return 1
    fi
    read -s -p "Confirm your master password:" pw_c_confirm
    echo ""
    if [ "$pw_c" != "$pw_c_confirm" ]; then
        echo ""
        echo "Passwords do not match. Please try again."
        return 1
    fi

    openssl passwd -6 -stdin <<< "$pw_c" > master.pass
    chmod 600 master.pass
    unset pw_c pw_c_confirm
    echo ""
    echo "Master password created successfully."
}

# Function to enter the vault
vault_entry(){

  echo "Welcome to the Vault"
    echo ""
    read -s -p "Enter the master password: " pw_v
    if [ -z "$pw_v" ]; then
        echo "Password cannot be empty. Please try again."
        return 1
    fi
    echo ""
    master_hash=$(cat master.pass)
    salt=$(echo "$master_hash" | awk -F'$' '{print $3}')
    pw_v_hash=$(openssl passwd -6 -salt "$salt" "$pw_v")

    if [ "$master_hash" = "$pw_v_hash" ]; then
        echo "Access Granted"
        entry=1
    else
        echo "Access Denied"
        entry=0
    fi
    unset pw_v pw_v_hash master_hash salt
}

#Function to main menu

main_menu() {
    echo ""
    echo "------ MAIN MENU ------"
    echo "1) View Passwords"
    echo "2) Manage Passwords"
    echo "3) Change Master Password"
    echo "4) Exit"
    read -p "Choose an option: " choice
}

#Function to view stored passwords
view_pass(){
 sqlite3 -header -column "$DB" \
    "SELECT id, service, username, encpass FROM passwords;"
}

#Function to Mangage Passwords Menu
manage_pass_menu(){
 echo ""
    echo "------ MANAGE PASSWORDS ------"
    echo "1) Add Password"
    echo "2) Delete Password"
    echo "3) Edit Password"
    echo "4) Back"
    read -p "Choose an option: " man_choice
}

#Function to Add Password Menu
add_pass_menu(){
echo ""
    echo "1) Add Password Manually"
    echo "2) Auto-generate Password"
    echo "3) Back"
    read -p "Choose an option: " add_choice
}

#Function to auto generate password
auto_gen_pass(){
    :
}

#Function to add new password manually
add_pass(){
 read -p "Service: " SERVICE
    read -p "Username: " USER
    read -sp "Password: " PASS
    echo ""

    sqlite3 "$DB" \
    "INSERT INTO passwords (service, username, encpass)
     VALUES ('$SERVICE', '$USER', '$PASS');"

    echo "Password saved."
}

#Function to delete a password
delete_pass(){
read -p "Enter ID to delete: " ID
    sqlite3 "$DB" "DELETE FROM passwords WHERE id=$ID;"
    echo "Deleted."
}

#Function to edit a password

edit_pass() {
    read -p "Enter ID to edit: " ID
    read -p "New Service: " SERVICE
    read -p "New Username: " USER
    read -sp "New Password: " PASS
    echo ""

    sqlite3 "$DB" \
    "UPDATE passwords
     SET service='$SERVICE', username='$USER', encpass='$PASS'
     WHERE id=$ID;"

    echo "Updated."
}

#Function to change master password
change_master(){
        read -s -p "Change your master password:" pw_ch
    echo ""
    if [ -z "$pw_ch" ]; then
        echo "Password cannot be empty. Please try again."
        return 1
    fi
    read -s -p "Confirm your master password:" pw_ch_confirm
    echo ""
    if [ "$pw_ch" != "$pw_ch_confirm" ]; then
        echo ""
        echo "Passwords do not match. Please try again."
        return 1
    fi

    openssl passwd -6 <<< "$pw_ch" > master.pass
    chmod 600 master.pass
    unset pw_ch pw_ch_confirm
    echo ""
    echo "Master password changed successfully."
}
