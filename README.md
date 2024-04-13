# create_account.sh

1. This bash script is used to create a new user account with a generated RSA private key to log into their account
2. To execute: bash create_account.sh
3. a 16 digit passphase is generated in the new user's /home/username/account_info.txt -> this is need to login via ssh with the RSA key
4. the RSA key is generated in the new user's /home/username/.ssh/id_rsa -> save this in a .pem file or other appropriate key file to use on login

