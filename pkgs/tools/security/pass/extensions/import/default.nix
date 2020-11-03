{ stdenv, pass, fetchFromGitHub, pythonPackages, makeWrapper, fetchpatch, ensureNewerSourcesForZipFilesHook }:
let
  pythonEnv = pythonPackages.python.withPackages (p: [
    p.defusedxml
    p.setuptools
    p.pyaml
  ]);

in
stdenv.mkDerivation rec {
  pname = "pass-import";
  version = "3.1";

  src = fetchFromGitHub {
    owner = "roddhjav";
    repo = "pass-import";
    rev = "v${version}";
    sha256 = "1846w89v3jnavd63lrn41aldifwx786g9wzxms0kycczll1b2zcw";
  };

  nativeBuildInputs = [ makeWrapper ];

  patches = [
    ./patches/0001-install-paths.patch
    ./patches/0002-make-data-files-more-deletable.patch
  ];

  buildInputs = [ pythonEnv ensureNewerSourcesForZipFilesHook ];

  installPhase = ''
    ${pythonEnv.interpreter} setup.py install_data --install-dir=$out --root=$out

    # This next line depends on `0002-make-data-files-more-deletable.patch`, it
    # removes the `data_files` parameter from the call to setup.  This is
    # required because `install_data` doesn't respect `--prefix` and otherwise
    # leads to paths like in $out 😿
    # https://github.com/NixOS/nixpkgs/issues/23438
    # https://github.com/pypa/setuptools/issues/130
    sed -i '/data_files=data_files/d' setup.py

    ${pythonEnv.interpreter} setup.py install --prefix=$out
  '';

  postFixup = ''
    wrapProgram $out/lib/password-store/extensions/import.bash \
      --prefix PATH : "${pythonEnv}/bin" \
      --prefix PYTHONPATH : "$out/${pythonPackages.python.sitePackages}" \
      --run "export PREFIX"

    wrapProgram $out/bin/pimport \
      --prefix PATH : "${pythonEnv}/bin" \
      --prefix PYTHONPATH : "$out/${pythonPackages.python.sitePackages}" \
      --run "export PREFIX"
  '';

  meta = with stdenv.lib; {
    description = "Pass extension for importing data from existing password managers";
    homepage = "https://github.com/roddhjav/pass-import";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ lovek323 fpletz tadfisher ];
    platforms = platforms.unix;
  };
}
