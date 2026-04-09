# Pretty tree with colors and dotfiles, skipping .git and node_modules noise.
# Pipes to less only if the output won't fit on one screen (-F quits if it fits).
function tre
    tree -aC -I '.git|node_modules|bower_components' --dirsfirst $argv | less -FRNX
end
