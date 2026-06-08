{
  config,
  lib,
  pkgs,
  username,
  ...
}:

{
  options.myModules.postgres-cli.enable = lib.mkEnableOption "Postgres command-line tools: pgcli (interactive REPL) and the postgresql package (for psql, pg_dump, etc.)";

  config = lib.mkIf config.myModules.postgres-cli.enable {
    home-manager.users.${username} = {
      home.packages = with pkgs; [
        pgcli
        postgresql
      ];
    };
  };
}
