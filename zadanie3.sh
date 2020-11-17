#!/bin/bash
echo -e "WELCOME!\n Today is: $(date +%d.%m.%Y)\n Time: $(date +%H:%M:%S)\n The last login:\n $(last | head -1). \n Are you new user? (y/n).\n"

shopt -s expand_aliases
alias ll='ls -al'
alias c='clear'
alias ls='ls -F'

read answer
case "$answer" in
	N|n)
	echo -e "Your login:"
	read loginn
	echo -e "There are some aliases for you: \n c = clear \n ll = ls -al\n ls = ls -F\n Please write a command or write 'stop' if you want to login now:"
	while :
	do
		read command
		command_to_stop="stop"
		if [[ $command == $command_to_stop ]];
		then
			if id "$loginn" &>/dev/null; then
				#echo "Please, write your password"
				#login $loginn
				echo "User with this name exists."
				break
			else
				echo "User with this name doesn't exist."
				break
			fi
		fi
		eval "$command"
	done
	;;
	y|Y)
	echo "Your name:"
	read user_name
	new_user_name=${user_name:0:1}
	echo "Your family name:"
	read family_name
	new_user_name="$new_user_name$family_name"
	echo -e "There are some aliases for you: \n c = clear \n ll = ls -al\n ls = ls -F\n Please write a command or write 'stop' if you want to login now:"
        while :
        do
                read command
                command_to_stop="stop"
                if [[ $command == $command_to_stop ]];
                then
			if id "$new_user_name" &>/dev/null; then
                        	echo "User with this name already exists."
                        	#login $new_user_name
				break
			else
				adduser "$new_user_name" --force-badname
				dir=/home/$new_user_name
				mkdir $dir/public_html
				cd $dir/public_html
				mkdir private_html
				chown -R $new_user_name:$new_user_name private_html
				echo $new_user_name >> /etc/vsftpd.userlist
				echo " " 
				echo "Write password for your private_html:"
				htpasswd -c $dir/public_html/private_html/.htpasswd $new_user_name
				chmod 644 $dir/public_html/private_html/.htpasswd
				echo "AuthType Basic" >> $dir/public_html/private_html/.htaccess
				echo -e "AuthName \"Username and password required\"" >> $dir/public_html/private_html/.htaccess
				echo -e "AuthUserFile $dir/public_html/private_html/.htpasswd" >> $dir/public_html/private_html/.htaccess
				echo "Require valid-user" >> $dir/public_html/private_html/.htaccess  
				break
			fi
                fi
                eval "$command"
        done

	;;
	*) echo "Please, write y(yes) or n(no)."
	;;
esac
