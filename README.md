# Kondiment

Tool for making coding tutorials super quickly.

Just make a git repo of your project where each commit is a tutorial step.

First line of commit message is used as step title.

Rest of commit message is parsed as markdown for step instructions.

Images in `tutorial-media` directory are shown in tutorial.

Changed files / diffs are shown and syntax highlighted, with a fancy theme

## Install

* Clone repo
* cd in to repo directory
* `bundle install`

## Usage

```bash
ruby kondiment.rb PATH_TO_TUTORIAL_REPO PATH_YOU_WANT_HTML_TO_BE_OUTPUT
```