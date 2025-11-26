#!/bin/bash

# --- CONFIGURATION ---
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DB="$SCRIPT_DIR/DataBase/vault.db"
# Define the log file location
LOG_FILE="$SCRIPT_DIR/vault_audit.log"

# --- LOGGING FUNCTION (NEW) ---
# Usage: log_activity "ACTION_TYPE" "Details about the action"
log_activity() {
    local action="$1"
    local details="$2"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")

    # Append the entry to the log file
    echo "[$timestamp] [$action] $details" >> "$LOG_FILE"

    # secure the log file permissions (only owner can read/write)
    chmod 600 "$LOG_FILE" 2>/dev/null
}

is_valid_id() {
  [[ $1 =~ ^[0-9]+$ ]]
}
sql_escape() {
  printf "%s" "$1" | sed "s/'/''/g"
}

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
    MASTERPW="$pw_ch"

    # LOGGING
    log_activity "SYSTEM" "New Master Password created"

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
        # LOGGING SUCCESS
        log_activity "LOGIN_SUCCESS" "User unlocked the vault"
    else
        echo "Access Denied"
        entry=0
        # LOGGING FAILURE (Security Critical)
        log_activity "LOGIN_FAIL" "Failed attempt to unlock vault"
    fi
    unset pw_v pw_v_hash master_hash salt
}

#Function to main menu

main_menu() {
    echo ""
    echo "------ MAIN MENU ------"
    echo "1) View Passwords"
    echo "2) Manage Passwords"
    echo "3) Exit"
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

    # LOGGING
    log_activity "VIEW" "User viewed/decrypted all passwords"

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

    ENC_SERVICE_ESC=$(sql_escape "$ENC_SERVICE")
    ENC_USER_ESC=$(sql_escape "$ENC_USER")
    ENC_PASS_ESC=$(sql_escape "$ENC_PASS")

    sqlite3 "$DB"<<EOF

   INSERT INTO passwords (service, username, encpass)
VALUES (
    '$(printf "%s" "$ENC_SERVICE_ESC")',
    '$(printf "%s" "$ENC_USER_ESC")',
    '$(printf "%s" "$ENC_PASS_ESC")'
);
EOF
    # LOGGING (Note: We log the SERVICE, but never the PASSWORD)
    log_activity "ADD" "Auto-generated password added for service: $SERVICE"

unset ENC_SERVICE ENC_USER ENC_PASS SERVICE USER PASS ENC_SERVICE_ESC ENC_USER_ESC ENC_PASS_ESC
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

    ENC_SERVICE_ESC=$(sql_escape "$ENC_SERVICE")
    ENC_USER_ESC=$(sql_escape "$ENC_USER")
    ENC_PASS_ESC=$(sql_escape "$ENC_PASS")
    sqlite3 "$DB" <<EOF
    INSERT INTO passwords (service, username, encpass)
VALUES (
    '$(printf "%s" "$ENC_SERVICE_ESC")',
    '$(printf "%s" "$ENC_USER_ESC")',
    '$(printf "%s" "$ENC_PASS_ESC")'
);
EOF

    # LOGGING
    log_activity "ADD" "Manual password added for service: $SERVICE"

unset ENC_SERVICE ENC_USER ENC_PASS SERVICE USER PASS ENC_SERVICE_ESC ENC_USER_ESC ENC_PASS_ESC
    echo "Password saved."
}

#Function to delete a password
delete_pass(){
read -p "Enter ID to delete: " ID
    if ! is_valid_id "$ID"; then
        echo "Invalid ID. Must be a non-negative integer."
        unset ID
        return 1
    fi

    sqlite3 "$DB" <<EOF
DELETE FROM passwords WHERE id = $ID;
EOF

    # LOGGING
    log_activity "DELETE" "Deleted password entry ID: $ID"

    unset ID
    echo "Deleted."
  }

#Function to edit a password

edit_pass() {
 read -p "Enter ID to edit: " ID
    if ! is_valid_id "$ID"; then
        echo "Invalid ID. Must be a non-negative integer."
        unset ID
        return 1
    fi

    read -p "New Service: " SERVICE
    read -p "New Username: " USER
    read -sp "New Password: " PASS
    echo ""

    ENC_SERVICE=$(encrypt "$SERVICE")
    ENC_USER=$(encrypt "$USER")
    ENC_PASS=$(encrypt "$PASS")

    ENC_SERVICE_ESC=$(sql_escape "$ENC_SERVICE")
    ENC_USER_ESC=$(sql_escape "$ENC_USER")
    ENC_PASS_ESC=$(sql_escape "$ENC_PASS")

    sqlite3 "$DB" <<EOF
UPDATE passwords
SET service = '$(printf "%s" "$ENC_SERVICE_ESC")',
    username = '$(printf "%s" "$ENC_USER_ESC")',
    encpass = '$(printf "%s" "$ENC_PASS_ESC")'
WHERE id = $ID;
EOF

    # LOGGING
    log_activity "EDIT" "Edited password entry ID: $ID for service: $SERVICE"

    unset ENC_SERVICE ENC_USER ENC_PASS ENC_SERVICE_ESC ENC_USER_ESC ENC_PASS_ESC SERVICE USER PASS ID
    echo "Updated."
}
