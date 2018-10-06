# Advanced Search on ContraDB
## Introduction
You can search dances for patterns of figures. [This somewhat dated video](https://www.youtube.com/watch?v=pAEUoKCn63o) walks you through it. 

## Filter Operator Reference

### figure

The dance matches if and only if (iff) there is a figure somewhere in the dance.

### formation

The dance matches iff it's formation matches.

### and

Matches iff all the subexpressions match the dance.

### or

Matches iff any of the subexpressions match the dance.

### no

Matches iff the subexpression does not match the dance.

### count

Most queries are for the presence or absence of a thing - the thing
appears either 0 times or 1 time in the dance. Count lets you specify
numbers of times other than 0 or 1 to check for the query.

### then

Like `and`, but the subexpressions have to match in the order they
appear in the dance, directly abuting each other. For example, You can
use this to check for dances with a roll away immediately followed by
a swing, whereas with `and` you could only check to see if the dance
had both a roll away and a swing.

Note: this search wraps around the end of the dance, so `allemande
then allemande` will match a dance where the first and last figures
are allemandes.

`then` gets more interesting when it's subexpressions are more than
simple figures - e.g. `not` and `all`, but for that we need a more
complicated understanding of queries.

## Queries Actually Match Choreography within a Dance - 'Patches'

Up until now, it's been possible to think of each query matching or
not matching on a dance as a whole. But in order to do more
complicated queries, we'll need to think of a query matching or not
matching on the dance as a whole and also on sets of consecutive
figures (here called 'patches', but not called that in the source
code).

If a query doesn't match a dance, then it can have no matching
patches.  A query can match a dance, and match zero or more patches -
we'll see an example of a dance matching with zero figures with `and`,
below.

### figure

Patches 1 figure long, equal to that figure, match.

### or

The dance matches if any subexpression matches. The matched patches
are the unions of the subexpressions' matched patches.

### and

The dance matches if all the subexpressions match. Individual patches
match if they're matched by each subexpression.

It's common to have a matching dance that has zero matching
subexpressions. E.g. `chain and hey` will match lots of dances, but
since no single figure is both a chain and a hey, no figures will ever
match.

### &

Like `and`, but the dance will only match if there is at least one
matching patch.

### count

Count matches the patches of it's subexpression, if it matches at
all. Note that some combinations of `count` and `then` are kind-of
non-useful, such as: "swing then count chain ≥ 2" means "A swing
followed by a chain, and - oh yeah - the dance has to have two
chains".


### no

The dance matches iff the subexpression doesn't match.
If the dance matches, then all 1-fiugre-long patches match.

This is important if you're using `then`: `swing then no hey` will
match the same dances as `swing and no hey` - likely not what you
intended.

### not ('figurewise not')

What we were maybe trying to get in the previous example was a search
for dances that had a swing followed by any move besides a hey, but
that were still allowed to have heys elsewhere in the dance. Enter
`not`. `not` matches all figures (length-1 patches)+ that are not matched
by their subexpression. `swing then not hey` - will match dances with a
swing followed by any figure not a hey.

`not` was formerly called 'anything but'.

### all

The dance matches only if every figure matches - this isn't too
practical, and anyway `all figure x` is equivalent to `not no figure
x`, but it seems somehow to complete the set. Here's one possible
application: imagine teaching contra to a preschool, and you want to
find only dances with certain figures. You could use: `all (swing or
allemande or circle or do si do or star or ...)` to search for dances
that use only simple moves.
