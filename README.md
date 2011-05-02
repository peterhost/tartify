    ########     ##     ######    ########   ######   ######## ###    ###
    ########    ####    ########  ########   ######   ########  ###  ### 
       ##       ####    ##    ##     ##        ##     ##         ######  
       ##      ##  ##   #######      ##        ##     #######     ####   
       ##      ######   ##  ####     ##        ##     ##           ##    
       ##     ###  ###  ##    ##     ##      ######   ##           ##    
       ##     ##    ##  ##    ###    ##      ######   ##           ##    


##TARTIFY - pimp up my PS1

###Tartification for the masses

If you're like me, colors are a gift of the gods which prevent us from
falling back into the middle ages of colorless terminals. The Gods are
not stupid, they did put colors in terminals for a reason: so that you
use them.  This is known, in the scriptures, as the process of
"**Tartification**", and whatever two-characters-PS1 addicts can tell you,
tartifying is a holly endeavour

Most of the time, nowadays, I navigate between GIT repositories and the
time I spend in plain old directories shrinks everyday. I needed a way
to know exactly where I am at one glance. 

>*First solution* : use the (excellent) __GIT_PS1 shell function which
>comes with the default git-completion shell script (usually found in
>your git-X.X.X.X/contrib/completion/ directory), and you're set

>Only, this solution is targetted towards heathens who follow the rules
>of a monochromatic heresy, of people who are strangers to the notion of
>properly Tartifying your shell

>*Second Solution* : get the power back


###What does it look like ?

![Tartify, give some colors to your GIT_PS1](https://github.com/peterhost/tartify/blob/master/img/tartify-shell.png?raw=true "Tartify : Optional title")

###OMG, how can you stand it ?

As *Dorothy Parker* once said :

    A little bad taste is like a nice dash of paprika.


###What dzit do ?

It addresses 3 or 4 concerns of mine :

* A git repository is an anonymous set of files. That's the
  philosophy behind it. However, we often call the directory holding
  a repository with a meaningfull name so as to be able to find it,
  for example. ***I need this name on my prompt***. Second, I need to
  know which branch I'm currently working on.  __GIT_PS1 addresss this
  by displaying the repository's `branch name` followed by esoteric
  symbols such as `*`, `%`, `+`, `^` to tell you things
  such as : there are unstaged changes, untracked files, a certain
  amount of stashes,... Only, I've never been able to wrap my believer's
  mind around them bloody symbols.


>Solution: use colors for all that

    Untracked files     : underline the repo's name
    Unstaged files      : repo's name in bold red
    Uncommited changes  : Magenta
    Life's good         : green
    ...

* Most of the time I use Github as a backup solution for my repos, as we
  all do. My default settings is to have any local branch track a remote
  branch on a beloved *origins* remote. When i'm co-working, I like to
  be able to tell at a glance how many commits ahead/behind I am,
  because my memory is like a friggin colander. ***I need that info in
  my prompt too***

* And sometimes, I enter my twelveth fork of Homebrew, in order to try
  and push a new formula that'll save the world, and setup the upstream
  repository as an *upstream* remote, like we all do. ***I want to
  see that too***, in addition to my *origin* remote.

>Solution : use colors for that

    remote origin     : O
    tracked           : add an arrow
    N commits ahead   : green
    N commits behind  : red
    remote upstream   : U
    another remote    : ⇧
    etc...

* Last, I need to see stashes **pop out** because stashes are bad, they
  make me forget about them, and I end up screwing things. I need to see
  how many element are in the stash stack, and to always see them, so
  that I can get rid of them as fast as I can

>Solution : use colors for that. A stash is like a stinkin cookie. Three
>stashes, 3 stinkies. In **bold yellow**

    ☆
    ☆
    ☆
    ...

###Doesn't it say something about Vim ?

Indeed it does. As if tartifying your shell is not enough, I also offer
you to tartify your favorite editor. This however, is moderate
tartification because Vim only allows the equivalent of 80 printf
commands in it's statusbar, so we have to limit ourselves, be
reasonable, cool down.

>What it does

    It does the same. Each of your statusbar will indicate if a buffer
    is corresponding to a Git controlled file, and if so, spit out all
    the same infos, with less colors.


###Preemptive FAQ

>Aint it heavy ?

    It is. Reason why the statusbar updates are limited are limited to
    window-switching, iddle time, entering/exitig edit mode.

>Won't it slow down my editor and my shell ?

    Yes it will. If that is a problem and you can't live without
    tartification now that you've seen the light, just go buy
    yourself a Cray II, or whatever it is they call them nowadays

>Youse dumb or wha ? Why repeat the parent directory's name in the first
>line and the PWD in your prompt

    Sometimes, directories go so deep underworld that even the `mines of
    Moria` look like rabbit holes. PWD is truncated to 40 characters.
    When you plunge deep under and your monotasking mind is lost, repo's
    name gives the north.

>Were you drunk when you wrote that last answer ?

    Not exactly

>Can I help you in your quest for providing the most garish, tawdy,
>tartified PS1 ever ?

    Erhh... yes, sure ! Be my guest
