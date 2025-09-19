substitutes:= '--substitute-urls=https://mirror.yandex.ru/mirrors/guix\ http://ci.guix.trop.in\ https://substitutes.nonguix.org'
cfg:= 'rc/main.scm'
chans:= 'chans.scm'
profile:= 'trg/profile'
guix:= if path_exists(profile) == 'true' { profile / 'bin/guix' } else { 'guix' }
sudo:= 'sudo --preserve-env=GUIX_PROFILE,FIRST,HOSTNAME,FIRST,GUILE_LOAD_PATH,PATH TRG=sys'

alias h := homeCfg
alias s := sysCfg
alias hb := homeBld
alias sb := sysBld
alias g := guix
dwim: homeCfg sysCfg

do *_:
    {{_}}
guix *_='describe': (do guix _)
cfg *_: (guix _ cfg substitutes)
chans *_: (guix _ '-C' chans substitutes)
home *_: (cfg 'home' _)
sys *_: (cfg 'system' _)
homeCfg *_: (home 'reconfigure' _)
sysCfg *_: (do sudo 'just sys reconfigure' _)
homeBld *_: (home 'build' _)
sysBld *_: (do sudo 'just sys build' _)
pul1 *_: (chans 'pull' _)
pull *_: (pul1 '-p' profile _)

bump: && pul1 pull (guix 'describe -f channels >' chans)
    ./bump.scm {{chans}}

vm: (sys 'vm')

init: (do sudo 'just sys init /mnt')

mount:
    sudo mount -L main -o subvolid=5 /mnt
    sudo mount -L efi /mnt/boot/efi

initDeb:
    {{sudo}} TRG='sys' {{guix}} system init oldcfg.scm /mnt {{substitutes}}

disk:='test.qcow2'

setupQemu:
    touch /tmp/{{disk}} && rm /tmp/{{disk}}
    qemu-img create /tmp/{{disk}} 30G -f qcow2

testInstall: getInstaller setupQemu

installer:='guix-installer.iso'

getInstaller:
    find {{installer}} || echo 'get {{installer}}'

makeInstaller: (guix 'system image -t iso9660 installer.scm' substitutes)

runQemu:
    sudo qemu-system-x86_64 -m 8192 -smp 4 -enable-kvm -drive file=/tmp/{{disk}} -cdrom {{installer}} -nic user -cpu host -vga virtio

repl:
    guile -c '((@ (ares server) run-nrepl-server))'&

 
       
mkswap $f='/swap/swapfile':
    mkdir /swap
    touch {{f}}
    fallocate -l 512M {{f}}
    mkswap {{f}}
    chmod 0660 {{f}}

nonguix:
	curl https://substitutes.nonguix.org/signing-key.pub > /tmp/nonguix.key
	cat /tmp/nonguix.key | sudo guix archive --authorize
	rm /tmp/nonguix.key
