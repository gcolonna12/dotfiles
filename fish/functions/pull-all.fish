# Fast-forward `main` in every git repo under the current directory, at any depth.
#
# Updates `main` regardless of which branch is checked out, without disturbing
# feature-branch working trees:
#   - if `main` is checked out: plain `pull --ff-only`
#   - otherwise: advance the local `main` ref without checking it out
#
# Runs in parallel with per-repo labelled output so failures are attributable.
function pull-all --description 'fast-forward main in all repos under cwd, in parallel'
    command find . -name .git -prune | sed 's|/.git$||' | xargs -P8 -I{} fish -c '
        set -l repo $argv[1]
        if test (git -C $repo branch --show-current) = main
            git -C $repo pull --ff-only 2>&1 | sed "s|^|$repo: |"
        else
            git -C $repo fetch origin main:main 2>&1 | sed "s|^|$repo: |"
        end
    ' {}
end
