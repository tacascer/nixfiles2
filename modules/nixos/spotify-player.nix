{ config, pkgs, ... }:
{
  home-manager.users.${config.custom.homeManager.username} =
    { ... }:
    {
      programs.spotify-player = {
        enable = true;
        package = pkgs.spotify-player.override {
          withDaemon = true;
          withStreaming = true;
          withMediaControl = true;
          withNotify = true;
          withImage = true;
          withSixel = true;
        };
        settings = {
          enable_media_control = true;
          enable_streaming = "Always";
          enable_audio_visualization = true;
          enable_notify = true;
          notify_streaming_only = true;
          enable_cover_image_cache = true;
          border_type = "Rounded";
          progress_bar_type = "Line";
          enable_mouse_scroll_volume = true;
          seek_duration_secs = 5;
          playback_metadata_fields = [
            "repeat"
            "shuffle"
            "volume"
            "device"
          ];
          device = {
            audio_cache = true;
            normalization = true;
          };
        };
      };
    };
}
