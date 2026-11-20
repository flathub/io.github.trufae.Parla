# Parla for Flathub

Official Parla Flathub package.

## CLI

With this flatpak you can also run `parla-cli`:

```sh
alias parla-cli='flatpak run --command=parla-cli io.github.trufae.Parla'
```

Or create a wrapper script if intended to be used via AI by running:
```sh
cat << EOF | sudo tee /usr/local/bin/parla-cli
#!/bin/sh
exec flatpak run --command=parla-cli io.github.trufae.Parla "\$@"
EOF
sudo chmod a+rx /usr/local/bin/parla-cli
```
