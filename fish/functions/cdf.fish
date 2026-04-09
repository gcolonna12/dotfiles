# cd to whatever folder Finder currently has open — bridges GUI and terminal workflows
function cdf
    cd (osascript -e 'tell app "Finder" to POSIX path of (insertion location as alias)')
end
