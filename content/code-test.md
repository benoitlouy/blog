+++
title = "Creating a nix overlay to patch a python package"
date = 2024-08-24

[taxonomies]
categories = ["nix"]
tags = ["nix", "python"]
+++

I recently ran into an error while updating my nixos configuration: the python
package wxpython pulled as a dependency of another package was failing to build
with the following error.
```
error: wxpython-4.2.1 not supported for interpreter python3.12
```
A quick search and I was able to find a patch to get wxpython to build. Rather
than waiting for the patch to make its way into the nixpkgs repository, I decided
to make an overlay for it. In nix, python package derivations are defined once
but are built for multiple python versions so creating an overlay requires using
`pythonPackagesExtensions` as follow.


```nix
self: super:

{
  pythonPackagesExtensions = super.pythonPackagesExtensions ++ [
    (pyfinal: pyprev: {
      wxpython = pyprev.wxpython.overrideAttrs (old: {
        disabled = false;
        postPatch =
          let
            waf_2_0_25 = super.fetchurl {
              url = "https://waf.io/waf-2.0.25";
              hash = "sha256-IRmc0iDM9gQ0Ez4f0quMjlIXw3mRmcgnIlQ5cNyOONU=";
            };
          in
          ''
            cp ${waf_2_0_25} bin/waf-2.0.25
            chmod +x bin/waf-2.0.25
            substituteInPlace build.py \
              --replace-fail "wafCurrentVersion = '2.0.24'" "wafCurrentVersion = '2.0.25'" \
              --replace-fail "wafMD5 = '698f382cca34a08323670f34830325c4'" "wafMD5 = 'a4b1c34a03d594e5744f9e42f80d969d'" \
              --replace-fail "distutils.dep_util" "setuptools.modified"
          '';
      });
    })
  ];
}
```
