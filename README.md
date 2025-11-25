```
__________  _____    _________ _________   ____   _________   ____ ___.____  ___________
\______   \/  _  \  /   _____//   _____/   \   \ /   /  _  \ |    |   \    | \__    ___/
 |     ___/  /_\  \ \_____  \ \_____  \     \   Y   /  /_\  \|    |   /    |   |    |   
 |    |  /    |    \/        \/        \     \     /    |    \    |  /|    |___|    |   
 |____|  \____|__  /_______  /_______  /      \___/\____|__  /______/ |_______ \____|   
                 \/        \/        \/                    \/                 \/        
```
Objective: A CLI-based password vault with secure storage.

    Features:
    1. AES-256 encryption (openssl)
    2. Password generation (random strings)
    3. Search/edit/delete entries
    4. Audit trail for access

Tech: openssl, base64, grep, sqlite3 (optional)

-----------------------------------------------------------------

A secure, lightweight, CLI-based password manager built entirely in Bash. It uses OpenSSL for military-grade encryption and SQLite for structured storage.

## 🚀 Features

  * **Secure Encryption:** Uses **AES-256-CBC** with **PBKDF2** (100,000 iterations) for key derivation.
  * **Zero-Knowledge Storage:** Service names, usernames, and passwords are all encrypted before being stored in the database.
  * **Auto-Initialization:** Automatically creates the necessary database structure on the first run.
  * **Password Generation:** Includes a built-in tool to generate secure, 32-character random passwords.
  * **Management Tools:** View, Add, Edit, and Delete credentials easily via a text-based menu.
  * **Session Security:** Master password is stored as a hash (SHA-512) and sensitive variables are unset immediately after use.

## 🛠️ Prerequisites

Ensure you have the following installed on your system (Linux/macOS):

  * `bash` (4.0+)
  * `openssl`
  * `sqlite3`

## 📂 Project Structure

```text
scripting-workshop-project/
├── main.sh              # Entry point (Run this file)
├── functions.sh         # Core logic (Encryption, DB ops, Menu)
├── DataBase/            # Directory for database storage
│   ├── init.sql         # SQL schema for table creation
│   └── vault.db         # The encrypted SQLite database (Created on runtime)
└── README.md            # Documentation
```

## 💻 Installation & Usage

1.  **Navigate to the project directory:**

    ```bash
    cd scripting-workshop-project
    ```

2.  **Make the scripts executable:**

    ```bash
    chmod +x main.sh functions.sh
    ```

3.  **Run the Vault:**

    ```bash
    ./main.sh
    ```

    *Note: On the first run, the script will automatically create the `DataBase` folder and initialize `vault.db`.*

## 🔐 Getting Started

### 1\. Setup Master Password

Upon first launch, you will be prompted to create a **Master Password**.

  * This password is used to encrypt/decrypt your data.
  * **Do not lose this password.** If lost, your data cannot be recovered.

### 2\. Main Menu

Once authenticated, you can access the following options:

  * **1) View Passwords:** Decrypts and displays a table of all stored credentials.
  * **2) Manage Passwords:**
      * *Add Password:* Manually input Service, Username, and Password.
      * *Auto-generate:* Create a secure entry automatically.
      * *Delete:* Remove an entry by ID.
      * *Edit:* Update an existing entry.
  * **3) Change Master Password:** Update your master encryption key.
  * **4) Exit:** Clears secrets from memory and closes the application.

## 🛡️ Security Details

  * **Encryption:** `openssl enc -aes-256-cbc`
  * **Key Derivation:** `pbkdf2` with Salt and 100,000 iterations (prevents rainbow table attacks).
  * **Hashing:** The master password is hashed using `openssl passwd -6` (SHA-512 crypt) for verification.
  * **Memory Safety:** Critical variables (like the decrypted password) are `unset` in the code as soon as they are processed to prevent memory leakage.

## ⚠️ Important Backup Advice

To backup your vault, you must save two files:

1.  `DataBase/vault.db` (The database)
2.  `master.pass` (The hashed verification file)

**If you lose `master.pass`, the script will not recognize your password, and you will be unable to decrypt the database.**

```
```
