# AI-powered git commit: stages diff → Claude generates message → accept/edit/regenerate/cancel
# Requires the `claude` CLI (Claude Code): https://docs.claude.com/en/docs/claude-code
function gcm
    function _gcm_generate
        git diff --cached | claude -p "
Below is a diff of all staged changes, coming from the command:

\`\`\`
git diff --cached
\`\`\`

Please generate a concise, one-line commit message for these changes. Output only the commit message, no other text. Do not include any attribution, signature, co-author trailer, or comment such as 'committed with Claude Code'."
    end

    git add -A
    echo "Generating AI-powered commit message..."
    set -l commit_message (_gcm_generate)

    while true
        echo ""
        echo "Proposed commit message:"
        echo "$commit_message"

        read -l -P "Do you want to (a)ccept, (e)dit, (r)egenerate, or (c)ancel? " choice

        switch $choice
            case a A
                if git commit -m "$commit_message"
                    echo "Changes committed successfully!"
                    return 0
                else
                    echo "Commit failed. Please check your changes and try again."
                    return 1
                end
            case e E
                read -l -P "Enter your commit message: " commit_message
                if test -n "$commit_message"; and git commit -m "$commit_message"
                    echo "Changes committed successfully with your message!"
                    return 0
                else
                    echo "Commit failed. Please check your message and try again."
                    return 1
                end
            case r R
                echo "Regenerating commit message..."
                set commit_message (_gcm_generate)
            case c C
                echo "Commit cancelled."
                return 1
            case '*'
                echo "Invalid choice. Please try again."
        end
    end
end
