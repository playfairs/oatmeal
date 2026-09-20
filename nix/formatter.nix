{ pkgs }:

pkgs.writeShellApplication {
  name = "oatmeal-format";

  runtimeInputs = [ pkgs.clang-tools pkgs.csharpier pkgs.swift-format ];

  text = ''
    set -eu

    while IFS= read -r -d ''\'' file; do
      case "$file" in
        *.m|*.mm)
          clang-format --style=file:.clang-format-objc -i "$file"
          ;;
        *)
          clang-format --style=file:.clang-format -i "$file"
          ;;
      esac
    done < <(find . \( -path '*/bin' -o -path '*/obj' -o -path './.git' \) -prune -o -type f \( \
      -name '*.h' -o \
      -name '*.hh' -o \
      -name '*.hpp' -o \
      -name '*.hxx' -o \
      -name '*.c' -o \
      -name '*.cc' -o \
      -name '*.cpp' -o \
      -name '*.cxx' -o \
      -name '*.m' -o \
      -name '*.mm' \
    \) -print0)

    while IFS= read -r -d ''\'' file; do
      csharpier format "$file"
    done < <(find . \( -path '*/bin' -o -path '*/obj' -o -path './.git' \) -prune -o -type f -name '*.cs' -print0)

    find . \( -path '*/bin' -o -path '*/obj' -o -path './.git' \) -prune -o -type f -name '*.swift' -print0 | \
      xargs -0 -r swift-format --in-place
  '';
}
