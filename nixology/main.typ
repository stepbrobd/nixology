#import "@preview/polylux:0.3.1": *
#import themes.simple: *

#let title = "Nixology"
#let author = "Yifei Sun"
#let date = datetime(year: 2024, month: 2, day: 2)

#set document(title: title, author: author, date: date)
#set page(paper: "presentation-16-9")

#show: simple-theme.with(footer: [])

#title-slide[
  #image("nix.svg", width: 10%)

  = #title

  #v(4em)

  #set text(16pt)

  #author

  #date.display("[month repr:long] [day padding:none], [year]")
]

#slide[
  == What's Nix?

  #grid(columns: 2, gutter: 2mm, [
    The holy trinity #footnote[https://zackerthescar.com/nix-nix-nix]:

    - Nix - the DSL | the package manager
    - Nixpkgs - the package collection
    - NixOS - the operating system
  ], [#image("trinity.svg", width: 74%)])

]

#slide[
  == The Problem

  #set align(center)
  #grid(
    columns: 2,
    gutter: 2mm,
    image("xkcd.png", width: 95%),
    footnote[https://imgs.xkcd.com/comics/cnr.png],
  )
]

#slide[
== "Reproducibility" \* \*\* \*\*\*

```nix
  {
    inputs = { ... };
    outputs = { self, ... } @ inputs: { ... };
  }
  ```

\*: only in *pure* mode // or strick mode, in a pure evaluation, builders don't have external access (network, out of path resources, etc.)

\*\*: can achieve with `nix-channel`, but painful

// almost all community projects are using nix flakes, impossible to get thrown away
// https://determinate.systems/posts/experimental-does-not-mean-unstable
\*\*\*: the example above is with `flakes`, still experiemntal #footnote[$"Experiemntal"^"TM"$ since Nov. 2021]
]

#slide[
== Channels v.s. Flakes

#grid(
  columns: 2,
  gutter: 2cm,
  [
  Channels
  - required by all `nix-*`// CLI tools dependes on channels
  - `nix-channel <args>`// channels can be added, removed, ... with `nix-channel`
  - hard to pin//  to a specific version
  ],
  [
  Flakes:
  - have inputs and outputs, like a function
  - inputs gets "locked" with `flake.lock`
  - experiemntal $!=$ unstable #footnote(
      "https://determinate.systems/posts/experimental-does-not-mean-unstable",
    )
  ],
)
]

#slide[
  == Derivations and Closures #footnote("https://zero-to-nix.com/concepts/derivations")

  A _derivation_

  // - is an instruction
  - can depend on any number of other derivation
  - can produce one or more outputs
  // derivation outputs can be libraries, packages, mannual pages, etc.

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
== Packaging #footnote("https://github.com/stepbrobd/nixology/tree/master/example1")

#set text(14pt)

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
]

#slide[
== Development #footnote("https://github.com/stepbrobd/nixology/tree/master/example2")

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

