# keep-wg-alive

Wireguard connection would disconnect after a long sleep. And this repo will help you check and reconnect the wg interfaces automaticly. 

## Installation

### Archlinux / Manjaro

```bash
git clone https://aur.archlinux.org/keep-wg-alive-git.git
cd keep-wg-alive-git
makepkg -si
```

### Universal
```bash
sudo cp keep-wg-alive.sh /usr/bin
sudo cp ./systemd/*.{service,timer} /usr/lib/systemd/system
```

## Usage
### Systemd
```bash
sudo systemctl enable --now keep-wg-alive.timer
```
