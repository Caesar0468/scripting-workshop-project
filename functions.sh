#!/bin/bash
set -o pipefail

# --- CONFIGURATION ---
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DB="$SCRIPT_DIR/DataBase/vault.db"
LOG_FILE="$SCRIPT_DIR/vault_audit.log"

# --- COLORS ---
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# --- LOGGING FUNCTION  ---
log_activity() {
    local action="$1"
    local details="$2"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")

    echo "[$timestamp] [$action] $details" >> "$LOG_FILE"
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
    echo -e "${BLUE}--- First Time Setup ---${NC}"
    read -s -p "Create your master password: " pw_c
    echo ""
    if [ -z "$pw_c" ]; then
        echo -e "${RED}Password cannot be empty.${NC}"
        return 1
    fi
    read -s -p "Confirm your master password: " pw_c_confirm
    echo ""
    if [ "$pw_c" != "$pw_c_confirm" ]; then
        echo -e "${RED}Passwords do not match.${NC}"
        return 1
    fi

    echo -n "Encrypting Master Key..."
    openssl passwd -6 -stdin <<< "$pw_c" > "$SCRIPT_DIR/master.pass"
    chmod 600 "$SCRIPT_DIR/master.pass"
    MASTERPW="$pw_c"
    sleep 1
    echo -e "${GREEN} Done!${NC}"

    log_activity "SYSTEM" "New Master Password created"
    unset pw_c pw_c_confirm
}

encrypt() {
    printf "%s" "$1" | \
    openssl enc -aes-256-cbc -salt -pbkdf2 -iter 600000 -md sha256 -pass fd:3 3<<<"$MASTERPW" | base64 | tr -d '\n'
}

decrypt() {
    printf "%s" "$1" | base64 -d | \
    openssl enc -d -aes-256-cbc -salt -pbkdf2 -iter 600000 -md sha256 -pass fd:3 3<<<"$MASTERPW" 2>/dev/null
}

vault_entry(){
    echo -e "${BLUE}Welcome to the Vault${NC}"
    echo ""
    read -s -p "Enter the master password: " pw_v
    echo ""
    
    if [ -z "$pw_v" ]; then
         echo -e "${RED}Password cannot be empty.${NC}"
         return 1
    fi

    echo -n "Verifying..."
    master_hash=$(cat "$SCRIPT_DIR/master.pass")
    salt=$(echo "$master_hash" | awk -F'$' '{print $3}')
    pw_v_hash=$(openssl passwd -6 -salt "$salt" -stdin <<< "$pw_v")
    sleep 0.5

    if [ "$master_hash" = "$pw_v_hash" ]; then
        echo -e "${GREEN} Access Granted!${NC}"
        MASTERPW="$pw_v"
        entry=1
        log_activity "LOGIN_SUCCESS" "User unlocked the vault"
    else
        echo -e "${RED} Access Denied.${NC}"
        entry=0
        log_activity "LOGIN_FAIL" "Failed attempt to unlock vault"
    fi
    unset pw_v pw_v_hash master_hash salt
}

#Function to main menu
main_menu() {
    clear # Clears screen for a clean look
    echo ""
    echo -e "${BLUE}------ MAIN MENU ------${NC}"
    echo "1) View Passwords"
    echo "2) Manage Passwords"
    echo "3) Exit"
    echo ""
    read -p "Choose an option: " choice
}

#Function to view stored passwords
view_pass() {
    rows=$(sqlite3 -separator $'\x1f' "$DB" "SELECT id, service, username, encpass FROM passwords;")

    # Colored Header
    printf "\n${CYAN}%-5s | %-20s | %-20s | %s${NC}\n" "ID" "SERVICE" "USERNAME" "PASSWORD"
    echo "--------------------------------------------------------------------------"

    while IFS=$'\x1f' read -r ID ENC_SERVICE ENC_USER ENC_PASS; do
         [ -z "$ENC_SERVICE" ] && continue
        SERVICE=$(decrypt "$ENC_SERVICE")
        USER=$(decrypt "$ENC_USER")
        PASS=$(decrypt "$ENC_PASS")

        printf "%-5s | %-20s | %-20s | %s\n" "$ID" "$SERVICE" "$USER" "$PASS"
    done <<< "$rows"

    log_activity "VIEW" "User viewed/decrypted all passwords"
    unset ID ENC_SERVICE ENC_USER ENC_PASS rows
    
    echo ""
    read -p "Press Enter to return..." dummy
}

#Function to Mangage Passwords Menu
manage_pass_menu(){
    echo ""
    echo -e "${BLUE}------ MANAGE PASSWORDS ------${NC}"
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
    echo -e "Generated Password: ${GREEN}$PASS${NC}"
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
    log_activity "ADD" "Auto-generated password added for service"

    unset ENC_SERVICE ENC_USER ENC_PASS SERVICE USER PASS ENC_SERVICE_ESC ENC_USER_ESC ENC_PASS_ESC
    echo -e "${GREEN}Password saved successfully.${NC}"
    echo ""
    read -p "Press Enter to continue..." dummy
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
    log_activity "ADD" "Manual password added for service"

    unset ENC_SERVICE ENC_USER ENC_PASS SERVICE USER PASS ENC_SERVICE_ESC ENC_USER_ESC ENC_PASS_ESC
    echo -e "${GREEN}Password saved successfully.${NC}"
    sleep 1
}

#Function to delete a password
delete_pass(){
    read -p "Enter ID to delete: " ID
    if ! is_valid_id "$ID"; then
        echo -e "${RED}Invalid ID. Must be a non-negative integer.${NC}"
        unset ID
        return 1
    fi

    exists=$(sqlite3 "$DB" "SELECT COUNT(*) FROM passwords WHERE id=$ID;")
    if [ "$exists" -eq 0 ]; then
        echo -e "${RED}Error: ID $ID not found.${NC}"
        unset ID exists
        return 1
    fi

    sqlite3 "$DB" <<EOF
DELETE FROM passwords WHERE id = $ID;
EOF

    log_activity "DELETE" "Deleted password"

    unset ID exists
    echo -e "${GREEN}Deleted.${NC}"
    sleep 1
}

#Function to edit a password
edit_pass() {
    read -p "Enter ID to edit: " ID
    if ! is_valid_id "$ID"; then
        echo -e "${RED}Invalid ID. Must be a non-negative integer.${NC}"
        unset ID
        return 1
    fi

    exists=$(sqlite3 "$DB" "SELECT COUNT(*) FROM passwords WHERE id=$ID;")
    if [ "$exists" -eq 0 ]; then
        echo -e "${RED}Error: ID $ID not found.${NC}"
        unset ID exists
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

    log_activity "EDIT" "Edited password"

    unset ENC_SERVICE ENC_USER ENC_PASS ENC_SERVICE_ESC ENC_USER_ESC ENC_PASS_ESC SERVICE USER PASS ID exists
    echo -e "${GREEN}Updated.${NC}"
    sleep 1
}