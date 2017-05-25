pkg_origin=smith
pkg_name=ponyserve
pkg_version=0.1.0
pkg_bin_dirs=(bin)
pkg_deps=(core/ponysay core/ruby)
pkg_build_deps=(core/bundler core/sed)
pkg_exposes=(port)
pkg_exports=(
  [port]=port
)

do_prepare() {
  export BUNDLE_SILENCE_ROOT_WARNING=1
  build_line "Setting BUNDLE_SILENCE_ROOT_WARNING=$BUNDLE_SILENCE_ROOT_WARNING"

}

do_build() {
  return 0
}

do_install() {
  cp -R "$SRC_PATH/"* "$CACHE_PATH"
  bundle install \
    --binstubs "$pkg_prefix/bin" \
    --gemfile "$CACHE_PATH/Gemfile" \
    --standalone \
    --retry 5 \
    --jobs 5 \
    --path="$pkg_prefix/lib"
  install -m 0644 "$SRC_PATH/config.ru" "$pkg_prefix"
  install -m 0644 "$SRC_PATH/data/ansi_up.js" "$pkg_prefix"
  sed -i "1c#!$(pkg_path_for ruby)/bin/ruby" "$pkg_prefix/bin/rackup"
}
