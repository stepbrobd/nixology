{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
    ejs.url = "github:tugawa/ejs-new";
    ejs.flake = false;
  };

  outputs = { self, nixpkgs, utils, ejs }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "ejs";
          version = "unstable-2021-08-19";
          src = ejs;

          dontConfigure = true;

          patchPhase = ''
            runHook prePatch

            # Change hardcoded gcc to $CC
            substituteInPlace ejsi/Makefile \
              --replace 'gcc -O2 -o ejsi ejsi.c' "$CC -O2 -o ejsi ejsi.c"

            runHook postPatch
          '';

          enableParallelBuilding = true;
          buildInputs = with pkgs; [ jdk ];
          nativeBuildInputs = with pkgs; [ ant makeWrapper python3 ];
          buildPhase = ''
            runHook preBuild

            # Build VMGen
            pushd vmgen && ant && popd

            # Build eJSC
            pushd ejsc && ant && popd

            # Build eJSVM
            mkdir -p build && pushd build
            cp ../ejsvm/Makefile.template Makefile
            make CC=$CC CXX=$CXX -j $NIX_BUILD_CORES
            popd

            runHook postBuild
          '';

          installPhase = ''
            runHook preInstall

            mkdir -p $out/share/java
            cp ejsc/newejsc.jar $out/share/java/ejsc.jar
            makeWrapper ${pkgs.jdk}/bin/java $out/bin/ejsc --add-flags "-jar $out/share/java/ejsc.jar"

            mkdir -p $out/bin
            cp build/{ejsi,ejsvm} $out/bin

            runHook postInstall
          '';

          doCheck = false;
        };

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [ ant jdk python3 ];
        };

        formatter = pkgs.nixpkgs-fmt;
      });
}
