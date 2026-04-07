# Create a directory and cd into it in one step — avoids the mkdir then cd dance
function mkd
    mkdir -p $argv; and cd $argv[-1]
end
