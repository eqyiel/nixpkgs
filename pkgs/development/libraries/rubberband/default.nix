{ stdenv
, fetchurl
, fetchpatch
, pkgconfig
, libsamplerate
, libsndfile
, fftw
, vamp-plugin-sdk
, ladspaH
, CoreVideo
}:

stdenv.mkDerivation rec {
  pname = "rubberband";
  version = "1.8.2";

  src = fetchurl {
    url = "https://breakfastquay.com/files/releases/${pname}-${version}.tar.bz2";
    sha256 = "1jn3ys16g4rz8j3yyj5np589lly0zhs3dr9asd0l9dhmf5mx1gl6";
  };

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [
    libsamplerate
    libsndfile
    vamp-plugin-sdk
    ladspaH
  ] ++ stdenv.lib.optionals stdenv.isDarwin [
    CoreVideo
  ] ++ stdenv.lib.optionals stdenv.isLinux [
    fftw
  ];

  # https://github.com/breakfastquay/rubberband/issues/17
  # In master, but there hasn't been an official release
  patches = [
    (fetchpatch {
      url = "https://github.com/breakfastquay/rubberband/commit/419a9bcf7066473b0d31e9a8a81fe0b2a8e41fed.patch";
      sha256 = "0drkfb2ahi31g4w1cawgsjjz26wszgg52yn3ih5l2ql1g25dqqn9";
    })
  ];

  dontConfigure = stdenv.isDarwin;

  buildPhase = stdenv.lib.optionalString stdenv.isDarwin ''
    substituteInPlace Makefile.osx \
      --replace "-mmacosx-version-min=10.7" "-mmacosx-version-min=10.12" \
      --replace ':= -L$(PREFIX)/lib -lsndfile $(LIBRARY_LIBS)' \
                ':= -L${stdenv.lib.getOutput "dev" libsndfile}/lib -lsndfile $(LIBRARY_LIBS)' \
      --replace ':= -L$(PREFIX)/lib -lvamp-sdk $(LIBRARY_LIBS)' \
                ':= -L${vamp-plugin-sdk}/lib -lvamp-sdk $(LIBRARY_LIBS)' \
      --replace ':= -framework Accelerate' \
                ':= -L${stdenv.lib.getOutput "dev" libsamplerate}/lib -lsamplerate -framework Accelerate' \
      --replace ':= $(ARCHFLAGS) $(OPTFLAGS) -I. -Isrc -Irubberband -I/usr/local/include -DUSE_PTHREADS -DMALLOC_IS_ALIGNED -DHAVE_VDSP -DUSE_SPEEX -DNO_THREAD_CHECKS -DNO_TIMING' \
                ':= $(ARCHFLAGS) $(OPTFLAGS) -I. -Isrc -Irubberband -I${stdenv.lib.getOutput "dev" libsamplerate}/include -I${stdenv.lib.getOutput "dev" libsndfile}/include -I${vamp-plugin-sdk}/include -DUSE_PTHREADS -DMALLOC_IS_ALIGNED -DHAVE_VDSP -DUSE_SPEEX -DNO_THREAD_CHECKS -DNO_TIMING'\
      --replace "/usr/local" "$out"

    sed -i \
      -e '/$(VAMP_TARGET) $(DESTDIR)$(INSTALL_VAMPDIR)/d' \
      -e '/cp vamp\/vamp-rubberband.cat $(DESTDIR)$(INSTALL_VAMPDIR)/d' \
      -e '/cp $(LADSPA_TARGET) $(DESTDIR)$(INSTALL_LADSPADIR)/d' \
      -e '/cp ladspa\/ladspa-rubberband.cat $(DESTDIR)$(INSTALL_LADSPADIR)/d' \
      -e '/cp ladspa\/ladspa-rubberband.rdf $(DESTDIR)$(INSTALL_LRDFDIR)/d' \
      Makefile.osx

    make -f Makefile.osx
  '';

  installPhase = stdenv.lib.optionalString stdenv.isDarwin ''
    make -f Makefile.osx install
  '';

  meta = with stdenv.lib; {
    description = "High quality software library for audio time-stretching and pitch-shifting";
    homepage = "https://breakfastquay.com/rubberband/";
    # commercial license available as well, see homepage. You'll get some more optimized routines
    license = licenses.gpl2Plus;
    maintainers = [ maintainers.goibhniu maintainers.marcweber ];
    platforms = platforms.unix;
  };
}
