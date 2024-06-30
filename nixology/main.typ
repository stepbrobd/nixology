#import "@preview/polylux:0.3.1": *
#import themes.simple: *

#let title = "Nixology"
#let author = "Yifei Sun"
#let date = datetime(year: 2024, month: 7, day: 1)

#set document(title: title, author: author, date: date)
#set page(paper: "presentation-16-9")

#show: simple-theme.with(footer: none)

#title-slide[
  #image("nix.svg", width: 10%)

  = #title

  #v(4em)

  #set text(16pt)

  #author

  #date.display("[month repr:long] [day padding:none], [year]")
]

#slide[
  == Problem

  #set align(center)
  #image("works.jpg", width: 75%)
]

#slide[
== Solution

Functions:

#grid(
  columns: 2, gutter: 2.5cm,
)[
```nix
{ inputs = { ... }; }
```

- Dependencies are inputs
- Usually tarballs or git repos
- Pinned and hashed
][
```nix
{ outputs = inputs: { ... }; }
```

- Outputs are functions of inputs// or contents of other outputs, or nothing
- Can be anything
- Lazily evaluated// evaluated only when needed
]
]

#slide[
  == Trinity

  #grid(columns: 2, gutter: 2mm, [
    - Nix - the package manager
    - Nix - the DSL
    - Nixpkgs - the package collection
    - NixOS - the operating system
  ], [#image("trinity.svg", width: 75%)])
]

#slide[
== Language Basics

#grid(columns: 2, gutter: 6cm)[
Integers: ```nix
> x = 1 + 1
> x
2
```

Floats: ```nix
> y = 1.0 + 1.0
> y
2.0
```
][
Strings: ```nix
> z = "world"
> "hello ${z}"
"hello world"
```

Attribute sets: ```nix
> s = { a = { b = 1; }; }
> s.a.b
1
```
]
]

#slide[
== Language Basics

#grid(columns: 2, gutter: 3cm)[
Lists:

```nix
> [ 1 "2" (_: 3) ]
[ 1 "2" <thunk> ]
```

Recursive attrsets:

```nix
> rec { x = 1; y = x; }
{ x = 1; y = 1; }
```
][
Bindings:

```nix
> let x = 1; in x + 1
2
```

Inherits:

```nix
> let x = 1; y = x; in
    { inherit x y; }
{ x = 1; y = 1; }
```
]
]

#slide[
== Language Basics

#grid(columns: 2, gutter: 3cm)[
Functions 1:

```nix
> f = x: x + 1
> f 2
3
> g = g': x: g' x + 1
> g f 2
4
```
][
Functions 2:

```nix
> h = { x ? 1 }: x + 1
> h
<function>
> h { }
2
> h { x = 2; }
3
```
]
]

#slide[
== Derivation

A _derivation_

#grid(columns: 2, gutter: 3cm)[
- is plan / blueprint
- it's used for producing
  - `lib`: library outputs
  - `bin`: binary outputs
  - `dev`: header files, etc.
  - `man`: man page entries
  - ...
][
```hs
  derivation ::
    { system    : String
    , name      : String
    , builder   : Path | Drv
    , ? args    : [String]
    , ? outputs : [String]
    } -> Drv
  ```
]
]

#slide[
== Derivation

Example:

#grid(columns: 2, gutter: 0.75cm)[
```hs
  derivation ::
    { system    : String
    , name      : String
    , builder   : Path | Drv
    , ? args    : [String]
    , ? outputs : [String]
    } -> Drv
  ```
][
```nix
  derivation {
    system = "aarch64-darwin";
    name = "hi";
    builder = "/bin/sh";
    args = ["-c" "echo hi >$out"];
    outputs = ["out"];
  }
  ```
]
]

#slide[
== Derivation

Special variables:

#grid(columns: 2, gutter: 0.75cm)[
```nix
  derivation {
    system = "aarch64-darwin";
    name = "hi";
    builder = "/bin/sh";
    args = ["-c" "echo hi >$out"];
    outputs = ["out"];     ^^^^
  }             ^^^
  ```
][
- `$src`: build source
- `$out`: build output (default)
- custom outputs

]

]

#slide[
== Nix Store

```nix
/nix/store/l2h1lyz50rz6z2c8jbni9daxjs39wmn3-hi
|---------|--------------------------------|-|
store     hash                             name
prefix
```

- Store prefix can be either local or remote (binary cache)
- Hash either derived from input (default) or output (CA derivation)
- The hash ensures two realised derivations with the same name have different
  paths if the inputs differ at all
]

#slide[
== Packaging

The process of: Nix expressions $arrow.r.double$ derivation(s)

- `builtins.derivation`
- `stdenv.mkDerivation` (from `nixpkgs`)
- `pkgs.buildGoApplication` (from `nixpkgs`)
- ...
]

#slide[
== Packaging #footnote("Example 1")

#set text(14pt)

#grid(columns: 2, gutter: 4cm, [
```nix
  {
    inputs = { ... };

    outputs = { self, nixpkgs, flake-utils }:
      flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages.default = pkgs.writeShellApplication {
          name = "moo";
          runtimeInputs = [ pkgs.cowsay ];
          text = "cowsay moo";
        };
      });
  }
  ```
], [
#v(4.5cm)
```txt
 _____
< moo >
 -----
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
  ```
])
]

#slide[
== Development #footnote("Example 2")

#set text(14pt)

#grid(
  columns: 2, gutter: 2cm, [
  *Shell*:

  - `nix develop` // starts a bash, cleans everything
  - `direnv` // keep your current shell, enter a dir, it auto activates, leaves the dir, auto deactivates

  #v(2em)

  ```nix
                      devShells.default = pkgs.mkShell {
                        packages = with pkgs; [
                          cargo
                          rustc
                          rustfmt
                        ];
                      };
                      ```
  ], [
  *Formatter*:

  - `nix fmt`
  - a single package, or $arrow.b$

  #v(2em)

  ```nix
                      formatter = pkgs.writeShellScriptBin "formatter" ''
                        set -eoux pipefail
                        shopt -s globstar
                        ${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt .
                        ${pkgs.rustfmt}/bin/rustfmt **/*.rs
                      '';
                      ```
  ],
)
]

#slide[
== Pinning

#set text(14pt)

#grid(
  columns: 2, gutter: 2cm, [
  *w/ builtin versions*: // for most critical and popular packages: llvm, gcc, node, ...

  ```shell
                        nix-repl> pkgs.coq_8_
                        pkgs.coq_8_10  pkgs.coq_8_12
                        pkgs.coq_8_14  pkgs.coq_8_16
                        pkgs.coq_8_18  pkgs.coq_8_5
                        pkgs.coq_8_7   pkgs.coq_8_9
                        ...
                        ```

  #v(2em)

  *w/ `nix shell`*:

  ```shell
                        nix shell nixpkgs/<hash>#{pkg1,...}
                        ```

  #v(2em)

  *or DIY!*
  ], [
  *w/ flakes*:

  ```nix
                        inputs = {
                          nixpkgsForA.url = "github:nixos/nixpkgs/<branch or hash>";
                          nixpkgsForB.url = "github:nixos/nixpkgs/<branch or hash>";
                          ...
                        };

                        outputs = { self, ... }: {
                          ...
                          pkgsA.<some pkg>;
                          pkgsB.<some pkg>;
                          ...
                        };
                        ```
  ],
)
]

#slide[
== Build System #footnote("Example 3")

Example: `eJS`

- Combine multiple build tools (`ant`, `make`, ...)
- Build multiple targets (binary target, jar, ...)
- Wrap programs
- ...
]

#slide[
== System Configuration #footnote("Ugawa lab infra")

#set text(18pt)

i.e. NixOS

```nix
outputs = { nixpkgs, ... }: {
  nixosConfigurations.test = nixpkgs.lib.nixosSystem {
    modules = [ /* a list of modules goes here */ ];
};};
```

*System Closure*: ```shell
nix build .#nixosConfigurations.test.config.system.build.toplevel
```

*Rebuild*: ```shell
nixos-rebuild <switch|boot|...> --flake .#test
```
]

#slide[
== Resources

- Installer: https://github.com/determinatesystems/nix-installer
- REPL is your friend: `nix repl`
- Intro: https://zero-to-nix.com
- Mannual: https://nixos.org/manual/nix/unstable/
- Forum: https://discourse.nixos.org
- Options: https://mynixos.com
- Source code search:
  - https://github.com/features/code-search
  - https://sourcegraph.com
]
