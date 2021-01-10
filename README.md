# configfiles
This repo contains shell scripts for automating various setups.

##ZSH
zshinstall.sh is for installing zsh for the first time.
It uses powerlevel10k theme as default. You can use different theme by adding -t option.
Run the following in your terminal
```
sh -c "$(wget -O - https://raw.githubusercontent.com/samsepiol-e/configfiles/v2.0/zshinstall.sh)"
```
zshplugins is for adding plugins. You can specify as many plugins as you like with -p option.
You can either specify git repository of the plugin or plugin name.
```
sh -c "$(wget -O - https://raw.githubusercontent.com/samsepiol-e/configfiles/v2.0/zshplugins.sh)"
```

##Git Branches
Use version.sh to create a new branch. You have to specify argument from release|feature|hotfix, for instance
```
./version.sh hotfix
```
Will create a branch called hotfix/x.y.z
release/feature/hotfit will increment x.y.z by 1 and replace the number on the right to 0. 
Version information is read from currentversion file. It automatically increment the string in the file.
release and feature branches are created from develop branch whereas hotfix branch is created from master branch.


After you are done with your branch, use 
```
./merge_branch.sh
```
To merge your branch.
feature branch is the only branch merging only to develop whereas the rest will merge to both master and develop.
Tag is added based on your branch version.
