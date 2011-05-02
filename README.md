##TARTIFY - pimp up my PS1

###Wha, Why, Whatfor ?

If you're like me, colors are a gift of the gods which prevent us from
falling back into the middle ages of colorless terminals. The Gods are
not stupid, they did put colors in terminals for a purpose : so that you
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


###What dzit do ?

It addresses 3 concerns of mine :

* A git repository is an anonymous set of files. That's the
  philosophy behind it. However, we often call the directory holding
  a repository with a meaningfull name so as to be able to find it,
  for example. ***I need this name on my prompt***. Second, I need to
  know in which branch I'm currently working.  __GIT_PS1 addresss this
  by displaying the repository's `branch name` followed by esoteric
  symbols such as ***\****, ***%***, ***+***, ***^*** to tell you things
  such as : there are unstaged changes, untracked files, a certain
  amount of stashes,... Only, I've never been able to wrap my believer's
  mind around them


>Solution: use colors for all that

    Untracked files : underline the repo's name
    Unstaged files  : repo's name in bold red
    Uncommited changes : Magenta
    All fine : green
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

    remote origin : O
    tracked : add an arrow
    N commits ahead : green
    N commits behind : red
    remote upstream : U
    another remote : ⇧
    etc...

* Last, I need to see stashes **pop out** because stashes are bad, they
  make me forget about them, and I end screwing up. I need to see how
  many element are in the stash pile, and to always see them, so that I
  can get rid of them as fast as I can

>Solution : use colors for that. A stash is like a cookie. Three
>stashes, 3 symbols. In **bold yellow**

    ☆
    ☆
    ☆
    ...


