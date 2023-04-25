// Taken from https://stackoverflow.com/questions/39679154/how-to-persist-scrolls-with-turbolinks
const persistScrollDataAttribute = 'turbolinks-persist-scroll';
let scrollPosition = null;

const turbolinksPersistScroll = () => {
  if (scrollPosition) {
    window.scrollTo(0, scrollPosition);
    scrollPosition = null;
  }


  const elements = document.querySelectorAll(`[data-${persistScrollDataAttribute}="true"]`)
  for (let i = 0; i < elements.length; i++) {
    elements[i].addEventListener('click', () => {
      document.addEventListener("turbolinks:before-render", () => {
        scrollPosition = window.scrollY;
      }, {once: true})
    })
  }
}

document.addEventListener('turbolinks:load', turbolinksPersistScroll);
document.addEventListener('turbolinks:render', turbolinksPersistScroll);
