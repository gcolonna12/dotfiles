# Use git's colored word-level diff instead of line-level — much easier to spot
# what actually changed in a line, especially in prose or config files
function diff
    git diff --no-index --color-words $argv
end
