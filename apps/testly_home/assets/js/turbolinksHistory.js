// taken from https://github.com/samvera/hyrax/pull/3007
window.addEventListener("popstate", function(event) {
  this.turbolinks_location = Turbolinks.Location.wrap(window.location);
  if (
    Turbolinks.controller.location.requestURL ===
    this.turbolinks_location.requestURL
  ) {
    return;
  }
  if (event.state != null ? event.state.turbolinks : undefined) {
    return;
  }
  if (
    (this.window_turbolinks =
      window.history.state != null
        ? window.history.state.turbolinks
        : undefined)
  ) {
    return Turbolinks.controller.historyPoppedToLocationWithRestorationIdentifier(
      this.turbolinks_location,
      this.window_turbolinks.restorationIdentifier
    );
  } else {
    return Turbolinks.controller.historyPoppedToLocationWithRestorationIdentifier(
      this.turbolinks_location,
      Turbolinks.uuid()
    );
  }
});
