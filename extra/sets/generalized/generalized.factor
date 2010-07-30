! Copyright (C) 2010 Sam Anklesaria.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs kernel locals sequences sets ;
IN: sets.generalized

:: tester ( seq quot -- quot' )
    seq quot map unique
    [ [ quot call ] dip key? ] curry ; inline

: diff-by ( seq1 seq2 quot -- newseq )
    tester [ not ] compose filter ; inline

: intersect ( seq1 seq2 -- newseq ) tester filter ; inline

: subset? ( seq1 seq2 -- ? ) tester all? ; inline

: intersects? ( seq1 seq2 -- ? ) tester any? ; inline