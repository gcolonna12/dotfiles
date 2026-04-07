# Human-readable file/directory sizes — du's default output is in blocks which nobody thinks in
function fs
    if test (count $argv) -gt 0
        du -sh -- $argv
    else
        # No args: show sizes of everything in current directory including dotfiles
        du -sh .[^.]* ./*
    end
end
