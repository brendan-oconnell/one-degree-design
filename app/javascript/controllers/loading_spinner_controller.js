import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["main", "spinner", "form"]

  connect() {
    // console.log(this.element)
    // console.log(this.spinnerTarget)
    // console.log(this.formTarget)
  }

  spin(event) {
    // make a validation for the input field?
    // event.preventDefault()
    // launch the creation

    this.mainTarget.classList.add("blur")
    this.spinnerTarget.classList.add("spinner")
    // make a validation for the input field?
    // sleep(3000)
  }
}

function sleep(delay) {
  var start = new Date().getTime();
  while (new Date().getTime() < start + delay);
}
