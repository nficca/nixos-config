{ helpers, ... }: let imports = helpers.listModules ./.; in { inherit imports; }
