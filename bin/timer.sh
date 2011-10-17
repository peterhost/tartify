#!/bin/sh
pathToHere=$(cd "$(dirname "$0")"; pwd)

    __K_=$( tput setf 0 || tput setaf 0 || : 2>/dev/null )    # [       0m          SET   FG color to BLACK
    __R_=$( tput setf 4 || tput setaf 1 || : 2>/dev/null )    # [       1m          SET   FG color to RED
    __C_=$( tput setf 3 || tput setaf 6 || : 2>/dev/null )    # [       6m          SET   FG color to CYAN
    __W_=$( tput setf 7 || tput setaf 7 || : 2>/dev/null )    # [       7m          SET   FG color to WHITE

   __EM_=$( tput bold    || : 2>/dev/null )                   # [ 1m                BEGIN DOUBLE INTENSITY (bold) mode
  __EMK_=$__EM_$__K_                                          # [ 1;    20m         SET   FG color to BOLD BLACK
  __EMR_=$__EM_$__R_                                          # [ 1;    21m         SET   FG color to BOLD RED
  __EMC_=$__EM_$__C_                                          # [ 1;    26m         SET   FG color to BOLD CYAN

   __NN_=$( tput sgr0   || : 2>/dev/null )                    # [ 0m                RESET ALL attributes

__getTimeNS(){
  # printf %016d ==>  -  : pad right
  #                   0  : pad with rezoes
  #                   16 : max length = 16
  #                   d  : associated argument is a signed decimal number
  printf "%-016s" $($pathToHere/timeNS) | tr " " "0"
}

__benchmark(){
  #set -- $REPLY
  local iter=$1;
  shift
  [ $iter -gt 1 ] 2>/dev/null || { echo "not a valid iteration number: $iter"; return 1;}
  echo "
  ${__K_}NB iterations :$__R_$iter$__NN_"

  for tested in $*
  do
    __beginT=`__getTimeNS`
    for ((  iki=0; iki<$iter; iki++ ))
            #do $tested
            do $tested  >/dev/null 2>&1
    done

    #echo  $(date +%s)
    __endT=`__getTimeNS`
    __diffT=$(( $__endT - $__beginT ))

    printf "%s\n" $__K_"------------
    NAME (ns) :$__W_$tested
    ${__K_}begin(ns) :$__C_$__beginT$__NN_
    ${__K_}end  (ns) :$__C_$__endT$__NN_
    ${__K_}diff (ns) :$__EMC_$__diffT$__NN_
    ${__K_}moy  (ns) :$__R_$((   $__diffT   / $(( $iki + 1 ))   ))$__NN_
    ${__K_}moy  (ms) :$__EMR_$((   $(( $__diffT / 1000 )) / $(( $iki + 1 ))   ))"$__NN_
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
