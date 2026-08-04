#!/bin/bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$REPO_DIR"

SHARED_FILE="$REPO_DIR/.dotfiles-shared"
CURRENT_BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null) || {
	echo "Error: not on a branch (detached HEAD?)"
	exit 1
}
TIMESTAMP=$(date '+%F %T')

# --- Step 1: Fetch all remote branches ---
git fetch --all --quiet 2>/dev/null || true

# --- Step 2: Merge remote changes for current branch ---
git merge "origin/$CURRENT_BRANCH" --no-edit 2>/dev/null || {
	git merge --abort 2>/dev/null || true
	echo "Warning: could not merge origin/$CURRENT_BRANCH, continuing with local state"
}

# --- Load shared paths config ---
SHARED_PATHS=()
if [ -f "$SHARED_FILE" ]; then
	mapfile -t SHARED_PATHS < <(grep -v '^\s*#' "$SHARED_FILE" | grep -v '^\s*$' | sed 's:/*$::')
fi

OTHER_BRANCHES=""
if [ ${#SHARED_PATHS[@]} -gt 0 ]; then
	OTHER_BRANCHES=$(git branch -r | grep -v HEAD | sed 's|origin/||' | tr -d ' ' | grep -v "^${CURRENT_BRANCH}$" | sort -u)
fi

# --- Step 3: Import newer shared files from other branches ---
# For each shared path, find the branch with the most recent commit touching it.
# If another branch is newer than ours, pull its version in before committing.
for path in "${SHARED_PATHS[@]}"; do
	if ! git diff --quiet -- "$path" 2>/dev/null; then
		continue
	fi

	local_hash=$(git rev-parse "HEAD:$path" 2>/dev/null || echo "none")
	local_time=$(git log -1 --format=%ct HEAD -- "$path" 2>/dev/null || echo 0)
	best_branch=""
	best_time=$local_time

	for branch in $OTHER_BRANCHES; do
		remote_hash=$(git rev-parse "origin/$branch:$path" 2>/dev/null || echo "none")
		[ "$remote_hash" = "none" ] && continue
		[ "$remote_hash" = "$local_hash" ] && continue

		remote_time=$(git log -1 --format=%ct "origin/$branch" -- "$path" 2>/dev/null || echo 0)
		if [ "$remote_time" -gt "$best_time" ]; then
			best_branch=$branch
			best_time=$remote_time
		fi
	done

	if [ -n "$best_branch" ]; then
		if [ -d "$REPO_DIR/$path" ]; then
			git rm -rf --quiet "$path" 2>/dev/null || true
		fi
		if git checkout "origin/$best_branch" -- "$path" 2>/dev/null; then
			echo "Updated $path from $best_branch (newer)"
		fi
	fi
done

# --- Step 4: Commit and push local changes ---
git add -A
git diff --cached --quiet || git commit -m "auto-sync $TIMESTAMP"
git push origin "$CURRENT_BRANCH"

# --- Step 5: Propagate shared files to other branches ---
for branch in $OTHER_BRANCHES; do
	WORKTREE_DIR=$(mktemp -d)
	cleanup() { git worktree remove --force "$WORKTREE_DIR" 2>/dev/null; rm -rf "$WORKTREE_DIR"; }
	trap cleanup EXIT

	git worktree add "$WORKTREE_DIR" "origin/$branch" --detach 2>/dev/null || { rm -rf "$WORKTREE_DIR"; continue; }
	git -C "$WORKTREE_DIR" checkout -B "$branch" "origin/$branch" 2>/dev/null || { cleanup; continue; }

	for path in "${SHARED_PATHS[@]}"; do
		src="$REPO_DIR/$path"
		dst="$WORKTREE_DIR/$path"

		[ -e "$src" ] || continue

		if [ -d "$src" ]; then
			rm -rf "$dst"
			mkdir -p "$(dirname "$dst")"
			cp -r "$src" "$dst"
		else
			mkdir -p "$(dirname "$dst")"
			cp "$src" "$dst"
		fi
	done

	git -C "$WORKTREE_DIR" add -A
	git -C "$WORKTREE_DIR" diff --cached --quiet || {
		git -C "$WORKTREE_DIR" commit -m "auto-sync shared configs from $CURRENT_BRANCH"
		git -C "$WORKTREE_DIR" push origin "$branch"
	}

	cleanup
	trap - EXIT
done
