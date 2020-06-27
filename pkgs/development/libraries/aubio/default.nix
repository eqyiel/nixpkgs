{ stdenv
, fetchurl
, alsaLib
, fftw
, libjack2
, libsamplerate
, libsndfile
, pkgconfig
, python
, wafHook
, CoreMedia
}:

stdenv.mkDerivation rec {
  name = "aubio-0.4.9";

  src = fetchurl {
    url = "https://aubio.org/pub/${name}.tar.bz2";
    sha256 = "1npks71ljc48w6858l9bq30kaf5nph8z0v61jkfb70xb9np850nl";
  };

  nativeBuildInputs = [ pkgconfig python wafHook ];
  buildInputs = [
    fftw
    libsamplerate
    libsndfile
  ] ++ stdenv.lib.optionals stdenv.isDarwin [
    CoreMedia
  ] ++ stdenv.lib.optionals stdenv.isLinux [
    alsaLib
    libjack2
  ];

  meta = with stdenv.lib; {
    description = "Library for audio labelling";
    homepage = "https://aubio.org/";
    license = licenses.gpl2;
    maintainers = with maintainers; [ goibhniu marcweber fpletz ];
    platforms = platforms.unix;
  };
}
