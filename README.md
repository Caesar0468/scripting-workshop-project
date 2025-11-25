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

A Simple & Secure Bash Password Manager

PASS VAULT is a lightweight, fully CLI-based password manager built entirely in Bash, using:
	•	AES-256-GCM encryption
	•	PBKDF2-SHA256 key derivation
	•	SQLite for storage
	•	OpenSSL for crypto

No plaintext is ever stored.
Everything is encrypted before touching the database.

⸻

⭐ Why PASS VAULT?

✔ No GUI required
✔ Works on any Linux/macOS terminal
✔ 100% offline — no server, no cloud
✔ Readable, hackable Bash code
✔ Strong modern cryptography
✔ Beginner friendly
✔ Tiny footprint (just a few KB)

⸻

🚀 Features (At a Glance)

🔒 Strong encryption
	•	AES-256-GCM
	•	PBKDF2 with 100,000 iterations
	•	Random salt for every entry
	•	GCM authentication (detects tampering)

🗄️ Encrypted SQLite vault
	•	Stores only encrypted fields
	•	Even stolen DB → still unreadable

🔧 Vault functions
	•	Add passwords
	•	Auto-generate passwords
	•	View decrypted passwords
	•	Edit entries
	•	Delete entries
	•	Change master password

🧼 Secure design
	•	Master password hashed (SHA-512-crypt)
	•	Decrypted data only in RAM
	•	Variables unset after use
	•	SQL injection prevented

⸻

📁 Project Structure

pass-vault/
│
├── vault.sh          # Main program
├── functions.sh      # All logic (encryption, menus, DB ops)
├── init.sql          # Database schema
├── README.md
└── .gitignore

Vault files created at runtime:

DataBase/vault.db     # encrypted SQLite database
master.pass           # hashed master password


⸻

🛠️ Requirements
	•	Bash
	•	OpenSSL
	•	SQLite3

Already installed on most Linux/macOS systems.

⸻

▶️ Getting Started

1. Clone the repo

git clone https://github.com/yourusername/pass-vault.git
cd pass-vault

2. Make scripts executable

chmod +x vault.sh functions.sh

3. Create database

mkdir -p DataBase
sqlite3 DataBase/vault.db < init.sql

4. Run PASS VAULT

./vault.sh


⸻

🔑 First Run

On the first run you’ll be asked to:
	1.	Create a master password
	2.	Confirm it

This master password:
	•	never stored in plaintext
	•	hashed using SHA-512-crypt
	•	used to derive your AES encryption key

⸻

🧭 Main Menu Overview

1) View Passwords
2) Manage Passwords
3) Change Master Password
4) Exit

Manage Passwords → Add / Edit / Delete

1) Add Password Manually
2) Auto-generate Password
3) Back


⸻

🔐 Auto-Generated Passwords

Uses:

openssl rand -base64 32

This gives a 256-bit secure random password.
Perfect for accounts, tokens, API keys, etc.

⸻

🧩 Security Notes (Important)
	•	Vault DB contains only encrypted values
	•	Master password is hashed, not stored
	•	All decrypted data is held only in memory, never written to disk
	•	SQL inserts are sanitized
	•	GCM ensures encrypted fields cannot be tampered with
	•	Losing master.pass or vault.db means losing access permanently

⸻

⚠️ Backup Reminder

Keep these two files safe:
	•	master.pass
	•	DataBase/vault.db

Without both, decryption is impossible.
