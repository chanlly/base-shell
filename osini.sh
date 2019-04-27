#!/bin/bash

green() {
	printf "$(tput setaf 2)"
	echo "$*"
	printf "$(tput sgr0)"
}

main() {
  # Use colors, but only if connected to a terminal, and that terminal
  # supports them.
  if which tput >/dev/null 2>&1; then
      ncolors=$(tput colors)
  fi
  if [ -t 1 ] && [ -n "$ncolors" ] && [ "$ncolors" -ge 8 ]; then
    RED="$(tput setaf 1)"
    GREEN="$(tput setaf 2)"
    YELLOW="$(tput setaf 3)"
    BLUE="$(tput setaf 4)"
    BOLD="$(tput bold)"
    NORMAL="$(tput sgr0)"
  else
    RED=""
    GREEN=""
    YELLOW=""
    BLUE=""
    BOLD=""
    NORMAL=""
  fi

  # Only enable exit-on-error after the non-critical colorization stuff,
  # which may fail on systems lacking tput or terminfo
  set -e

  if ! command -v zsh >/dev/null 2>&1; then
    printf "${YELLOW}Zsh is not installed!${NORMAL} Please install zsh first!\n"
    exit
  fi

  if [ ! -n "$ZSH" ]; then
    ZSH=~/.oh-my-zsh
  fi

  if [ -d "$ZSH" ]; then
    printf "${YELLOW}You already have Oh My Zsh installed.${NORMAL}\n"
    printf "You'll need to remove $ZSH if you want to re-install.\n"
    exit
  fi

  # Prevent the cloned repository from having insecure permissions. Failing to do
  # so causes compinit() calls to fail with "command not found: compdef" errors
  # for users with insecure umasks (e.g., "002", allowing group writability). Note
  # that this will be ignored under Cygwin by default, as Windows ACLs take
  # precedence over umasks except for filesystems mounted with option "noacl".
  umask g-w,o-w

  printf "${BLUE}Cloning Oh My Zsh...${NORMAL}\n"
  command -v git >/dev/null 2>&1 || {
    echo "Error: git is not installed"
    exit 1
  }
  # The Windows (MSYS) Git is not compatible with normal use on cygwin
  if [ "$OSTYPE" = cygwin ]; then
    if git --version | grep msysgit > /dev/null; then
      echo "Error: Windows/MSYS Git is not supported on Cygwin"
      echo "Error: Make sure the Cygwin git package is installed and is first on the path"
      exit 1
    fi
  fi
  env git clone --depth=1 https://github.com/robbyrussell/oh-my-zsh.git "$ZSH" || {
    printf "Error: git clone of oh-my-zsh repo failed\n"
    exit 1
  }


  printf "${BLUE}Looking for an existing zsh config...${NORMAL}\n"
  if [ -f ~/.zshrc ] || [ -h ~/.zshrc ]; then
    printf "${YELLOW}Found ~/.zshrc.${NORMAL} ${GREEN}Backing up to ~/.zshrc.pre-oh-my-zsh${NORMAL}\n";
    mv ~/.zshrc ~/.zshrc.pre-oh-my-zsh;
  fi

  printf "${BLUE}Using the Oh My Zsh template file and adding it to ~/.zshrc${NORMAL}\n"
  cp "$ZSH"/templates/zshrc.zsh-template ~/.zshrc
  sed "/^export ZSH=/ c\\
  export ZSH=\"$ZSH\"
  " ~/.zshrc > ~/.zshrc-omztemp
  mv -f ~/.zshrc-omztemp ~/.zshrc

  # If this user's login shell is not already "zsh", attempt to switch.
  TEST_CURRENT_SHELL=$(basename "$SHELL")
  if [ "$TEST_CURRENT_SHELL" != "zsh" ]; then
    # If this platform provides a "chsh" command (not Cygwin), do it, man!
    if hash chsh >/dev/null 2>&1; then
      printf "${BLUE}Time to change your default shell to zsh!${NORMAL}\n"
      chsh -s $(grep /zsh$ /etc/shells | tail -1)
    # Else, suggest the user do so manually.
    else
      printf "I can't change your shell automatically because this system does not have chsh.\n"
      printf "${BLUE}Please manually change your default shell to zsh!${NORMAL}\n"
    fi
  fi

  printf "${GREEN}"
  echo '         __                                     __   '
  echo '  ____  / /_     ____ ___  __  __   ____  _____/ /_  '
  echo ' / __ \/ __ \   / __ `__ \/ / / /  /_  / / ___/ __ \ '
  echo '/ /_/ / / / /  / / / / / / /_/ /    / /_(__  ) / / / '
  echo '\____/_/ /_/  /_/ /_/ /_/\__, /    /___/____/_/ /_/  '
  echo '                        /____/                       ....is now installed!'
  echo ''
  echo ''
  echo 'Please look over the ~/.zshrc file to select plugins, themes, and options.'
  echo ''
  echo 'p.s. Follow us at https://twitter.com/ohmyzsh'
  echo ''
  echo 'p.p.s. Get stickers, shirts, and coffee mugs at https://shop.planetargon.com/collections/oh-my-zsh'
  echo ''
  printf "${NORMAL}"
  # don't change shell with zsh now
  # env zsh -l
}

isInstallZsh='false'
zshrc="$HOME/.zshrc"
bash_profile="$HOME/.bash_profile"
ssh="$HOME/.ssh"

cd $HOME

# 1.安装配置oh-my-zsh
## 1.1 检查并安装oh-my-zsh
if [ ! -d .oh-my-zsh ]; then
	yum install -y curl git vim ntpdate net-tools iproute2 lsof zsh expect
	# sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" 
	#sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
	main
	isInstallZsh='true'
else
	isInstallZsh='false'
fi

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
green "create .ssh/id_rsa successful. public key is:"
cat id_rsa.pub

# end:
if [ "$isInstallZsh" == 'true' ];then
	env zsh -l
	printf "$(tput setaf 2)"
	echo "change shell to zsh"
	printf "$(tput sgr0)"
fi

