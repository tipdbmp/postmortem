# Postmortem - Perl data flow visualizing after the END { }

Patches the importing module's subs so that they print their names, the arguments they were
called with and their return value.

### Caveats
- The placement of the 'use Postmortem;' must be after the sub declarations, so that the
typeglobs would show up in the symbol table
- The output is some-what hard to read/follow.

### Dependencies
- v5.10+
- Package::Stash
