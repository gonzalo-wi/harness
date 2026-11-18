#!/usr/bin/env bash
# Regression tests for guard.sh. Run: bash hooks/test-guard.sh
# Not a hook: install.sh skips files that start with "test-".

cd "$(dirname "$0")" || exit 1
fail=0

run() { # run <tool> <field> <value> -> exit code of guard.sh
  local json
  json="$(node -e 'const [t,f,v]=process.argv.slice(1);process.stdout.write(JSON.stringify({tool_name:t,tool_input:{[f]:v}}))' "$1" "$2" "$3")"
  printf '%s' "$json" | bash ./guard.sh 2>/dev/null
}

expect() { # expect <block|allow> <tool> <command-or-path>
  local want="$1" tool="$2" value="$3" field=command code got
  [ "$tool" = Read ] && field=file_path
  run "$tool" "$field" "$value"; code=$?
  [ $code -eq 2 ] && got=block || got=allow
  if [ "$got" != "$want" ]; then
    echo "FAIL [$tool] want $want, got $got: $value"
    fail=1
  fi
}

# Must block
expect block Bash 'git push --force origin main'
expect block Bash 'git push --force-with-lease origin main'
expect block Bash 'git push -f'
expect block Bash 'git push origin +main'
expect block Bash 'git push origin --delete feature'
expect block Bash 'git push origin :feature'
expect block PowerShell 'git push --force origin main'
expect block Bash 'git worktree remove --force ../other-checkout'
expect block Bash 'git worktree remove -f /c/Users/me/proj-wt'
expect block Bash 'git commit -m "wip" --no-verify'
expect block Bash 'git commit -nm "wip"'
expect block Bash 'git reset --hard HEAD~1'
expect block Bash 'git clean -fd'
expect block Bash 'git clean --force'
expect block Bash 'git checkout -- .'
expect block Bash 'git checkout -f main'
expect block Bash 'git restore .'
expect block Bash 'git branch -D feature'
expect block Bash 'git stash clear'
expect block Bash 'git tag --force v1'
expect block Bash 'rm -rf /'
expect block Bash 'rm -rf ~'
expect block Bash 'rm -rf $HOME'
expect block Bash 'rm -fr .'
expect block PowerShell 'Remove-Item -Recurse -Force C:\'
expect block PowerShell 'Remove-Item $env:USERPROFILE -Recurse'
expect block Bash 'cat .env'
expect block Bash 'cat ./config/.env.production'
expect block PowerShell 'Get-Content .env.local'
expect block Bash 'git add .env'
expect block Read 'C:\proj\.env'
expect block Read '/home/me/proj/.env.local'
expect block Read '/home/me/.ssh/id_rsa'
expect block Read '/proj/certs/server.pem'

# Must allow
expect allow Bash 'git push'
expect allow Bash 'npm test && git push origin main'
expect allow PowerShell 'git push origin main'
expect allow Bash 'git worktree remove --force /tmp/verify-wt'
expect allow Bash 'git worktree remove --force "C:/Users/me/AppData/Local/Temp/claude/x/scratchpad/lint"'
expect allow Bash 'git worktree remove ../clean-wt'
expect allow Bash 'grep -rn "git push" docs/'
expect allow Bash 'git commit -m "feat: allow push notifications"'
expect allow Bash 'git status && git diff'
expect allow Bash 'git add -f dist/keep.txt'
expect allow Bash 'git clean -n'
expect allow Bash 'git clean -nfd'
expect allow Bash 'git restore --staged .'
expect allow Bash 'git checkout main'
expect allow Bash 'git checkout -b feat/x'
expect allow Bash 'git branch -d merged'
expect allow Bash 'git rm --cached .env'
expect allow Bash 'rm -rf dist'
expect allow Bash 'rm -rf /c/Users/me/proj/node_modules'
expect allow Bash 'rm -f /tmp/x.txt'
expect allow PowerShell 'Remove-Item -Recurse -Force .\dist'
expect allow PowerShell 'Remove-Item -Force .\x.txt'
expect allow Bash 'cat .env.example'
expect allow Bash 'cp .env.example .env'
expect allow Read 'C:\proj\.env.example'
expect allow Read '/proj/src/env.ts'
expect allow Read '/proj/README.md'

[ $fail -eq 0 ] && echo "guard.sh: all tests passed"
exit $fail
