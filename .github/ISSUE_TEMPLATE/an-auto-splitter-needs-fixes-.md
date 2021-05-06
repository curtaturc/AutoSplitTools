---
name: An auto splitter needs fixes!
about: Help me help you by providing me with some helpful information.
title: "[GAME NAME] auto splitter does not [start, split, reset, remove loads/sync
  to game time]"
labels: ''
assignees: ''

---

## *Context*
Game name (as it appears on this repo): 

[ ] The game has recently received an update

---
## *Which Features are Broken?*
(*do not check any features which didn't exist to begin with*)

[ ] Start
[ ] Split
[ ] Reset  
[ ] Load removal / Game time synchronization

---
## *Describe your Issue*
[ ] The features checked above outright do not work  
If there is any especially weird behavior with the timer, please describe what is happening:  

---
## *Causes and Fixes*
(*for experienced users only*)

Do you know the exact cause of the problem? Broken pointers, signatures can't be resolved, level names changed? Please elaborate.  
Do you already have a fix? Please give me a merge request with your proposed changes. You will be properly credited.

---
## *Common Issues*
*Only load removal / game time sync is broken, everything else works*: Please make sure you are comparing against Game Time within LiveSplit.  
*The auto splitter cannot be activated from the splits editor*: Try launching LiveSplit as administrator. If the issue persists after that, it is a bug on LiveSplit's side.
