import Turbolinks from "turbolinks";
import SmoothScroll from "smooth-scroll";
import "phoenix_html";
import "./turbolinksHistory";
import "./priceSlider";
import "./persistScroll";
import "./presaleForm";
import "./lightbox";
import "whatwg-fetch";
import '../css/main.scss';

const active = "is-active";
document.addEventListener("turbolinks:load", function () {
  const headerNavs = document.querySelector(".main-header-navs");
  const navsToggle = document.querySelector(".main-header-navs-toggle")
  const navsClose = document.querySelector(".main-header-navs-close");

  navsToggle && headerNavs && navsToggle.addEventListener("click", function () {
    headerNavs.classList.add(active);
  });

  navsClose && headerNavs && navsClose.addEventListener("click", function () {
    headerNavs.classList.remove(active);
  });
});

document.addEventListener("DOMContentLoaded", function () {
  new SmoothScroll('a[href^="#"]');
})

Turbolinks.start();

Turbolinks.BrowserAdapter.prototype.showProgressBarAfterDelay = function() {
  return this.progressBarTimeout = setTimeout(this.showProgressBar, 0);
};