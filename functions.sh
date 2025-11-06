# functions are defined in this file

#!/bin/bash

# Function to check if master password file exists
check_master(){
if [ ! -f master.pass ]; then
    master_exists=0 
else
    master_exists=1
fi 
}

# Function to create a new master password
create_master(){
read -s -p "Create your master password:" pw
echo ""
if [ -z "$pw" ]; then
    echo "Password cannot be empty. Please try again."
    return 1
fi
read -s -p "Confirm your master password:" pw_confirm
if [ "$pw" != "$pw_confirm" ]; then
    echo ""
    echo "Passwords do not match. Please try again."
    return 1
fi

openssl enc -aes-256-cbc -salt -pbkdf2 -md sha256 -iter 100000 -pass pass:"$pw" -out master.pass <<< "$pw"
chmod 600 master.pass
pw=null
pw_confirm=null
echo ""
echo "Master password created successfully."
}

# Function to enter the vault
vault_entry(){
echo "Welcome to the Vault"
echo ""
read -s -p "Enter the master password: " pw
if [ -z "$pw" ]; then
    echo "Password cannot be empty. Please try again."
    return 1
fi
echo ""
master_password=$(openssl enc -d -aes-256-cbc -salt -pbkdf2 -md sha256 -iter 100000 -pass pass:"$pw" -in master.pass)

if [ $? -eq 0 ] && [ "$master_password" == "$pw" ]; then
    echo "Access Granted"
    entry=1
else
    echo "Access Denied"
    entry=0
fi
unset pw master_password
}

#Function to main menu
main_menu(){}

#Function to view stored passwords
view_pass(){}

#Function to Mangage Passwords Menu
manage_pass_menu(){}

#Function to Add Password Menu
add_pass_menu(){}

#Function to auto generate password
auto_gen_pass(){}

#Function to add new password manually
add_pass(){}

#Function to delete a password
delete_pass(){}

#Function to edit a password
edit_pass(){}

#Function to change master password
change_master(){}
