# Predator_WebScan

Predator_WebScan is a powerful multi-purpose security tool designed to assist penetration testers and security researchers in performing advanced web fuzzing and directory scanning operations efficiently and effectively. It serves as a lightweight and flexible alternative to traditional tools like dirb, gobuster, ffuf, and wfuzz by offering dynamic fuzzing capabilities and recursive wordlist expansion.

Key Features:

🔍 Web Fuzzing & Directory Scanning:

Advanced Fuzzing: Supports multiple FUZZ placeholders for flexible and dynamic input generation.

Directory Enumeration: Automatically switches to directory scanning mode if no "FUZZ" placeholder is present in the URL.

Recursive Expansion: Replaces FUZZ dynamically to generate a broad range of potential attack surfaces.

Smart Filtering: Ignores 404 responses and highlights valid results efficiently.


🚀 High Efficiency & Flexibility:

Multiple Wordlist Support: Allows different wordlists for different placeholders (FUZZ, FUZZ1, FUZZ2, etc.).

Optimized Performance: Lightweight script designed for speed and efficiency.


Usage Examples:

🌐 Web Fuzzing:

./predator_webscan.sh -u "http://example.com/FUZZ/FUZZ1" -w wordlist.txt -w1 wordlist1.txt

📂 Hidden Directory Scanning:

./predator_webscan.sh -u "http://example.com/" -w dirs.txt

⚠ Disclaimer: This tool is intended for ethical security testing purposes only and should only be used on systems where you have explicit permission. The developer is not responsible for any misuse of this tool.

