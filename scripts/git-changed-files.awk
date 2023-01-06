# awk script to parse `git status --porcelain` command in order to detect files that were:
# M     - modified
# A, AM - added
# ??    - new unstaged files
# R, RM - renamed
# Useful to run scripts that should operate only on files that have changed, for example:
# linting tools, formatting tools, etc.
#
# Usage example in a bash script: 
# `git status -uall --porcelain | awk -f git-changed-files.awk | while read line; do echo "$line"; done`

{
  if ($1 == "M" || $1 == "A" || $1 == "AM" || $1 == "??") {
    if (match($0, /".*"/) != 0) {
      print substr($0, RSTART+1, RLENGTH-2)
    } else {
      print $2
    }
  } else if ($1 == "R" || $1 == "RM") {
    if (match($0, /->/) != 0) {
      path = substr($0, RSTART+3)
      if (match(path, /".*"/) != 0) {
        print substr(path, RSTART+1, RLENGTH-2)
      } else {
        print path
      }
    }
  }
}
