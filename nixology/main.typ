#import "@preview/polylux:0.3.1": *
#import themes.simple: *

#let title = "Nixology"
#let author = "Yifei Sun"
#let date = datetime(year: 2024, month: 6, day: 28)

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
  columns: 2,
  gutter: 2.5cm,
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

  // - is an instruction
  - can depend on any number of other derivation
  - can produce one or more outputs
  // derivation outputs can be libraries, packages, mannual pages, etc.
]

#slide[
  == Closure

  A _closure_

  - encapsulates all of the packages required to build or run it
  - has two types, build-time closure and runtime closure// differenciated by phases, buildPhase, buildInputs, nativeBuildInputs v.s. installPhase, fixupPhase
]

#slide[
== Nix Store #footnote("https://zero-to-nix.com/concepts/nix-store")

```txt
/nix/store/ffkg7rz4zxfsdix6xxmhk2v3nx76r141-nix-2.18.1
|---------|--------------------------------|---------|
 store     hash                             name
 prefix
```

- store prefix can be local or remote (binary cache)
- hash either derived from input (default) or output (CA derivation)
- `*.drv` for derivation files
]

#slide[
== Packaging

Nix expressions $arrow.r.double$ derivation(s)

- `builtins.derivation`
- `stdenv.mkDerivation` (from `nixpkgs`)
- `pkgs.buildGoApplication` (from `nixpkgs`)
- `crane.lib.x86_64-linux.buildPackage` (from `crane`)
- ...
]

#slide[
== Packaging #footnote("https://nixolo.gy/example1")

#set text(14pt)

#grid(columns: 2, gutter: 2cm, [
```nix
  {
    inputs = { ... };

    outputs = { self, nixpkgs, flake-utils }:
      flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        packages.default = pkgs.writeShellApplication {
          name = "cheese";
          runtimeInputs = [ pkgs.cowsay ];
          text = "cowsay cheese";
        };
      });
  }
  ```
], [
#v(4.5cm)
```txt
   ________
  < cheese >
   --------
          \   ^__^
           \  (oo)\_______
              (__)\       )\/\
                  ||----w |
                  ||     ||
  ```
])
]

#slide[
== Development #footnote("https://nixolo.gy/example2")

#set text(14pt)

#grid(
  columns: 2,
  gutter: 2cm,
  [
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
  ],
  [
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
== Development

#set text(14pt)

*Pinning*:

#grid(
  columns: 2,
  gutter: 2cm,
  [
  w/ builtin versions: // for most critical and popular packages: llvm, gcc, node, ...

  ```shell
      nix-repl> pkgs.coq_8_
      pkgs.coq_8_10  pkgs.coq_8_12
      pkgs.coq_8_14  pkgs.coq_8_16
      pkgs.coq_8_18  pkgs.coq_8_5
      pkgs.coq_8_7   pkgs.coq_8_9
      ...
      ```

  #v(2em)

  w/ `nix shell`:

  ```shell
      nix shell nixpkgs/<hash>#{pkg1,...}
      ```

  #v(2em)

  or DIY!
  ],
  [
  w/ flakes:

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
== System Configurations

#set text(18pt)

*Modules* #footnote("https://mynixos.com/nixpkgs/options/services.caddy"):

```nix
{ ... }:
{
  networking.firewall.allowedTCPPorts = [ 80 443 ];
  services.caddy = {
    virtualHosts."nixolo.gy" = {
      extraConfig = "redir https://github.com/stepbrobd/nixology/tree/master{uri}";
      serverAliases = [ "*.nixolo.gy" ];
    };
  };
}
```
]

#slide[
== System Configurations #footnote("https://nixolo.gy/example3")

#set text(18pt)

```nix
outputs = { self, nixpkgs, ... }: {
  nixosConfigurations.example3 = nixpkgs.lib.nixosSystem {
    modules = [ ./hardware.nix ./service.nix ];
  };
};
```

*System Closure*: ```shell
nix build .#nixosConfigurations.example3.config.system.build.toplevel
```

*Rebuild*: ```shell
nixos-rebuild <switch|boot|...> --flake .#example3
```
]
#slide[
  == Resources

  - https://github.com/determinatesystems/nix-installer
  - https://zero-to-nix.com
  - https://nixos.org/manual/nix/unstable/
  - https://discourse.nixos.org
  - https://mynixos.com
  - REPL
  - source code
    - https://github.com/features/code-search
    - https://sourcegraph.com
]

