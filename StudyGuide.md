# 📚 Password Manager Project – Study Guide

This document lists everything you need to **study, read, or watch** to fully understand and build the  
**CLI Password Manager with AES Encryption** project.

---

## 🧠 Overview

This project combines concepts from:
- **Bash scripting**
- **File encryption (AES-256 via OpenSSL)**
- **Password generation and security**
- **Basic database (SQLite3)**
- **Audit logging and system permissions**

Use this guide as a structured roadmap to learn each part.

---

## 🧩 Topics to Master

### 1. 🐚 Bash Scripting

#### 📘 Read
- [GNU Bash Manual (Chapters 1–4)](https://www.gnu.org/software/bash/manual/bash.html)
- [Bash Scripting Tutorial – Ryan Chadwick](https://ryanstutorials.net/bash-scripting-tutorial/)
- [LinuxCommand.org – Writing Shell Scripts](http://linuxcommand.org/lc3_writing_shell_scripts.php)

#### 🎥 Watch
- [Bash Scripting Full Course – freeCodeCamp](https://www.youtube.com/watch?v=tK9Oc6AEnR4)
- [NetworkChuck – Bash Scripting Crash Course](https://www.youtube.com/watch?v=oxuRxtrO2Ag)

#### 🧩 Focus Topics
- Variables and data types  
- Conditional statements (`if`, `case`)  
- Loops (`for`, `while`)  
- Functions and scope  
- File handling (`cat`, `grep`, `awk`, `sed`)  
- Command substitution and piping  
- Argument parsing (`getopts`)  
- Secure input using `read -s`  
- Exit codes and error handling  

---

### 2. 🔐 Encryption with OpenSSL

#### 📘 Read
- [OpenSSL Encrypt/Decrypt Files (Baeldung)](https://www.baeldung.com/linux/openssl-encrypt-decrypt-file)
- [OpenSSL Command Line Documentation](https://www.openssl.org/docs/manmaster/man1/openssl.html)

#### 🎥 Watch
- [NetworkChuck – Encrypt Files with OpenSSL](https://www.youtube.com/watch?v=9s6M7kY8l4E)
- [TechHut – Encrypt/Decrypt Files in Linux](https://www.youtube.com/watch?v=jY4VqYwNue8)

#### 🧩 Focus Topics
- AES-256-CBC vs AES-256-GCM  
- Salt and Initialization Vector (IV)  
- Base64 encoding/decoding  
- `-pbkdf2` key derivation  
- Encrypt/decrypt text and files from terminal  
- Using passwords with `-pass pass:`  
- Creating random IV/salt with `openssl rand`  

---

### 3. 🔑 Password Generation

#### 📘 Read
- [Secure Random Passwords in Bash (cyberciti.biz)](https://www.cyberciti.biz/faq/linux-random-password-generator/)
- `man pwgen`

#### 🎥 Watch
- [Generate Secure Passwords in Linux – LearnLinuxTV](https://www.youtube.com/watch?v=H_euTYNrPM8)

#### 🧩 Focus Topics
- Random password generation using:
  - `/dev/urandom`
  - `openssl rand -base64 12`
  - `pwgen` utility  
- Understanding entropy and randomness  
- Avoiding predictable or reused passwords  

---

### 4. 🗃️ SQLite3 (Optional Vault Storage)

#### 📘 Read
- [SQLite Command-Line Interface](https://sqlite.org/cli.html)
- [SQLite Tutorial – TutorialsPoint](https://www.tutorialspoint.com/sqlite/index.htm)

#### 🎥 Watch
- [SQLite Crash Course – Web Dev Simplified](https://www.youtube.com/watch?v=byHcYRpMgI4)

#### 🧩 Focus Topics
- Creating and querying databases from terminal  
- SQL basics: `CREATE TABLE`, `INSERT`, `SELECT`, `DELETE`  
- Using `sqlite3` inside Bash scripts  
- File permissions and secure DB storage  

---

### 5. 🧾 Audit Trail & Logging

#### 📘 Read
- `man logger`
- [Linux Logging with date and echo](https://www.gnu.org/software/coreutils/manual/html_node/date-invocation.html)

#### 🧩 Focus Topics
- Logging actions with timestamps:
  ```bash
  echo "$(date '+%Y-%m-%d %H:%M:%S') : Accessed vault" >> audit.log
  ```
- Rotating logs and managing file sizes  
- Using `logger` to log to syslog  
- File permissions for logs (`chmod`, `chown`)  

---

### 6. 🧰 Security Concepts

#### 📘 Read
- [What is AES Encryption? – Cloudflare Learn](https://www.cloudflare.com/learning/ssl/what-is-aes-encryption/)
- [Storing Passwords Securely – StackExchange](https://security.stackexchange.com/questions/211/how-to-securely-store-passwords)
- [PBKDF2 Key Derivation – Wikipedia](https://en.wikipedia.org/wiki/PBKDF2)

#### 🎥 Watch
- [AES Explained – Computerphile](https://www.youtube.com/watch?v=O4xNJsjtN6E)
- [How to Store Passwords Securely – Computerphile](https://www.youtube.com/watch?v=8ZtInClXe1Q)

#### 🧩 Focus Topics
- Symmetric encryption and key handling  
- Importance of salt and IV  
- Password-based key derivation (PBKDF2)  
- Preventing plaintext exposure in memory  
- File permission security (`chmod 600`)  

---

### 7. ⚙️ Integration Practice

#### 🧩 Try These Commands
```bash
# Encrypt and decrypt test files
openssl enc -aes-256-cbc -salt -pbkdf2 -in test.txt -out test.enc -pass pass:MySecret
openssl enc -aes-256-cbc -d -pbkdf2 -in test.enc -out test_decrypted.txt -pass pass:MySecret
```

#### 🧪 Build Mini Demos
- Password generator script using `openssl rand`
- Log file with timestamps for every access
- Encrypt/decrypt file function in Bash
- Optional: small SQLite-based storage script  

---

## 🗓️ Suggested Learning Roadmap (5 Days)

| Day | Focus | Goals |
|-----|--------|-------|
| **Day 1** | Bash Basics | Variables, loops, conditionals, file handling |
| **Day 2** | Advanced Bash | Functions, arguments, error handling, `getopts` |
| **Day 3** | Encryption | OpenSSL usage, AES-256-CBC, salt/IV concepts |
| **Day 4** | Passwords & Logging | Generate passwords, audit trails |
| **Day 5** | Integration | Combine everything into one script, test security |

---

## ✅ Practice Checklist
- [ ] Write a Bash script that reads secure input (`read -s`)  
- [ ] Encrypt and decrypt a text file with OpenSSL  
- [ ] Generate a random password using `openssl rand`  
- [ ] Log activity to a file with timestamps  
- [ ] Create a vault file (`vault.enc`) and test round-trip  
- [ ] Secure file permissions with `chmod 600`  
- [ ] Optional: Store entries in SQLite and retrieve them via CLI  

---

## 🧾 Notes
- Keep all testing inside a local folder (never upload real passwords).  
- Always use `-pbkdf2` with OpenSSL for strong key derivation.  
- Consider adding a `.gitignore` for `vault.enc`, `audit.log`, and other sensitive files.

---

**Happy hacking and stay secure 🔒**