# keep-wg-alive

Wireguard connection would disconnect after a long sleep. And this repo will help you check and reconnect the wg interfaces automaticly. 

## Usage
### Systemd
```bash
sudo cp keep-wg-alive.sh /usr/bin
sudo cp ./systemd/*.{service,timer} /usr/lib/systemd/system
sudo systemctl enable --now keep-wg-alive.timer
```
