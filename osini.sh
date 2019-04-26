#!/bin/bash

# 1.安装配置oh-my-zsh
## 1.1 检查并安装oh-my-zsh
if [ ! -d .oh-my-zsh ]; then
	yum install -y curl git vim ntpdate net-tools iproute2 lsof zsh expect
	# sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" 
	sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
fi

zshrc="$HOME/.zshrc"
bash_profile="$HOME/.bash_profile"
ssh="$HOME/.ssh"

cd $HOME

## 1.2 添加并修改zsh主题
myZshTheme='local ret_status="%(?:%{$fg_bold[green]%}➜ :%{$fg_bold[red]%}➜ )"\n'
myZshTheme+='PROMPT="[%n@%m %{$fg[cyan]%}%c%{$reset_color%} $(git_prompt_info)]# "\n'
myZshTheme+='ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}git:(%{$fg[red]%}"\n'
myZshTheme+='ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "\n'
myZshTheme+='ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[yellow]%}✗"\n'
myZshTheme+='ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})"'

echo -e "$myZshTheme" > "$HOME/.oh-my-zsh/themes/myrobbyrussell.zsh-theme"
if [ "`awk '/ZSH_THEME="myrobbyrussell"/{print $0}' $zshrc`" == "" ]; then
	sed -i -r 's@ZSH_THEME="robbyrussell"@#ZSH_THEME="robbyrussell"\nZSH_THEME="myrobbyrussell"@g' $zshrc
fi

# 1.3 注释.bash_pofile加载逻辑(简单处理即可，因为初始化文件比较简单)
sed -i -r 's@(#?)(.*\.bashrc)@#\2@g' $bash_profile && sed -i -r 's@^(#?)(fi)@#\2@g' $bash_profile

## 1.4 配置zsh加载.bash_profile文件
if [ "`awk '/source .bash_profile/{print $0}' $zshrc`" == ""  ];then
	echo "source .bash_profile" >> $zshrc
fi

# 2. 配置vimrc
vimrc="$HOME/.vimrc"
vimcontent="\" Configuration file for vim
set modelines=0     \" CVE-2007-2438

\" Normally we use vim-extensions. If you want true vi-compatibility
\" remove change the following statements
set nocompatible    \" Use Vim defaults instead of 100% vi compatibility
set backspace=2     \" more powerful backspacing

\" Don't write backup file if vim is being called by \"crontab -e\"
au BufWrite /private/tmp/crontab.* set nowritebackup nobackup
\" Don't write backup file if vim is being called by \"chpass\"
au BufWrite /private/etc/pw.* set nowritebackup nobackup

\" # 语法高亮
syntax on
\" # 自动缩进
set autoindent
\" # 设置实际上读到档案的\t(Tab字元)是，要解析几个空白符
set tabstop=4
\" # 设置缩进符(Tab或者\t)的宽度为4个空格
set shiftwidth=4
set ai!
\" set nu
\" # 显示光标当前位置
\" set ruler 
\" # 将tab转换为空格,vim中使用 :retab! 亦可 [set noexpandtab]
\" set expandtab"

if [ ! -f $vimrc ];then
	touch $vimrc
	echo -e "$vimcontent" > $vimrc
fi

# 3. 配置ssh
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

