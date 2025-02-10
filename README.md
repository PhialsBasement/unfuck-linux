# Unfuck Linux

Make Linux actually usable as a desktop OS by removing unnecessary security theater and annoying restrictions.

## What is this?

A collection of scripts to remove common Linux annoyances like:
- Constant password prompts
- KWallet nagging
- File permission hassles
- Other pointless security theater

## Warning

This repo explicitly prioritizes usability over "security best practices". If you're the type to lecture people about running everything in a VM, this isn't for you.

## Scripts

### security/
- `remove-kwallet.sh` - Disable KWallet and its password prompts
- `passwordless-sudo.sh` - Enable passwordless sudo after initial login
- `auto-exec.sh` - Make files executable by default

### convenience/
- `sane-defaults.sh` - Set up reasonable system defaults
- `dev-tools.sh` - Configure development environment without the BS

### system/
- `unfuck-all.sh` - Run all scripts to fully unfuck your system

## Usage

1. Clone the repo:
```bash
git clone https://github.com/PhialsBasement/unfuck-linux.git
cd unfuck-linux
```

2. Make scripts executable:
```bash
chmod +x scripts/*/*.sh
```

3. Run individual scripts or unfuck everything:
```bash
# Remove individual annoyances
./scripts/security/remove-kwallet.sh

# Or unfuck everything at once
./scripts/system/unfuck-all.sh
```

## Contributing

Found another annoying "security feature" that needs removing? PRs welcome!

## Disclaimer

This project intentionally removes security measures that some consider essential. If you're worried about the NSA spying on your calculator app, this isn't for you.

## License

MIT - Do whatever you want, just don't blame us when your tin-foil-hat-wearing friends complain.