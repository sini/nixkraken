# This test checks that GitKraken is correctly installed and can be launched.
# It also tests that application and profile-specific configuration files gets written to home directory.

_:

{
  home-manager.users.root = {
    programs = {
      git = {
        enable = true;
        userEmail = "somebody@example.com";
        userName = "Somebody";
      };

      nixkraken = {
        enable = true;
        acceptEULA = true;
        skipTutorial = true;
        defaultProfile.name = "NixKraken rocks";
      };
    };
  };
}
