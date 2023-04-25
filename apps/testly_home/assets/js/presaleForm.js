import { serialize } from 'dom-form-serializer';

const toQueryParams = function(obj) {
  const str = [];
  for (let p in obj)
    if (obj.hasOwnProperty(p)) {
      str.push(encodeURIComponent(p) + "=" + encodeURIComponent(obj[p]));
    }
  return str.join("&");
}

document.addEventListener("turbolinks:load", function () {
  document.querySelector("#presale_form").addEventListener("submit", function(e){
    e.preventDefault();

    this.parentElement.classList.add("submitted")

    const formData = serialize(this);

    fetch(`https://bryxen.activehosted.com/proc.php?${toQueryParams(formData)}`, {method: 'get', mode: 'no-cors'});
  });
});
