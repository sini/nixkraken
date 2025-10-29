[decrypt-pkg-source]: https://github.com/nicolas-goudry/nixkraken/blob/main/pkgs/decrypt/script.py
[doc-app-extractor]: ../gitkraken/utils/app-extractor.md
[doc-login]: ./login.md
[encrypt-pkg-source]: https://github.com/nicolas-goudry/nixkraken/blob/main/pkgs/encrypt/script.py
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

## How to Run

```sh
# Using the raw Bash script
$ ./pkgs/encrypt/script.sh
$ ./pkgs/decrypt/script.sh
```

```sh
# ...or using new Nix commands
$ nix run '.#encrypt'
$ nix run '.#decrypt'
```

```sh
# ...or using classic Nix commands
$ nix-build ./pkgs -A encrypt && ./result/bin/gk-encrypt
$ nix-build ./pkgs -A decrypt && ./result/bin/gk-decrypt
```

```sh
# ...or from the Nix development shell (nix develop / nix-shell)
$ gk-encrypt
$ gk-decrypt
```

For further details, refer to the actual scripts code:

- [`gk-decrypt` source][decrypt-pkg-source]
- [`gk-encrypt` source][encrypt-pkg-source]

## Encryption / Decryption Methods

The encryption and decryption methods are adapted from [GitKraken][gitkraken]'s original code, reimplemented using Python modules.

The reference implementation below is stripped from irrelevant code, prettified from `main.bundle.js` and enhanced with comments.

::: tip TL;DR

The secrets are JSON data encrypted with the `appId` as the passphrase.

:::

```js
class Ae {
  data = {};

  /**
   * Represents secure data.
   * @param {string} re - Path to secret file
   * @param {string} ne - Secret file password (appId)
   * @param {string} se - Cryptography algorithm
   */
  constructor(re, ne, se) {
    (this.secPath = re),
      (this.password = ne),
      (this.algorithm = se),
      (this.cryptoHack = le.default), // This is Node's crypto module
      this.loadData();
  }

  /**
   * Loads data from a secret file (decryption).
   */
  async loadData() {
    try {
      // Create a decipher with the password key
      const re = this.cryptoHack.createDecipher(
          this.algorithm,
          this.password,
        ),
        // Read the entire secret file as a Buffer
        ne = await pe.promises.readFile(this.secPath),
        // Decrypt data, verify authentication tag and convert decrypted Buffer to string
        se = Buffer.concat([re.update(ne), re.final()]).toString();
      // Parse decrypted data as JSON
      this.data = JSON.parse(se);
    } catch {
      this.data = {};
    }
  }

  /**
   * Saves data into a secret file (encryption).
   */
  async saveData() {
    try {
      // Create a cipher with the password key
      const re = this.cryptoHack.createCipher(
          this.algorithm,
          this.password,
        ),
        // Encrypt JSON data as string with authentication tag into a Buffer
        ne = Buffer.concat([
          re.update(Buffer.from(JSON.stringify(this.data))),
          re.final(),
        ]);
      // Replace entire content of secret file with encrypted data
      await pe.promises.writeFile(this.secPath, ne);
    } catch {}
  }
}
```

<center>

_[Extracted][doc-app-extractor] from version GitKraken 11.5.0._

</center>
