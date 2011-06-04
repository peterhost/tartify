#!/bin/sh
pathToHere=$(cd "$(dirname "$0")"; pwd)

__getTimeNS(){
  # printf %016d ==>  -  : pad right
  #                   0  : pad with rezoes
  #                   16 : max length = 16
  #                   d  : associated argument is a signed decimal number
  printf "%-016s" $($pathToHere/timeNS) | tr " " "0"
}

__benchmark(){
  for tested in $*
  do
    __beginT=`__getTimeNS`
    for ((  iki=0; iki<1000; iki++ ))
            #do $tested
            do $tested  >/dev/null 2>&1
    done

    #echo  $(date +%s)
    __endT=`__getTimeNS`
    __diffT=$(( $__endT - $__beginT ))

    echo "------------
    NAME    :$tested
    begin   :$__beginT
    end     :$__endT
    diff    :$__diffT
    moy(ms) :$((   $(( $__diffT / 1000 )) / $(( $iki + 1 ))   ))"
  done
}

__benchmark $*


#
# __func1(){ git stash list | wc -l; }; export -f __func1; __func2(){ git rev-parse --verify refs/stash; }; export -f __func2; sh /Users/plhoste/.vim/bundle/tartify/bin/timer.sh __func1 __func2
#
# EXAMPLES :                                            SMALL (1MB)             HUGE (150MB)
# * git rev-parse --git-dir >/dev/null 2>&1;echo $?     5ms
#   git rev-parse --git-dir >/dev/null 2>&1; aaa=$?     5ms
#   git rev-parse --git-dir >/dev/null 2>&1;            3ms
#   if git rev-parse --git-dir >/dev/null 2>&1;
#    then echo "true"; else echo "false"; fi;           3ms                     3ms
#   __gitdir : in a GIT repo                            4ms
#              elsewhere                                3ms
#
# * Stash
#     git stash list | wc -l :                          51ms                    59ms
#     git rev-parse --verify refs/stash :               4ms                     4ms
#
# * Remote
#
#     __git_ps1_show_upstream :                         16.5ms
#     __tartify_remote :                                75ms
#
# * All
#
#     __git_ps1 :                                       86ms                   197ms
#     tartify : (before opt)                                                   479ms
