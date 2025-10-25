{
  home-manager.users.root = {
    programs = {
      git = {
        enable = true;
        userEmail = "somebody@example.com";
        userName = "Somebody";
      };

      nixkraken = {
        acceptEULA = true;
        skipTutorial = true;
      };
    };
  };
}
