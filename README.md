# bin_todo

# About

Vim plugin for managing a todo list.  It will operate on any file named `todo.txt`.

## Format

Todo lists look like this:

```
= 9/5/2020 =
	! [9/5/20] jkl
	* [9/4/20] qwerty
	~ [9/8/20] zcxv
	. [9/6/20] uiop
	! foo
	* bar
	~ baz
	. asdf
	# done
```

They are sorted automatically by both importance and due date.  Each entry is prefixed with a
symbol from the following list.  Symbols signify the importance of a task, with a larger 
number representing higher importance.  They are also highlighted according to urgency:

Symbol | Importance | Color
--- | --- | ---
`!` | 4 | Red
`*` | 3 | Yellow
`~` | 2 | Green
`.` | 1 | Blue
`#` | 0 | Gray

Note that `#` is intended to represent a comment.  It will always be prioritized below all other 
items due to its importance of zero and the way scoring happens.

Child items are supported without a bound on the depth.  A child is denoted by indenting 
the item one tab past the parent item.  Children are sorted according to the same scoring 
system as parent items, though a set of children is treated as a separate sub-list.  If 
a parent moves up in the list, its children will follow.

Please note that items must be indented with hard tabs only; no space approximations.

Days are delimited with a date block of the format `= mm/dd/yyyy =`.  These should be 
automatically updated when creating a new day.

Each day the user is to create a new list by running the `:Newday` command.  This will copy 
all un-finished items from the previous day (i.e., those not denotated with a `#`) to a new 
date block headed by the current day.

## Scoring

Each entry receives a score according to its importance and how soon it is due.  Scores are 
calculated by dividing the importance by the base-five log of the number of days until due.  
The reason I take the base-five log rather than simply using the number of days until due 
is to decrease the negative weight against an items position as the number of days 
increases.  The idea is to prevent something due in a month but with high importance from 
being constantly pushed under something due in a week but with lower importance.

## Sorting

After each time insert mode is exited, the plugin triggers and sorts the list.  It does this 
by reading the list into a trie representation, sorting the trie, re-formatting it, and 
printing it back out.  This means the plugin will "eat" any invalid or empty lines it 
encounters.

# Installation

This plugin can be installed like any other vim plugin.  I use junegunn's vim-plug, and therefore
install it like this: `Plug 'bin/bin_todo'`.

# To-do

* Fix known bugs.
* Find a better way to handle errors?
* Performance improvements where possible, though I have yet to encounter issues.
* Add a setting to sort with a manually-executed command, rather than each time the user leaves insert mode.
* Potentially somehow restrict user input to prevent issues with incomplete or badly-fomratted lines?


# Known bugs

* If the cursor is positioned on a list-delimiting block (one of the `= mm/dd/yyyy =` lines) and in insert mode, when leaving insert mode, the plugin "eats" the top line of the list.
* Syntax highlighting is glitchy at times.  This is likely my questionable regex skills at it again.
