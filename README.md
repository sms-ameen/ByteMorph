This script is a custom file/folder encryption/decryption utility.

It doesn’t use standard cryptography libraries for encryption but instead performs character substitution on binary data using a password-derived mapping table. It also integrates MD5 checksums for integrity verification.

Syntax:

ByteMorph_2.0.ps1 [-f] [-debug] e/d file/folder


