import noUiSlider from 'nouislider';
import wNumb from 'wnumb';

document.addEventListener("turbolinks:load", function () {
  const $value = document.getElementById("pricingSliderValue");
  const pricingSlider = document.getElementById("pricingSlider");
  const $checkbox = document.getElementById("pricingPlan");

  const prices = {
    regular: [49, 99, 149, 249, 349],
    annual: [33, 66, 99, 179, 229]
  };

  if ($checkbox) {
    $checkbox.onchange = function(e) {
      const annual = !document.querySelector("#pricingPlan:checked");
      const packagePrices = document.querySelectorAll(".js-package-price");
  
      for (var i = 0; i < packagePrices.length; i++) {
        packagePrices[i].innerText = "$" + prices[annual ? "annual" : "regular"][i] + "/month";
      }
    };
  }

  if ($value && pricingSlider) {
    noUiSlider.create(pricingSlider, {
      start: 100000,
      connect: [true, false],
      range: {
        min: 1000,
        "15%": 7500,
        "30%": 20000,
        "45%": 100000,
        "60%": 300000,
        "75%": 500000,
        max: 550000
      },
      format: wNumb({
        decimals: 0,
        thousand: ","
      })
    });

    function setPageviews() {
      const value = pricingSlider.noUiSlider.get();
      $value.innerHTML = value;

      const intValue = parseInt(value.replace(",", ""), 10);
      let breakpoint;

      if (intValue <= 7499) breakpoint = 75;
      if (intValue === 1000) breakpoint = 1;
      if (intValue >= 7500) breakpoint = 20;
      if (intValue >= 20000) breakpoint = 100;
      if (intValue >= 100000) breakpoint = 300;
      if (intValue >= 300000) breakpoint = 500;
      if (intValue >= 500000) breakpoint = 550;
  
      document.getElementById("priceSliderValuePlus").style.display = "none";

      if (intValue === 550000) {
        document.getElementById("priceSliderValuePlus").style.display = "inline";
      }

      var pricingPackages = document.querySelectorAll(
        ".pricing-packages-table-content-item"
      );
      for (var i = 0; i < pricingPackages.length; i++) {
        pricingPackages[i].classList.remove("active");
      }

      document.getElementById("pricingValue" + breakpoint).classList.add("active");
    }

    pricingSlider.noUiSlider.on("slide", setPageviews);

    document.addEventListener("turbolinks:before-cache", function () {

      pricingSlider.innerHTML = '';

    }, { once: true });
  }
});