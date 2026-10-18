{ ... }:
{
  networking.networkmanager.ensureProfiles = {
    # Secrets live OUTSIDE the Nix store (the store is world-readable).
    environmentFiles = [ "/etc/nm-secrets/eduroam.env" ];

    profiles.eduroam = {
      connection = {
        id = "eduroam";
        type = "wifi";
        autoconnect = "true";
      };

      wifi = {
        mode = "infrastructure";
        ssid = "eduroam";
      };

      wifi-security = {
        key-mgmt = "wpa-eap";
      };

      "802-1x" = {
        eap = "peap;";
        phase2-auth = "mschapv2";

        # substituted from the env file at activation
        identity = "$EDUROAM_USER";
        password = "$EDUROAM_PASS";

        # Verify the server (this is what protects you from fake APs)
        ca-cert = "/etc/ssl/eduroam/unica-ca.pem";
        altsubject-matches = "DNS:ise-po1.unica.it;DNS:ise-po2.unica.it;";

        # Only if the CAT profile defines one:
        # anonymous-identity = "anonymous@unica.it";
      };

      ipv4.method = "auto";
      ipv6 = {
        method = "auto";
        addr-gen-mode = "default";
      };
    };
  };

  # Install the CA where the profile expects it
  environment.etc."ssl/eduroam/unica-ca.pem".source = ./unica-ca.pem;
}
