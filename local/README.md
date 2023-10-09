Contains local library deps which may be forked or not hosted on Hex.

## mist
Since Gleam does not yet support Github repo refs a deps, we must use a local 
path to the mist library. This is a fork of the original mist library with a
required fix for websockets https://github.com/rawhat/mist/pull/25.

Once the fix is released, we can switch back to the original library.