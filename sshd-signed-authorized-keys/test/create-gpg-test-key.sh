# launch gpg-agent, else next step fails
gpgconf --homedir `pwd`/gnupg --launch gpg-agent

# generate key. I walked trough the interactive menus, using defaults.
gpg --homedir `pwd`/gnupg --expert --full-generate-key

# export public keyring
gpg --homedir `pwd`/gnupg --export test@example.com > test@example.com.gpg

# create first test signature
gpg --homedir `pwd`/gnupg --detach-sign user/.ssh/authorized_keys

# create second test signature
cat id_ed25519-2.pub >> user/.ssh/authorized_keys
gpg --homedir `pwd`/gnupg --detach-sign user/.ssh/authorized_keys
cp authorized_keys.sig authorized_keys-2.sig

