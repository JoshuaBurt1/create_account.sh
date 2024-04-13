echo "This script will create a new user account on this system. The script will also attempt to generate the relevant RSA encryption files and configure the account for SSH login."
echo "Please provide the following information for the new user."
echo "First Name: "
read FirstName
echo "Lastname: "
read LastName
echo "Email address: "
read email
echo "username: "
read username

Password=`< /dev/urandom tr -dc _A-Z-a-z-0-9\%\&\*\$\#\@\! | head -c${1:-16};echo;`

#if password creation succeeded, remove all files in .ssh
if [ $? -eq 0 ]; then
        rm /etc/skel/.ssh/*
fi

#if .ssh directory exists, generate id_rsa; else make the .ssh directory & generate id_rsa
if [ -d /etc/skel/.ssh ]; then
        ssh-keygen -q -t rsa -b 4096 -f /etc/skel/.ssh/id_rsa -N "$Password"
else
        sudo chmod 777 /etc/skel
        sudo mkdir -p /etc/skel/.ssh
        sudo chmod 777 /etc/skel/.ssh
        sudo ssh-keygen -q -t rsa -b 4096 -f /etc/skel/.ssh/id_rsa -N "$Password"
fi

if [ $? -eq 0 ]; then
        echo "RSA key was generated successfully."
else
        echo '!!! ssh-keygen failed. Deleting the user account. !!!'
        sudo rm -r /home/$username
        exit 2
fi

cp /etc/skel/.ssh/id_rsa.pub /etc/skel/.ssh/authorized_keys

# Generate a message for the user and store it in account_info.txt
echo "Hello $FirstName" > /etc/skel/account_info.txt
echo "You have been granted a user account on our system. " >> /etc/skel/account_info.txt
echo "Your User Name is: $username" >> /etc/skel/account_info.txt
echo "Your randomly generated Passphrase is: $Password" >> /etc/skel/account_info.txt
echo "You are being provided with your own RSA private key. The server will be configured with your public key in order to allow you access to the server via SSH." >> /etc/skel/account_info.txt
echo "Make sure to protect and guard your private key and passphrase at all costs!" >> /etc/skel/account_info.txt

sudo adduser --gecos "$first_name, $last_name, $email, $username" --disabled-password $username

# Set permissions for key to be useable
sudo chmod 700 /home/$username/.ssh
sudo chmod 600 /home/$username/.ssh/authorized_keys

if [ $? -eq 0 ]; then
        echo "Linux User account for ${FirstName} $LastName was created successfully."
        echo "The authorized_keys file was placed in user's folder."
else
        echo '!!! User account was not added. AddUser Returned exit status '$?' !!!'
        exit 1
fi


