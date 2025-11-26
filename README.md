
# 🔐 Bash Password Vault

![Bash](https://img.shields.io/badge/Language-Bash-4EAA25?style=flat-square&logo=gnu-bash&logoColor=white)
![SQLite](https://img.shields.io/badge/Database-SQLite3-003B57?style=flat-square&logo=sqlite&logoColor=white)
![Security](https://img.shields.io/badge/Security-OpenSSL%20AES--256-red?style=flat-square&logo=openssl&logoColor=white)

```
 ____   __    ___  ___        _  _  __    __  __  __   ____ 
(  _ \ /__\  / __)/ __)      ( \/ )/__\  (  )(  )(  ) (_  _)
 )___//(__)\ \__ \\__ \       \  //(__)\  )(__)(  )(__  )(  
(__) (__)(__)(___/(___/        \/(__)(__)(______)(____)(__) 
````

**PassVault** is a secure, lightweight, CLI-based password manager built entirely in Bash. It leverages **OpenSSL** for military-grade encryption and **SQLite** for structured, queryable storage, ensuring your credentials remain private and secure.

-----

## 🚀 Features

  * **🛡️ Strong Encryption:** Uses **AES-256-CBC** with **PBKDF2** (600,000 iterations) for robust key derivation.
  * **👁️ Zero-Knowledge Storage:** Service names, usernames, and passwords are fully encrypted *before* they touch the database.
  * **📝 Privacy-Preserving Audit Log:** Logs operational events (e.g., "Password Added", "Login Success") to `vault_audit.log` without exposing sensitive metadata like Service Names or IDs.
  * **⚡ Auto-Initialization:** Detects first-run status and automatically sets up the database schema and master password.
  * **🎲 Password Generator:** Built-in CSPRNG tool generates 32-character secure passwords.
  * **🧹 Automatic Cleanup:** Traps system signals (SIGINT/SIGTERM) to securely unset variables and clear memory upon exit.

## 🛠️ Prerequisites

Ensure you have the following installed on your system (Linux/macOS):

  * `bash` (4.0+)
  * `openssl` (1.1.1+)
  * `sqlite3`

## 📂 Project Structure

```text
scripting-workshop-project/
├── main.sh              # 🚀 Entry point (Run this file)
├── functions.sh         # ⚙️ Core logic (Encryption, DB ops, Audit)
├── DataBase/            # 🗄️ Storage directory
│   ├── init.sql         # SQL schema for table creation
│   └── vault.db         # Encrypted SQLite database (Generated on runtime)
├── vault_audit.log      # 📝 Security log (Generated on runtime)
└── README.md            # Documentation
```

## 💻 Installation & Usage

### 1\. Installation

Clone the repository and set executable permissions:

```bash
git clone [https://github.com/Caesar0468/scripting-workshop-project](https://github.com/Caesar0468/scripting-workshop-project)
cd scripting-workshop-project
chmod +x main.sh functions.sh
```

### 2\. First Run (Setup)

Run the main script. On the first launch, you will be asked to create a **Master Password**.

```bash
./main.sh
```

> **⚠️ Warning:** Do not lose your Master Password. Since the system uses PBKDF2 to derive the encryption key directly from your password, **there is no recovery mechanism** if you forget it.

### 3\. Main Menu

Once authenticated, the vault offers the following operations:

1.  **View Passwords:** Decrypts and displays a formatted table of your stored credentials.
2.  **Manage Passwords:**
      * **Add Password:** Manual entry of Service, Username, and Password.
      * **Auto-generate:** Creates a random 32-char password and saves it automatically.
      * **Delete:** Remove an entry permanently by ID.
      * **Edit:** Update an existing entry by ID.
3.  **Exit:** Clears memory, unsets the master key, and closes the application.

## 🛡️ Security Architecture

| Component | Implementation Details |
| :--- | :--- |
| **Encryption Algo** | `aes-256-cbc` |
| **Key Derivation** | `PBKDF2` (Salted, SHA-256, **600,000 Iterations**) |
| **Authentication** | SHA-512 Hash (`openssl passwd -6`) verification |
| **Data Storage** | SQLite3 (All fields are Base64 encoded ciphertext) |
| **File Permissions** | Logs and Password files are strictly `chmod 600` |

### Database Schema

Even if the database file is stolen, the attacker will only see encrypted strings. The schema uses `TEXT` fields to store the Base64 ciphertext:

```sql
CREATE TABLE passwords (
    id INTEGER PRIMARY KEY,
    service TEXT, -- Encrypted
    username TEXT, -- Encrypted
    encpass TEXT -- Encrypted
);
```

## ⚠️ Backup & Advice

To backup your vault, you need to save the following files:

1.  `DataBase/vault.db` (The encrypted data)
2.  `master.pass` (The hashed verification file)

**If you lose `master.pass`, the script will not recognize your password, and you will be unable to decrypt the database.**

-----

```

