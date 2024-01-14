import "dev/justfile.default"

develop:
    nix develop "{{ justfile_directory() }}"
