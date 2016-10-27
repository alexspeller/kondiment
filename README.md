# Kondiment

Tool for making coding tutorials super quickly.

Just make a git repo of your project where each commit is a tutorial step.

First line of commit message is used as step title.

Rest of commit message is parsed as markdown for step instructions.

Images in `tutorial-media` directory are shown in tutorial, as part of the
tutorial step for which they are added.

Changed files / diffs are shown and syntax highlighted, with a fancy theme,
nice table of contents etc.

## Install

* Clone repo
* cd in to repo directory
* `bundle install`

## Usage

```bash
ruby kondiment.rb PATH_TO_TUTORIAL_REPO PATH_YOU_WANT_HTML_TO_BE_OUTPUT
```

## Editing git history

If you want to edit your tutorial, you'll need to be comfortable with git
rebasing. The core tool you'll use is:

```console
git rebase -i --root
```

(The `root` option allows you to edit also the first commit in the repository).

Select which commits in the rebase you want to edit by changing the rebase-todo
in the file that pops up, using one of the options for each file in the
instructions that pop up. You can also reorder commits be reordering the lines
in the file, and remove commits be removing them.

When you get to each commit, make the file changes you want then run

```console
git add .
git ci --amend
git rebase --continue
```

If you're pushing your tutorial repo to a remote repo, you'll need to use
`git push -f` to force push.

If you mess stuff up, you can use `git reflog` to find a good commit to go back
to, and then do `git reset --hard <KNOWN GOOD SHA>` to reset.