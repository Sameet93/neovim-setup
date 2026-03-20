#!/usr/bin/env bash
# =============================================================================
# Neovim DevOps IDE — Installer
#
# What this script does:
#   1. Detects OS (macOS/Linux) and installs Neovim + core dependencies
#   2. Backs up any existing Neovim config/data/state/cache with a timestamp
#   3. Copies (or symlinks) this repo's nvim/ directory to ~/.config/nvim
#   4. Offers to install optional DevOps CLI tools (terraform, ansible, etc.)
#   5. Offers to install Ollama + pull the codestral model for AI assistance
#
# Usage:
#   ./install.sh               # copy mode  (safe default)
#   ./install.sh --symlink     # symlink mode (edits reflect back to the repo)
#   ./install.sh --help        # show help
#
# Requirements: bash >= 3.2, git, curl or brew (macOS)
# =============================================================================

set -euo pipefail

# ─── Colours ─────────────────────────────────────────────────────────────────
BOLD="\033[1m"
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
CYAN="\033[0;36m"
RESET="\033[0m"

info()    { echo -e "${BLUE}[INFO]${RESET}  $*"; }
success() { echo -e "${GREEN}[OK]${RESET}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${RESET}  $*"; }
error()   { echo -e "${RED}[ERROR]${RESET} $*" >&2; }
header()  { echo -e "\n${BOLD}${CYAN}==> $*${RESET}"; }
die()     { error "$*"; exit 1; }

# ─── Parse arguments ─────────────────────────────────────────────────────────
SYMLINK=false
for arg in "$@"; do
  case "$arg" in
    --symlink) SYMLINK=true ;;
    --help|-h)
      echo "Usage: $0 [--symlink] [--help]"
      echo ""
      echo "  (no flags)   Copy nvim/ to ~/.config/nvim (safe default)"
      echo "  --symlink    Symlink ~/.config/nvim → this repo's nvim/"
      echo "               Edits in ~/.config/nvim will live in this repo."
      exit 0
      ;;
    *) die "Unknown argument: $arg  (use --help for usage)" ;;
  esac
done

# ─── Resolve the repo root (directory this script lives in) ─────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NVIM_SOURCE="${SCRIPT_DIR}/nvim"

[[ -d "$NVIM_SOURCE" ]] || die "Cannot find nvim/ directory at: $NVIM_SOURCE"

# ─── Detect OS ───────────────────────────────────────────────────────────────
OS="unknown"
case "$(uname -s)" in
  Darwin) OS="macos" ;;
  Linux)  OS="linux" ;;
  *)      die "Unsupported OS: $(uname -s)" ;;
esac
info "Detected OS: $OS"

# ─── Helper: command exists? ─────────────────────────────────────────────────
cmd_exists() { command -v "$1" &>/dev/null; }

# ─── Helper: prompt yes/no ───────────────────────────────────────────────────
ask() {
  # ask <question> -- returns 0 (yes) or 1 (no)
  # Uses tr for lowercase to stay compatible with bash 3.2 (macOS default)
  local answer answer_lc
  while true; do
    read -r -p "$1 [y/N] " answer
    answer_lc="$(echo "$answer" | tr '[:upper:]' '[:lower:]')"
    case "$answer_lc" in
      y|yes) return 0 ;;
      n|no|"") return 1 ;;
      *) echo "Please enter y or n." ;;
    esac
  done
}

# =============================================================================
# 1. Install Neovim
# =============================================================================
header "Neovim installation"

install_neovim_macos() {
  if cmd_exists brew; then
    info "Installing Neovim via Homebrew..."
    brew install neovim
  else
    die "Homebrew not found. Install it from https://brew.sh then re-run this script."
  fi
}

install_neovim_linux() {
  # Prefer the official AppImage for a recent version; fall back to distro pkg.
  if cmd_exists apt-get; then
    info "Installing Neovim via apt (may not be the latest -- consider the AppImage)..."
    sudo apt-get update -qq
    sudo apt-get install -y neovim
  elif cmd_exists dnf; then
    info "Installing Neovim via dnf..."
    sudo dnf install -y neovim
  elif cmd_exists pacman; then
    info "Installing Neovim via pacman..."
    sudo pacman -Sy --noconfirm neovim
  elif cmd_exists snap; then
    info "Installing Neovim via snap (edge = latest stable)..."
    sudo snap install nvim --classic --channel=latest/stable
  else
    die "No supported package manager found (apt/dnf/pacman/snap). Install Neovim manually from https://neovim.io"
  fi
}

if cmd_exists nvim; then
  NVIM_VERSION="$(nvim --version | head -1)"
  info "Neovim already installed: ${NVIM_VERSION}"

  # Warn if version is below 0.10
  NVIM_MAJOR=$(nvim --version | head -1 | grep -oE '[0-9]+\.[0-9]+' | head -1 | cut -d. -f1)
  NVIM_MINOR=$(nvim --version | head -1 | grep -oE '[0-9]+\.[0-9]+' | head -1 | cut -d. -f2)
  if [[ "$NVIM_MAJOR" -lt 1 ]] && [[ "$NVIM_MINOR" -lt 11 ]]; then
    warn "This config requires Neovim ≥ 0.11. Your version may be too old."
    if ask "Attempt to upgrade Neovim now?"; then
      if [[ "$OS" == "macos" ]]; then install_neovim_macos; else install_neovim_linux; fi
    fi
  fi
else
  info "Neovim not found -- installing..."
  if [[ "$OS" == "macos" ]]; then install_neovim_macos; else install_neovim_linux; fi
  cmd_exists nvim || die "Neovim installation failed. Please install it manually."
  success "Neovim installed: $(nvim --version | head -1)"
fi

# =============================================================================
# 2. Install core build/tool dependencies
# =============================================================================
header "Core dependencies"

install_pkg_macos() {
  local pkg
  local formula
  pkg="$1"
  formula="${2:-$1}"
  if cmd_exists "$pkg"; then
    success "$pkg already installed"
  else
    info "Installing $pkg..."
    brew install "$formula"
  fi
}

install_pkg_linux() {
  local pkg
  local apt_pkg
  pkg="$1"
  apt_pkg="${2:-$1}"
  if cmd_exists "$pkg"; then
    success "$pkg already installed"
  else
    info "Installing $pkg..."
    if cmd_exists apt-get; then
      sudo apt-get install -y "$apt_pkg"
    elif cmd_exists dnf; then
      sudo dnf install -y "$apt_pkg"
    elif cmd_exists pacman; then
      sudo pacman -Sy --noconfirm "$apt_pkg"
    else
      warn "Cannot auto-install $pkg -- please install it manually."
    fi
  fi
}

install_pkg() {
  if [[ "$OS" == "macos" ]]; then
    install_pkg_macos "$@"
  else
    install_pkg_linux "$@"
  fi
}

# git is almost always present; check anyway
install_pkg git git
install_pkg make make
install_pkg rg ripgrep
install_pkg fd fd
install_pkg node nodejs

# Python3
if cmd_exists python3; then
  success "python3 already installed: $(python3 --version)"
else
  install_pkg python3
fi

# Node (for LSP servers that need it)
if cmd_exists node; then
  success "node already installed: $(node --version)"
fi

# =============================================================================
# 3. Back up existing Neovim config, data, state, cache
# =============================================================================
header "Backing up existing Neovim files"

TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP_SUFFIX=".bak.${TIMESTAMP}"
BACKED_UP=()

backup_dir() {
  local dir="$1"
  if [[ -e "$dir" ]] || [[ -L "$dir" ]]; then
    local dest="${dir}${BACKUP_SUFFIX}"
    info "Backing up: $dir  →  $dest"
    mv "$dir" "$dest"
    BACKED_UP+=("$dest")
  fi
}

backup_dir "${HOME}/.config/nvim"
backup_dir "${HOME}/.local/share/nvim"
backup_dir "${HOME}/.local/state/nvim"
backup_dir "${HOME}/.cache/nvim"

if [[ ${#BACKED_UP[@]} -eq 0 ]]; then
  info "No existing Neovim directories found — nothing to back up."
else
  success "Backed up ${#BACKED_UP[@]} director(ies) with suffix ${BACKUP_SUFFIX}"
  echo ""
  info "Backup locations:"
  for d in "${BACKED_UP[@]}"; do
    echo "    $d"
  done
fi

# =============================================================================
# 4. Install the config
# =============================================================================
header "Installing Neovim config"

NVIM_CONFIG_DIR="${HOME}/.config/nvim"

# Ensure ~/.config exists
mkdir -p "${HOME}/.config"

if [[ "$SYMLINK" == true ]]; then
  info "Creating symlink: $NVIM_CONFIG_DIR  →  $NVIM_SOURCE"
  ln -s "$NVIM_SOURCE" "$NVIM_CONFIG_DIR"
  success "Symlink created. Changes in the repo will be reflected immediately."
else
  info "Copying config: $NVIM_SOURCE  →  $NVIM_CONFIG_DIR"
  cp -r "$NVIM_SOURCE" "$NVIM_CONFIG_DIR"
  success "Config copied to $NVIM_CONFIG_DIR"
fi

# =============================================================================
# 5. Optional: DevOps tooling
# =============================================================================
header "Optional DevOps tools"
echo ""
echo "  The following tools are used by LSPs, linters, and terminal integrations."
echo "  Skip any you have already installed or don't need."
echo ""

install_devops_tool() {
  local cmd
  local pkg
  local desc
  cmd="$1"
  pkg="${2:-$1}"
  desc="${3:-}"
  if cmd_exists "$cmd"; then
    success "$cmd already installed — skipping"
    return
  fi
  if ask "  Install ${BOLD}$cmd${RESET} ($desc)?"; then
    if [[ "$OS" == "macos" ]]; then
      brew install "$pkg"
    else
      install_pkg_linux "$cmd" "$pkg"
    fi
  fi
}

install_devops_tool "go"        "go"         "Go language runtime (gopls)"
install_devops_tool "terraform" "terraform"  "Terraform IaC CLI + LSP"
install_devops_tool "ansible"   "ansible"    "Ansible automation CLI + LSP"
install_devops_tool "helm"      "helm"       "Helm Kubernetes package manager"
install_devops_tool "kubectl"   "kubectl"    "Kubernetes CLI"
install_devops_tool "k9s"       "k9s"        "Kubernetes TUI (terminal integration)"
install_devops_tool "lazygit"   "lazygit"    "Git TUI (terminal integration)"
install_devops_tool "hadolint"  "hadolint"   "Dockerfile linter"
install_devops_tool "tflint"    "tflint"     "Terraform linter"

# pip-based Python DevOps tools
# Check by CLI command name; pip package for ansiblelint is "ansible-lint"
PIP_TOOLS=()
PIP_PKGS=()

_check_pip_tool() {
  local cli="$1"
  local pkg="$2"
  if ! cmd_exists "$cli"; then
    PIP_TOOLS+=("$cli")
    PIP_PKGS+=("$pkg")
  fi
}

_check_pip_tool black       black
_check_pip_tool isort       isort
_check_pip_tool flake8      flake8
_check_pip_tool yamllint    yamllint
_check_pip_tool ansible-lint ansible-lint

if [[ ${#PIP_PKGS[@]} -gt 0 ]]; then
  echo ""
  info "The following Python tools are not installed: ${PIP_TOOLS[*]}"
  if ask "  Install them via pip3 (${PIP_PKGS[*]})?"; then
    pip3 install --user "${PIP_PKGS[@]}"
    success "Python tools installed"
  fi
else
  success "All Python DevOps tools already installed"
fi

# =============================================================================
# 6. Optional: Ollama (local AI — fully private, no data leaves your machine)
# =============================================================================
header "AI assistant (Ollama + codestral)"
echo ""
echo "  CodeCompanion is included in this config and uses Ollama for a fully"
echo "  local AI assistant. Your code never leaves your machine."
echo ""
echo "  Recommended model: codestral (Mistral AI, 22B)"
echo "    - Best for Terraform / HCL, Ansible, Bash, Go, Python"
echo "    - Requires ~14 GB RAM during inference"
echo "    - If you have ≤ 16 GB RAM consider: llama3.1:8b (~5 GB)"
echo ""

install_ollama_macos() {
  if cmd_exists brew; then
    info "Installing Ollama via Homebrew..."
    brew install ollama
  else
    info "Installing Ollama via official installer..."
    curl -fsSL https://ollama.com/install.sh | sh
  fi
}

install_ollama_linux() {
  info "Installing Ollama via official installer..."
  curl -fsSL https://ollama.com/install.sh | sh
}

if cmd_exists ollama; then
  success "Ollama already installed: $(ollama --version 2>/dev/null || echo 'version unknown')"
else
  if ask "  Install Ollama?"; then
    if [[ "$OS" == "macos" ]]; then install_ollama_macos; else install_ollama_linux; fi
    cmd_exists ollama && success "Ollama installed" || warn "Ollama installation may have failed — install manually from https://ollama.com"
  fi
fi

if cmd_exists ollama; then
  echo ""
  # Offer model selection if no code models are already pulled
  HAVE_CODESTRAL=false
  HAVE_LLAMA=false
  if ollama list 2>/dev/null | grep -q "codestral"; then HAVE_CODESTRAL=true; fi
  if ollama list 2>/dev/null | grep -qE "llama3"; then HAVE_LLAMA=true; fi

  if [[ "$HAVE_CODESTRAL" == true ]]; then
    success "codestral model already present — no download needed"
  else
    echo "  Choose a model to pull (you can change this later with: ollama pull <model>):"
    echo "    1) codestral     — best quality, ~14 GB download (recommended for ≥ 32 GB RAM)"
    echo "    2) llama3.1:8b   — good quality, ~5 GB download  (recommended for ≤ 16 GB RAM)"
    echo "    3) Skip          — I'll pull a model manually later"
    echo ""
    MODEL_CHOICE=""
    while true; do
      read -r -p "  Your choice [1/2/3]: " MODEL_CHOICE
      case "$MODEL_CHOICE" in
        1) MODEL_TO_PULL="codestral";  break ;;
        2) MODEL_TO_PULL="llama3.1:8b"; break ;;
        3) MODEL_TO_PULL="";           break ;;
        *) echo "  Please enter 1, 2, or 3." ;;
      esac
    done

    if [[ -n "$MODEL_TO_PULL" ]]; then
      info "Starting Ollama daemon for model pull..."
      # Start ollama serve in background if not already running
      if ! curl -s --max-time 2 http://localhost:11434/api/tags &>/dev/null; then
        ollama serve &>/tmp/ollama-serve.log &
        OLLAMA_PID=$!
        sleep 3
      fi
      info "Pulling ${MODEL_TO_PULL} (this may take a while)..."
      ollama pull "$MODEL_TO_PULL" && success "${MODEL_TO_PULL} model ready" || warn "Pull failed — run manually: ollama pull ${MODEL_TO_PULL}"
    else
      info "Skipped. Pull a model later with: ollama pull codestral"
    fi
  fi

  echo ""
  info "To start Ollama automatically at login:"
  if [[ "$OS" == "macos" ]]; then
    echo "    brew services start ollama"
  else
    echo "    sudo systemctl enable --now ollama"
  fi
fi

# =============================================================================
# 7. First launch
# =============================================================================
header "Ready!"
echo ""
echo -e "  Config installed at: ${BOLD}${NVIM_CONFIG_DIR}${RESET}"
if [[ ${#BACKED_UP[@]} -gt 0 ]]; then
  echo -e "  Old config backed up with suffix: ${BOLD}${BACKUP_SUFFIX}${RESET}"
fi
echo ""
echo "  Next steps:"
echo "    1. Open Neovim:    nvim"
echo "       lazy.nvim will self-bootstrap and install all plugins (~1-2 min)."
echo "    2. Mason auto-installs LSP servers, linters, and formatters."
echo "       Watch progress with :Mason or :Lazy"
echo "    3. Run :checkhealth to confirm everything is working."
if cmd_exists ollama; then
  echo "    4. Start Ollama:   ollama serve  (or brew services start ollama)"
  echo "       Then in Neovim: <leader>ac to open the AI chat."
fi
echo ""

if ask "Open Neovim now?"; then
  exec nvim
fi
