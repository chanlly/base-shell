#!/bin/bash

# 1.安装配置oh-my-zsh

## 1.1 安装zsh
$(echo "y\ny\ny\ny\ny\n" | yum install git vim ntpdate net-tools iproute2 wget lsof zsh expect)
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

## 1.2 添加并修改zsh主题
myZshTheme='local ret_status="%(?:%{$fg_bold[green]%}➜ :%{$fg_bold[red]%}➜ )"\n'
myZshTheme+="PROMPT='[%n@%m %{$fg[cyan]%}%c%{$reset_color%} $(git_prompt_info)]# '"
myZshTheme+='ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}git:(%{$fg[red]%}"'
myZshTheme+='ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "'
myZshTheme+='ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[yellow]%}✗"'
myZshTheme+='ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})"'

echo -e "$HOME/.oh-my-zsh/themes" > "myrobbyrussell.zsh-theme"
sed -r 's@ZSH_THEME="robbyrussell"@#ZSH_THEME="robbyrussell"\nZSH_THEME="myrobbyrussell"@g' "$HOME/.zshrc" > "$HOME/.zshrc"

# 1.3 注释.bash_pofile加载逻辑(简单处理即可，因为初始化文件比较简单)
sed -r 's@(#?)(.*\.bashrc)@#\2@g' $HOME/.bash_profile | sed -r 's@^(#?)(fi)@#\2@g' > "$HOME/.bash_pofile"

## 1.4 配置zsh加载.bash_profile文件
echo "source .bash_profile" >> "$HOME/.zshrc"

# 2. 配置ssh
if [ ! -d "$HOME/.ssh"];then
	mkdir "$HOME/.ssh"
fi
chmod 700 "$HOME/.ssh"
cd $HOME/.ssh

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

