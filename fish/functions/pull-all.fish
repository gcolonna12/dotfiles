# Clone any missing repos from a GitLab group, then fast-forward `main` in every
# git repo under the current directory, at any depth.
#
# Cloning (requires `glab`):
#   - lists all projects in the group (subgroups included) that you're a member of
#   - clones the ones missing locally under cwd, mirroring the group's subgroup
#     structure. cwd is treated as the group root, so the leading `<group>/` is
#     stripped (run it from the group's dir, not its parent)
#   - the group comes from the first arg, or $PULL_ALL_GROUP if no arg is given
#   - $PULL_ALL_SKIP is an optional space-separated list of subgroup-path globs
#     to skip (e.g. 'archive/*'); set it in your private fish config
#   - skipped entirely if `glab` is not installed or no group is set
#
# Fast-forwarding `main` regardless of which branch is checked out, without
# disturbing feature-branch working trees:
#   - if `main` is checked out: plain `pull --ff-only`
#   - otherwise: advance the local `main` ref without checking it out
#
# Runs in parallel with per-repo labelled output so failures are attributable.
# Matches only real repo roots (`.git` directory) — worktrees and submodules have
# a `.git` *file* and share the parent's main ref, so they are skipped.
function pull-all --description 'clone missing group repos then fast-forward main in all repos under cwd'
    set -l group $argv[1]
    test -n "$group"; or set group $PULL_ALL_GROUP

    if command -q glab; and test -n "$group"
        echo "Checking $group for missing repos…"
        set -l page 1
        while true
            set -l projects (glab repo list --group $group -G --member -P 100 --page $page -F json 2>/dev/null \
                | string collect \
                | python3 -c 'import sys, json
for r in json.load(sys.stdin):
    print(r["path_with_namespace"] + "\t" + r["ssh_url_to_repo"])')
            or break
            test (count $projects) -eq 0; and break

            for line in $projects
                set -l parts (string split \t $line)
                # cwd is the group root, so drop the leading `<group>/` from the
                # namespace path (e.g. mygroup/platform/foo -> platform/foo)
                set -l path (string replace -r "^$group/" '' $parts[1])
                set -l url $parts[2]
                # skip any subgroups the user opted out of via $PULL_ALL_SKIP
                set -l skip 0
                for pattern in $PULL_ALL_SKIP
                    string match -q $pattern $path; and set skip 1; and break
                end
                test $skip -eq 1; and continue
                if not test -d $path/.git
                    echo "cloning $path"
                    git clone $url $path 2>&1 | sed "s|^|$path: |"
                end
            end

            test (count $projects) -lt 100; and break
            set page (math $page + 1)
        end
    end

    command find . -name .git -type d -prune | sed 's|/.git$||' | xargs -P8 -I{} fish -c '
        set -l repo $argv[1]
        if test (git -C $repo branch --show-current) = main
            git -C $repo pull --ff-only 2>&1 | sed "s|^|$repo: |"
        else
            git -C $repo fetch origin main:main 2>&1 | sed "s|^|$repo: |"
        end
    ' {}
end
