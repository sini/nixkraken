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
      };
    };
  };
}
