
![Tartify, give some colors to your GIT_PS1](/Users/plhoste/Tmp/tartify.png "Tartify : Optional title")

# TODO: - replace the two 'perl -pe' calls in tartify (for non-ansi char
# substitution)

##Tartification for the masses

If you strongly believe that colors are a gift of the gods which prevent
us from falling back into the middle ages of colorless terminals, surely
you must also know this fact. The Gods are not stupid, they did put
colors in terminals for a reason: so that you use them.  This is known,
in the scriptures, as the process of "**Tartification**", and whatever
two-characters-PS1 addicts can tell you, tartifying is a holly endeavour

**It's like Fight Club**, you don't talk about it, you just do it.

**It's like [Programming, Motherfucker](http://oppugn.us/posts/1300784321.html)**

As most of the directories I spend time in nowadays are GIT
repositories, I need a way
to know exactly where I am *at first glance*.

>*First solution* : use the (excellent) \_\_GIT\_PS1 shell function which
>comes with the default git-completion shell script (usually found in
>your git-X.X.X.X/contrib/completion/ directory), and you're set

Only, this solution is targeted towards heathens who follow the rules of
a monochromatic heresy, of people who are strangers to the beauty of a
properly Tartifed shell

>*Second Solution* : **get the power back**



##What dzit do ?

Nothing fancy really, there are thousands of scripts, from snippets to
fully fledged emacs-like things to manage your PS1. I just wanted two
files, a bash script and a vim script that I could source, have all my
tawdy colors, and be done with it. Eventually the Vim script became a
plugin.

Also, it addresses 3 or 4 concerns of mine :

* A git repository is an anonymous set of files. That's the
  philosophy behind it. However, we often call the directory holding a
  repository with a meaningful name so as to be able to find it, for
  example. ***I need this name on my prompt***. Also, I need to know
  which branch I'm currently working on.  \_\_GIT\_PS1 address this by
  displaying the repository's `branch name` followed by esoteric symbols
  such as `*`, `%`, `+`, `^` to tell you things such as : there are
  unstaged changes, untracked files, a certain amount of stashes,...
  Only, I've never been able to wrap my mind around them bloody symbols,
  they're like [R2D2 speaking Sanskrit to a Wooky](http://www.r2d2translator.com/).
  I remember colors better.


>_Solution_: **use colors for all that**

    Untracked files     : underline the repo's name  
    Unstaged files      : repo's name in bold red  
    Uncommitted changes : Magenta  
    Unpushed to tracked : Yellow
    Life's good         : green  
    ...  

* Most of the time I use Github as a backup solution for my repos, as we
  all do. Most chaps' default settings is to have any local branch track a remote
  branch on an *origins* remote. When co-working, it's useful to
  be able to tell at a glance how many commits ahead/behind I am,
  because my memory is leaking like a friggin colander. ***I need that info in
  my prompt too***

* And sometimes, I fork, say Homebrew, for the 12th time in order to try
  and push a new formula that'll save the world, so I setup another
  *upstream* remote. ***I want to see that in my prompt too***, in
  addition to my *origin* remote.

>_Solution_: **use colors for all that**

    remote origin     : O  
    tracked           : add an arrow  
    N commits ahead   : green  
    N commits behind  : red  
    remote upstream   : U  
    another remote    : ⇧  
    etc...  

* Last, I need to see stashes **REALLY pop out** because stashes are
  bad, they make me forget about them, and I end up screwing things. I
  need to see how many element are in the stash stack, and to always see
  them, so that I can get rid of them as fast as I can

>_Solution_: **use colors for all that** A stash is like a stinkin
>sock. Three stashes, 3 stinkies. In **bold yellow**

    ☆  
    ☆  
    ☆  
    ...  

## Let the images speak for themselves

![Tartify, give some colors to your GIT\_PS1](https://github.com/peterhost/tartify/blob/master/img/tartify-shell.png?raw=true "Tartify : Optional title")

##OMG, how can you stand it ?

As *Dorothy Parker* once said :

    A little bad taste is like a nice dash of paprika.

##WTF, your prompt looks so *noob !

Beware the Law of \*ness

    Apparent signs of elderli*ness* tend to decrease opposite-sex
    attractive*ness*.

##Doesn't it say something about Vim ?

Indeed it does. As if tartifying your shell is not enough, I also offer
you to tartify your favorite editor. This however, is moderate
tartification because Vim only allows the equivalent of 80 printf
commands in it's statusbar, so we have to limit ourselves, be
reasonable, cool down.

####What it does

It does the same. Each of your statusbar will indicate if a buffer
is corresponding to a Git controlled file, and if so, spit out all
the same infos, with less colors.

#####More precisely

* it generates a smart statusline which adapts to the current
  Colorscheme,

* it play nice with plugins like :
   * fugitive
   * NERDTree

* optionally, it will do some debugging and tell you whether a
  Colorscheme is User{N} compatible. Non-User{N} compatibility in a Vim
  ColorScheme is rude. It's like using python when you know perl, or
  voting for Winnie the Pooh.

    Also : it will adapt to the buffer so as not to bother you with a
    bloated statusline in plugin-windows/buffers such as (Taglist,
    YankRing, NERDtree, Fugitive,...). It will be tartified nonetheless,
    but not bloated.  . It will be tartified too, but not bloated.

####Usage

    Source one of the following files within your `.vimrc` and that's all
    (provided you also source the `bashps1` shell script within your
    `.bashrc` ) :

    statusbar.vim : only the GIT relevant part. This is a template you
    can build on to add your favrit custom element to your status line
    statusbarheavy.vim : All in One

##Install

    Do it yourself


##Preemptive FAQ

>Aint it heavy ?

    It is. Reason why Vim's statusbar updates are limited to
    buffer-saving, window-switching, idle time, entering/exiting edit
    mode. In your terminal, only raw CPU powa will save you.

>How does it compare to __git_ps1

    As tartify is basically just a wrapper around __git_ps1, it will be
    somewhat slower.

>You're a bastard and I'll prove it : it works not in windows' version of
>GVim

    I hate you too.
    It sortof works in cygwin, though.

>I attend a *Tartification* class at high school and our teacher asked
>us to write a historical essay, with quotes and stuff. Can you point me
>towards references about this subtle art ?

    A pr0n master once wrote : I can't remember the last time I jacked
    off to black and white pornography.  Can you?  OF COURSE YOU CANT!
    Color is fucking awesome! No one yanks their crank to black and
    white shit anymore.  Once you've tasted color, you can never go
    back.

>Can I help you in your quest for providing the most garish, tawdy,
>tartified PS1 ever ?

    Erhh... yes, sure ! Be my guest
