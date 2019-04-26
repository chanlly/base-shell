#!/bin/bash

cd $HOME

zshrc="$HOME/.zshrc"
bash_profile="$HOME/.bash_profile"
ssh="$HOME/.ssh"

# 1.安装配置oh-my-zsh

## 1.1 安装zsh
yum install -y curl git vim ntpdate net-tools iproute2 lsof zsh expect
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" 
sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"

## 1.2 添加并修改zsh主题
myZshTheme='local ret_status="%(?:%{$fg_bold[green]%}➜ :%{$fg_bold[red]%}➜ )"\n'
myZshTheme+='PROMPT="[%n@%m %{$fg[cyan]%}%c%{$reset_color%} $(git_prompt_info)]# "\n'
myZshTheme+='ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}git:(%{$fg[red]%}"\n'
myZshTheme+='ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "\n'
myZshTheme+='ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[yellow]%}✗"\n'
myZshTheme+='ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})"'

echo -e "$myZshTheme" > "$HOME/.oh-my-zsh/themes/myrobbyrussell.zsh-theme"
sed -i -r 's@ZSH_THEME="robbyrussell"@#ZSH_THEME="robbyrussell"\nZSH_THEME="myrobbyrussell"@g' $zshrc

# 1.3 注释.bash_pofile加载逻辑(简单处理即可，因为初始化文件比较简单)
sed -i -r 's@(#?)(.*\.bashrc)@#\2@g' $bash_profile && sed -i -r 's@^(#?)(fi)@#\2@g' $bash_profile

## 1.4 配置zsh加载.bash_profile文件
echo "source .bash_profile" >> $zshrc

# 2. 配置ssh
if [ ! -d $ssh ];then
	mkdir $ssh
fi
chmod 700 $ssh
cd $ssh

# 创建authorized_keys
if [ ! -f authorized_keys ]; then
	touch authorized_keys
fi
chmod 600 authorized_keys

# 创建密钥对
if [ ! -f "id_rsa" ]; then
    echo "n\n" | ssh-keygen -t rsa -f id_rsa -P "" > /dev/null
fi

# 输出公钥信息
cat id_rsa.pub

