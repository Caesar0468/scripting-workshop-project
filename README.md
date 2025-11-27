# scripting-workshop-project
----------------Password Manager with Encryption-----------------

Objective: A CLI-based password vault with secure storage.

    Features:
    1. AES-256 encryption (openssl)
    2. Password generation (random strings)
    3. Search/edit/delete entries
    4. Audit trail for access

Tech: openssl, base64, grep, sqlite3 (optional)

-----------------------------------------------------------------

```
Start Program
Checks if master.pass exists (check_master())
|--if yes -> vault_entry()    
|             |-- if matched -> main_menu()
|             |                   1. View Passwords(view_pass()) ->main_menu()
|             |                   2. Manage Passwords
|             |                       |
|             |                       |-- 1. Add Password 
|             |                       |       |- 1. Auto-Generate(auto_gen_pass()) ->main_menu()
|             |                       |       |- 2. Manual Entry(add_pass()) ->main_menu()
|             |                       |       |_ 3. Return to Menu -> main_menu()
|             |                       |-- 2. Delete Password(delete_pass()) -> main_menu()
|             |                       |__ 3. Edit Password(edit_pass()) -> main_menu()
|             |                       |__ 4. Return to main menu
|             |                   3. Change Master Password
|             |                       |__ change_master() -> Start Program
|             |                   4. Exit -> Return 0
|             |
|             |__ if not match -> exit
|
|__if no -> create_master() --> Start Program
```
