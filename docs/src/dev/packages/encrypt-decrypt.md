[decrypt-pkg-source]: https://github.com/nicolas-goudry/nixkraken/blob/main/pkgs/decrypt/script.sh
[doc-login]: ./login.md
[encrypt-pkg-source]: https://github.com/nicolas-goudry/nixkraken/blob/main/pkgs/encrypt/script.sh
[gitkraken]: https://www.gitkraken.com/git-client

# `gk-encrypt` and `gk-decrypt`

These packages are used to encrypt and decrypt [GitKraken][gitkraken]'s `secFile`s, which contain sensitive data such as access tokens.

They are primarily intended for use by the [`gk-login`][doc-login] package, but can also be used independently.

Although their execution is considered safe (since they only read the `secFile`s and output results to stdout), they are provided as-is, with no warranty.

## Usage

### `gk-encrypt`

```txt
@GK_ENCRYPT_USAGE@
```

### `gk-decrypt`

```txt
@GK_DECRYPT_USAGE@
```

## How to run

```bash
# Using the raw Bash script
./pkgs/encrypt/script.sh
./pkgs/decrypt/script.sh
```

```bash
# ...or using new Nix commands
nix run '.#encrypt'
nix run '.#decrypt'
```

```bash
# ...or using classic Nix commands
nix-build ./pkgs -A encrypt && ./result/bin/gk-encrypt
nix-build ./pkgs -A decrypt && ./result/bin/gk-decrypt
```

```bash
# ...or from the Nix development shell (nix develop / nix-shell)
gk-encrypt
gk-decrypt
```

The scripts are extensively documented through comments in the source files themselves:

- [`gk-decrypt` source][decrypt-pkg-source]
- [`gk-encrypt` source][encrypt-pkg-source]

## Encryption / Decryption methods

The encryption and decryption methods are adapted from [GitKraken][gitkraken]'s original code, reimplemented using Unix tools. The reference implementation below is prettified from `main.bundle.js` with comments manually added:

```js
// Arguments:
// - I: path to secFile
// - re: appId
// - ne: input encoding
//
// External variables
// - le: path module
// - ae: crypto module
// - ce: logging library
// - se: seems to be a wrapper around fs module and fs-extra library
I.exports = (I, re, ne) => {
  const pe = re || "",
    Ee = ne || "aes256",
    ge = le.resolve(I),
    doCrypto = (I, re) => {
      ce("doing crypto: %s", re ? "decrypting" : "encrypting");
      const ne = re ? "binary" : "utf8",
        se = re ? ae.createDecipher(Ee, pe) : ae.createCipher(Ee, pe),
        le = [new Buffer(se.update(I, ne)), new Buffer(se.final())],
        ge = Buffer.concat(le);
      return ce("done doing crypto"), ge;
    };
  return {
    load: () => (
      ce("attempting to load"),
      Promise.resolve()
        .then(() => se.readFileAsync(ge))
        .then((I) => doCrypto(I, !0).toString())
        .then((I) => JSON.parse(I))
        .catch((I) => (ce("failed to load:"), ce(I), {}))
    ),
    save: (I) => (
      ce("attempting to save"),
      Promise.resolve()
        .then(() => se.ensureFileAsync(ge))
        .then(() => JSON.stringify(I, null, 2))
        .then((I) => doCrypto(I, !1))
        .then((I) => se.writeFileAsync(ge, I))
        .catch((I) => {
          throw (ce("failed to save:"), ce(I), I);
        })
    ),
  };
};
```

In summary, the secrets are JSON data encrypted with the `appId` as the passphrase.
