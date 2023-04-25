const fade = ($el, type, ms) => {
  let isIn = type === 'in',
    opacity = isIn ? 0 : 1,
    interval = 15,
    duration = ms,
    gap = interval / duration;

  if (isIn) {
    $el.style.display = 'block';
    $el.style.opacity = opacity;
  }
   function func() {
    opacity = isIn ? opacity + gap : opacity - gap;
    $el.style.opacity = opacity;

    if(opacity <= 0) $el.style.display = 'none'
    if(opacity <= 0 || opacity >= 1) window.clearInterval(fading);
  }
   let fading = window.setInterval(func, interval);
}

document.addEventListener("turbolinks:load", function () {
  const $lightbox = document.querySelector(".lightbox");
  const $dimmer = document.querySelector(".dimmer");
  const showSubscribeBoxElements = document.querySelectorAll('[data-show-subscribe-popup]');
  
  const hideLightbox = () => {
    fade($lightbox, 'out', 75);
    fade($dimmer, 'out', 75);
  }

  const showLightbox = () => {
    fade($lightbox, 'in', 100);
    fade($dimmer, 'in', 75);
  }

  [].forEach.call(showSubscribeBoxElements, function (el) {
    el.onclick = showLightbox;
  });

  document.onkeydown = function(e) {
    e = e || window.event;
    if (e.keyCode == 27) hideLightbox()
  };
  document.querySelector(".lightbox-close").onclick = hideLightbox;
  document.querySelector(".dimmer").onclick = hideLightbox;  
});
