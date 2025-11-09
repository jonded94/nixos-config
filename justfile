# NixOS rebuild commands for jonas-nixos

target_host := "root@jonas-nixos"
ssh_key := "${HOME}/.ssh/nixos_root_ssh_key"
config_file := "configuration.nix"
linting_ignored_files := "hardware-configuration.nix"

lint-check:
    @echo "Checking syntax with nix-instantiate..."
    nix-instantiate --parse {{config_file}} > /dev/null
    @echo "Checking for anti-patterns with statix..."
    nix-shell -p statix --run "statix check --ignore {{linting_ignored_files}}"
    @echo "Formatting with nixfmt..."
    nix-shell -p nixfmt-tree --run "treefmt --ci --excludes {{linting_ignored_files}}"
    @echo "✓ All lint checks passed!"

# Lint the Nix configuration
lint-fix:
    @echo "Checking syntax with nix-instantiate..."
    nix-instantiate --parse {{config_file}} > /dev/null
    @echo "Checking for anti-patterns with statix..."
    nix-shell -p statix --run "statix fix --ignore {{linting_ignored_files}}"
    @echo "Formatting with nixfmt..."
    nix-shell -p nixfmt-tree --run "treefmt --excludes {{linting_ignored_files}}"
    @echo "✓ All lint fixes passed!"

# Internal recipe to run nixos-rebuild
_rebuild add_flags="": lint-fix
    NIX_SSHOPTS="-i {{ssh_key}}" nix-shell -p nixos-rebuild --run "nixos-rebuild switch --target-host {{target_host}} {{add_flags}} -I nixos-config={{justfile_directory()}}/{{config_file}}"

# Build locally and deploy to remote host
build-local:
    @just _rebuild

# Build on remote host and deploy
build-remote:
    @just _rebuild "--build-host {{target_host}}"
