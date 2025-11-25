#!/bin/bash

# functions are defined in this file
# Function to check if master password file exists
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DB="$SCRIPT_DIR/DataBase/vault.db"
check_master(){
    if [ ! -f "$SCRIPT_DIR/master.pass" ]; then
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

    openssl passwd -6 -stdin <<< "$pw_c" > "$SCRIPT_DIR/master.pass"
    chmod 600 "$SCRIPT_DIR/master.pass"
    unset pw_c pw_c_confirm
    echo ""
    echo "Master password created successfully."
}

encrypt() {
    printf "%s" "$1" | \
    openssl enc -aes-256-cbc -salt -pbkdf2 -iter 600000 -md sha256 -pass fd:3 3<<<"$MASTERPW" | base64 -w 0
}

decrypt() {
    printf "%s" "$1" | base64 -d | \
    openssl enc -d -aes-256-cbc -salt -pbkdf2 -iter 600000 -md sha256 -pass fd:3 3<<<"$MASTERPW" 2>/dev/null
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
    master_hash=$(cat "$SCRIPT_DIR/master.pass")
    salt=$(echo "$master_hash" | awk -F'$' '{print $3}')
    pw_v_hash=$(openssl passwd -6 -salt "$salt" -stdin <<< "$pw_v")

    if [ "$master_hash" = "$pw_v_hash" ]; then
        echo "Access Granted"
        MASTERPW="$pw_v"
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
view_pass() {
    rows=$(sqlite3 -separator $'\x1f' "$DB" "SELECT id, service, username, encpass FROM passwords;")

    printf "\n%-5s | %-20s | %-20s | %s\n" "ID" "SERVICE" "USERNAME" "PASSWORD"
    echo "--------------------------------------------------------------------------"

    while IFS=$'\x1f' read -r ID ENC_SERVICE ENC_USER ENC_PASS; do
         [ -z "$ENC_SERVICE" ] && continue 
        SERVICE=$(decrypt "$ENC_SERVICE")
        USER=$(decrypt "$ENC_USER")
        PASS=$(decrypt "$ENC_PASS")

        printf "%-5s | %-20s | %-20s | %s\n" "$ID" "$SERVICE" "$USER" "$PASS"
    done <<< "$rows"
    unset ID ENC_SERVICE ENC_USER ENC_PASS rows
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
    read -p "Service: " SERVICE
    read -p "Username: " USER
    PASS=$(openssl rand -base64 32)
    echo "Generated Password: $PASS"
    echo ""
    
    ENC_SERVICE=$(encrypt "$SERVICE")
    ENC_USER=$(encrypt "$USER")
    ENC_PASS=$(encrypt "$PASS")

    sqlite3 "$DB" \
    "INSERT INTO passwords (service, username, encpass)
     VALUES ('$ENC_SERVICE', '$ENC_USER', '$ENC_PASS');"

    unset ENC_SERVICE ENC_USER ENC_PASS SERVICE USER PASS
    echo "Password saved."
}

#Function to add new password manually
add_pass(){
 read -p "Service: " SERVICE
    read -p "Username: " USER
    read -sp "Password: " PASS
    echo ""

    ENC_SERVICE=$(encrypt "$SERVICE")
    ENC_USER=$(encrypt "$USER")
    ENC_PASS=$(encrypt "$PASS")

    sqlite3 "$DB" \
    "INSERT INTO passwords (service, username, encpass)
     VALUES ('$ENC_SERVICE', '$ENC_USER', '$ENC_PASS');"

    unset ENC_SERVICE ENC_USER ENC_PASS SERVICE USER PASS
    echo "Password saved."
}

#Function to delete a password
delete_pass(){
read -p "Enter ID to delete: " ID
    sqlite3 "$DB" "DELETE FROM passwords WHERE id=$ID;"
    echo "Deleted."
    unset ID
}

#Function to edit a password

edit_pass() {
    read -p "Enter ID to edit: " ID
    read -p "New Service: " SERVICE
    read -p "New Username: " USER
    read -sp "New Password: " PASS
    echo ""

    ENC_SERVICE=$(encrypt "$SERVICE")
    ENC_USER=$(encrypt "$USER")
    ENC_PASS=$(encrypt "$PASS")

    sqlite3 "$DB" \
    "UPDATE passwords
     SET service='$ENC_SERVICE', username='$ENC_USER', encpass='$ENC_PASS'
     WHERE id=$ID;"

    echo "Updated."

    unset ENC_SERVICE ENC_USER ENC_PASS SERVICE USER PASS ID
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

    openssl passwd -6 -stdin <<< "$pw_ch" > "$SCRIPT_DIR/master.pass"
    chmod 600 "$SCRIPT_DIR/master.pass"
    unset pw_ch pw_ch_confirm
    echo ""
    echo "Master password changed successfully."
}
