lib:

# Function to generate a fake UUID string from a SHA512 hash of a seed string
# Generates a map with the first 32 characters of the hash split in groups of
# different size and concatenate them in a string, each group separated by dashes
# Note: using the same seed will always generate the same UUID
seed:
lib.concatStringsSep "-" (
  builtins.foldl'
    (
      acc: elem:
      acc
      ++ lib.singleton (
        lib.substring (lib.elemAt elem 0) (lib.elemAt elem 1) (builtins.hashString "sha512" seed)
      )
    )
    [ ]
    [
      [
        0
        8
      ]
      [
        8
        4
      ]
      [
        12
        4
      ]
      [
        16
        4
      ]
      [
        20
        12
      ]
    ]
)
