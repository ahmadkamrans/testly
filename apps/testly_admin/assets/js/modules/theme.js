/*
 * To make sure the charts receive the right colors (window.theme.X) we wait
 * before enabling document.ready (jQuery) until the right computed styles
 * are available.
 */

const style = getComputedStyle(document.body);
const themeInterval = setInterval(checkTheme, 25);

// Hold jQuery ready
$.holdReady(true);

function checkTheme(){
  // Check if the primary color is available, so we know for sure the
  // stylesheet is loaded properly
  if(style.getPropertyValue('--primary').trim() !== ""){
    clearInterval(themeInterval);
    setTheme();

    // Release jQuery ready
    $.holdReady(false);
  }
}

function setTheme(){
  const theme = {
    primary: style.getPropertyValue('--primary').trim(),
    secondary: style.getPropertyValue('--secondary').trim(),
    tertiary: style.getPropertyValue('--tertiary').trim(),
    success: style.getPropertyValue('--success').trim(),
    info: style.getPropertyValue('--info').trim(),
    warning: style.getPropertyValue('--warning').trim(),
    danger: style.getPropertyValue('--danger').trim()
  };

  window.theme = theme;
}
