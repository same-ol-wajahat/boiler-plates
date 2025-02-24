# WireGuard installation and configuration - on Ubuntu

## Prerequisites

- Linux Server running Ubuntu 20.04 LTS or newer
- This will work on the systems using Systemd

*For installing WireGuard on other Linux distriubtions or different versions than Ubuntu 20.04 LTS, follow the [official installation instructions](https://www.wireguard.com/install/).*

## Installation and Configuration

### Install WireGuard

To install WireGuard on Ubuntu 20.04 LTS we need to execute the following commands on the Server and Client.

```bash
sudo apt install wireguard
```

### Create a private and public key on Server & Client

Before we can establish a secure tunnel with WireGuard we need to create a private and public key on both, Server and Client first. WireGuard comes with a simple tool that can easily generate these keys. Execute this on the Server and Client.

```bash
wg genkey | tee privatekey | wg pubkey > publickey
```

Be aware, you ***MUST NOT SHARE*** the private key with anyone! Make sure to store it in a secure way on both devices.

### Configure the Server

Now you can configure the server, just add a new file called `/etc/wireguard/wg0.conf`. Insert the following configuration lines and replace the `<server-private-key>` placeholder with the previously generated private key.

You need to insert a private IP address for the `<server-ip-address>` that doesn't interfere with another subnet. Next, replace the `<public-interface>` with your interface the server should listen on for incoming connections. 

```conf
[Interface]
PrivateKey=<server-private-key>
Address=<server-ip-address>/<subnet>
SaveConfig=true
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o <public-interface> -j MASQUERADE;
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o <public-interface> -j MASQUERADE;
ListenPort = 51820
```

You need to configure your server to forward traffic, in Ubuntu you can check whether your Server is configured to to forward tarffic or not just by running the following command:

```bash
cat /proc/sys/net/ipv4/ip_forward
```
if you see `1` in the output then you are good to go but if you see a `0` in the output then you need to modify this setting on the server. You can easily fiddle with this setting using the commands below:

```bash
sysctl -w net.ipv4.ip_forward=0
OR
sysctl -w net.ipv4.ip_forward=1
```

```bash
echo 0 > /proc/sys/net/ipv4/ip_forward
OR
echo 1 > /proc/sys/net/ipv4/ip_forward
```

In order to make sure that this setting survives reboot, you need to edit `/etc/sysctl.conf` file:

```bash
sudo vim /etc/sysctl.conf
```

Add on of the two following lines:

```conf
net.ipv4.ip_forward = 0
OR
net.ipv4.ip_forward = 1
```

After editing the file you can run the following command to make sure that changes take effect right away:

```bash
sysctl -p
```

You can also verify the configuration changes by having a look at the `IPTABLES` rules
```bash
iptables -n -L -v
```

### Configure the Client

Now, we need to configure the client. Create a new file called `/etc/wireguard/wg0.conf`. Insert the following configuration lines and replace the `<client-private-key>` placeholder with the previously generated private key.

You need to insert a private IP address for the `<client-ip-address>` in the same subnet like the server's IP address. Next, replace the `<server-public-key>` with the generated servers public key. And also replace `<server-public-ip-address>` with the IP address where the server listens for incoming connections.

*Note that if you set the AllowedIPs to `0.0.0.0/0` the client will route ALL traffic through the VPN tunnel. That means, even if the client will access the public internet, this will break out on the server-side. If you don't want route all traffic through the tunnel, you need to replace this with the target IP addresses or networks.*

```conf
[Interface]
PrivateKey = <client-private-key>
Address = <client-ip-address>/<subnet>
SaveConfig = true

[Peer]
PublicKey = <server-public-key>
Endpoint = <server-public-ip-address>:51820
AllowedIPs = 0.0.0.0/0
```

Once you have created the configuration file, you need to enable the wg0 interface with the following command.

```bash
wg-quick up wg0
```

You can check the status of the connection with this command.

```bash
wg
```

### Add Client to the Server

Next, you need to add the client to the server configuration file. Otherwise, the tunnel will not be established. Replace the `<client-public-key>` with the clients generated public key and the `<client-ip-address>` with the client's IP address on the wg0 interface.

```bash
wg set wg0 peer <client-public-key> allowed-ips <client-ip-address>/32
```

Now you can enable the wg0 interface on the server.

```bash
wg-quick up wg0
```

```bash
wg
```