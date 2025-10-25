# This test checks that EULA acceptance is working as intended.
# It also ensures that the tutorial can be skipped and that user info can be defined.

{
  home-manager.users.root.programs.nixkraken = {
    acceptEULA = true;

    # In order to check for EULA acceptance, we have to skip tutorial
    skipTutorial = true;

    # Because we skip tutorial, we have to set user info
    user = {
      email = "somebody@example.com";
      name = "Somebody";
    };
  };
}
