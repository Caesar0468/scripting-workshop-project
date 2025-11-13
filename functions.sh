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
read -s -p "Create your master password:" pw_c
echo ""
if [ -z "$pw_c" ]; then
    echo "Password cannot be empty. Please try again."
    return 1
fi
read -s -p "Confirm your master password:" pw_c_confirm
if [ "$pw_c" != "$pw_c_confirm" ]; then
    echo ""
    echo "Passwords do not match. Please try again."
    return 1
fi

openssl passwd -6 $"pw_c" > master.pass
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
pw_v_hash=$(openssl passwd -6 -salt  $"$pw_v")

if [ "$master_hash" == "$pw" ]; then
    echo "Access Granted"
    entry=1
else
    echo "Access Denied"
    entry=0
fi
unset pw_v pw_v_hash master_hash
}

#Function to main menu
main_menu(){
    pass
}

#Function to view stored passwords
view_pass(){
    pass
}

#Function to Mangage Passwords Menu
manage_pass_menu(){
    pass
}

#Function to Add Password Menu
add_pass_menu(){
    pass
}

#Function to auto generate password
auto_gen_pass(){
    pass
}

#Function to add new password manually
add_pass(){
    pass
}

#Function to delete a password
delete_pass(){
    pass
}

#Function to edit a password
edit_pass(){
    pass
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
