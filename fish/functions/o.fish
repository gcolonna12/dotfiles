# Open current directory (or given path) in Finder — saves reaching for the mouse
function o
    if test (count $argv) -eq 0
        open .
    else
        open $argv
    end
end
