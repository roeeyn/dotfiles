# Signing commits with GPG

## Create a new key
```shell
# Every option with default
gpg --full-generate-key

# Show the gpg keys
gpg --list-secret-keys --keyid-format=long
```

## Get the GPG key id (e.g. 3AA5C34371567BD2)
```shell
$ gpg --list-secret-keys --keyid-format=long
/Users/hubot/.gnupg/secring.gpg
------------------------------------
sec   4096R/3AA5C34371567BD2 2016-03-10 [expires: 2017-03-10]
uid                          Hubot
ssb   4096R/42B317FD4BA89E7A 2016-03-10
```

## Add the key to GitHub
```shell
# Prints the key
gpg --armor --export 3AA5C34371567BD2
```

## Enables the commit signing by default
```shell
git config --global commit.gpgsign true
```
