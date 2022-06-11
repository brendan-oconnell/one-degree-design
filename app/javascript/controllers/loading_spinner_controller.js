import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["spinner", "form"]

  connect() {
    console.log(this.element)
    console.log(this.spinnerTarget)
    console.log(this.formTarget)
  }

  spin(event) {
    // make a validation for the input field?
    event.preventDefault()
    // launch the creation
    this.spinnerTarget.classList.add("blur")
    this.spinnerTarget.classList.add("spinner")
    // wait for 3sec
    // switch view
  }
}
