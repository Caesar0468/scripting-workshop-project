
__________  _____    _________ _________   ____   _________   ____ ___.____  ___________
\______   \/  _  \  /   _____//   _____/   \   \ /   /  _  \ |    |   \    | \__    ___/
 |     ___/  /_\  \ \_____  \ \_____  \     \   Y   /  /_\  \|    |   /    |   |    |   
 |    |  /    |    \/        \/        \     \     /    |    \    |  /|    |___|    |   
 |____|  \____|__  /_______  /_______  /      \___/\____|__  /______/ |_______ \____|   
                 \/        \/        \/                    \/                 \/        
                 
----------------Password Manager with Encryption-----------------

Objective: A CLI-based password vault with secure storage.

    Features:
    1. AES-256 encryption (openssl)
    2. Password generation (random strings)
    3. Search/edit/delete entries
    4. Audit trail for access

Tech: openssl, base64, grep, sqlite3 (optional)

-----------------------------------------------------------------

🔐 Bash Encrypted Password Manager (AES-256-GCM + PBKDF2 + SQLite)

A lightweight, secure, and fully terminal-based password manager written entirely in Bash, using:
	•	AES-256-GCM authenticated encryption
	•	PBKDF2-SHA256 (100k iterations) key derivation
	•	SHA-512-crypt (openssl passwd -6) for master password hashing
	•	SQLite database for storage
	•	Zero external dependencies beyond OpenSSL + SQLite3

This project stores no plaintext credentials.
All saved data is encrypted before touching the database.

⸻

🚀 Features

🔒 Strong Security
	•	AES-256-GCM encryption for all fields (service, username, password)
	•	PBKDF2-SHA256 with 100,000 iterations
	•	Automatic random salt generation
	•	Authenticated encryption (detects tampering)
	•	Master password protected with SHA-512-crypt

🗄️ Encrypted SQLite Vault
	•	All credentials stored inside vault.db
	•	Nothing stored in plaintext
	•	Database is safe even if stolen

🖥️ Pure Bash Interface
	•	Fully interactive
	•	No GUI needed
	•	Easy to run anywhere (Linux, macOS)

🔧 Functionalities
	•	Create / verify master password
	•	Add passwords (manual or auto-generated)
	•	Auto-generate strong random passwords
	•	View passwords (automatically decrypted in memory)
	•	Edit entries
	•	Delete entries
	•	Change master password

🧹 Secure by default
	•	Sensitive variables are unset after use
	•	Password prompts are hidden
	•	Encrypted values safely inserted using SQL-escaping

⸻

📁 Project Structure

.
├── vault.sh          # Main program entry
├── functions.sh      # All logic: encryption, menus, SQL, vault operations
├── DataBase/
│   └── vault.db      # SQLite encrypted vault (created automatically)
└── master.pass       # Master password hash (created on first run)


⸻

🔑 Encryption Design

Each value is encrypted like this:

plaintext → AES-256-GCM → binary → base64 → store in SQLite

All encryption uses:

openssl enc -aes-256-gcm -pbkdf2 -iter 100000 -md sha256 -salt

This ensures:
	•	high iteration count (resists brute force)
	•	integrity protection (GCM tag)
	•	salted keys (unique per-row)
	•	password-based key (derived from your master password)

⸻

🛠️ Requirements
	•	Bash
	•	OpenSSL
	•	SQLite3

Most Linux and macOS systems already include these.

⸻

▶️ Usage

1. Clone the repository

git clone https://github.com/Caesar0468/scripting-workshop-project.git
cd bash-password-manager

2. Make scripts executable

chmod +x vault.sh functions.sh

3. Run the vault

./vault.sh

4. First Run → Create Master Password

You will be asked to set a master password:
	•	Must not be empty
	•	Must be typed twice to confirm
	•	Stored as a SHA-512-crypt salted hash

5. Use the Menu

------ MAIN MENU ------
1) View Passwords
2) Manage Passwords
3) Change Master Password
4) Exit

Inside Manage Passwords:

1) Add Password
2) Delete Password
3) Edit Password
4) Back

Inside Add Password:

1) Add Password Manually
2) Auto-generate Password
3) Back


⸻

🔐 Auto-Generated Passwords

The vault uses:

openssl rand -base64 32

generating a 256-bit entropy password.

⸻

🧩 Security Notes
	•	The vault database contains only encrypted values.
	•	Decrypted values are shown only in memory, never written to disk.
	•	Encrypted values are SQL-escaped to prevent SQL injection.
	•	unset is used to remove sensitive variables.
	•	GCM decryption will detect if anyone tampers with the DB file.

⸻

⚠️ Backup Reminder

Backup your two critical files:

master.pass
DataBase/vault.