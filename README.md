# AccDemo smoke + exact Mode 3 tests

Builds two separate dylibs.

## 1. AccDemoSmoke_10x.dylib

Hooks `clock_gettime()` only after `UIApplicationDidFinishLaunching`, but
does not modify the returned timestamp at all.

Use this FIRST.

- If Arcaea crashes with Smoke: the problem is the function-hook mechanism /
  binary compatibility, not 0.5x time manipulation.
- If Arcaea runs with Smoke: proceed to Exact 0.5x.

## 2. AccDemoExact_05x.dylib

A minimal reimplementation of the published AccDemo Mode-3 algorithm:
successive `clock_gettime()` deltas are multiplied by 0.50 and accumulated
into the timestamp returned to the process.

No floating UI and no extra time hooks are included.

## IMPORTANT

Do NOT put both dylibs in the same active tweak folder.

Test them one at a time:

1. Tweak folder contains only `AccDemoSmoke_10x.dylib`.
2. Launch Arcaea.
3. If stable, remove Smoke.
4. Add only `AccDemoExact_05x.dylib`.
5. Relaunch and test an offline chart.

Use modified timing only for local/offline testing; do not submit modified
scores to online rankings.
