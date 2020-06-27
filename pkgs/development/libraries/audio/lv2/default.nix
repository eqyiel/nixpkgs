{ stdenv, fetchurl, gtk2, libsndfile, pkgconfig, python3, wafHook }:

stdenv.mkDerivation rec {
  pname = "lv2";
  version = "1.18.0";

  src = fetchurl {
    url = "https://lv2plug.in/spec/${pname}-${version}.tar.bz2";
    sha256 = "0gs7401xz23q9vajqr31aa2db8dvssgyh5zrvr4ipa6wig7yb8wh";
  };

  nativeBuildInputs = [ pkgconfig wafHook ];
  buildInputs = [ gtk2 libsndfile python3 ];

  # Prevent configure script from selecting global "/Library/Audio/Plug-Ins/LV2"
  # as bundle directory when building on macOS.
  # https://github.com/drobilla/autowaf/blob/878bdba53979f11fa582088e47997df129e56d16/extras/lv2.py#L58-L73
  wafConfigureFlags = [
    "--lv2dir=${placeholder "out"}/usr/local/lib/lv2"
  ];

  meta = with stdenv.lib; {
    homepage = "https://lv2plug.in";
    description = "A plugin standard for audio systems";
    license = licenses.mit;
    maintainers = [ maintainers.goibhniu ];
    platforms = platforms.linux;
  };
}
