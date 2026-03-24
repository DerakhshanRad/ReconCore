#  Simple Network Recon & Enumeration Tool

##  Overview

This project is a lightweight network reconnaissance tool designed to help identify open ports and suggest next steps for enumeration and exploitation.

It is built as a learning tool, especially for beginners preparing for certifications like eJPT.

---

##  Features

* Scan target IP for open ports
* Identify common services (e.g., SMB, SSH, HTTP)
* Provide basic enumeration suggestions
* Lightweight and fast execution

---

##  Usage

Run the tool with a target IP:

```
python3 scanner.py <TARGET_IP>
```

Example:

```
python3 scanner.py 10.10.10.21
```

---

##  How It Works

1. Performs a port scan using Nmap
2. Parses open ports
3. Matches ports to known services
4. Outputs suggested enumeration commands

---

##  Example Output

```
[+] Scanning host: 10.10.10.21

[+] Port 445 open (SMB)
    → Try: smbclient -L //<IP> -N
    → Try: enum4linux -a <IP>

[+] Port 22 open (SSH)
    → Try: ssh user@<IP>

[+] Port 9090 open (HTTP)
    → Try: Open in browser
```

---

##  Suggested Manual Enumeration

### SMB (Port 445)

```
smbclient -L //<IP> -N
enum4linux -a <IP>
```

### SSH (Port 22)

```
ssh <user>@<IP>
```

### Web Services

Open in browser:

```
http://<IP>:PORT
```

---

##  Wordlists

The tool uses a basic wordlist:

```
wordlists/common.txt
```

Make sure this file is **not empty**.

Example contents:

```
admin
login
dashboard
uploads
backup
api
test
```

---

##  Limitations

* Does not perform exploitation automatically
* Limited service-specific logic
* Requires manual follow-up

---

##  Future Improvements

* Add automatic SMB enumeration
* Add web directory brute-forcing
* Support for multiple wordlists
* Better service detection

---

##  Learning Philosophy

This tool is designed to **assist**, not replace, manual testing.

> Scan → Analyze → Attack → Improve the tool

---

##  Disclaimer

This tool is for educational purposes only.
Do not use it on systems you do not have permission to test.

---

##  Author

Derakhshan Radbareh


