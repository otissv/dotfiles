# zsh
ln -s ~/dotfiles/zsh/.zlogin ~/.zlogin
ln -s ~/dotfiles/zsh/.zshrc ~/.zshrc
# make zsh default shell
chsh -s $(which zsh)

#i3
ln -s ~/dofiles/.i3/config ~/.i3/conf
ln -s ~/dofiles/.i3/detect_displays.sh ~/.i3/detect_displays.sh
ln -s ~/dofiles/.i3/i3exit ~/.i3/i3exit
ln -s ~/dofiles/.i3/lock.png ~/.i3/lock.png

# i3blocks
rm ~/i3blocks.conf ln -s ~/dotfiles/i3blocks/i3blocks.conf ~/i3blocks.conf

#xorg
rm ~/.xinit && ln -s ~/dotfiles/xorg/.xinit ~/.xinit
rm ~/.xprofile && ln -s ~/dotfiles/xorg/.xprofile ~/.xprofile
rm ~/etc/X11/xorg.conf && ln -s ~/dotfiles/xorg/xorg.conf ~/etc/X11/xorg.conf

# gtk
sudo rm usr/share/gtk-2.0/gtkrc
sudo ln -s ~/dotfiles/gtk/gtkrc usr/share/gtk-2.0/gtkrc
chown ninja /usr/share/gtk-2.0/gtkrc
