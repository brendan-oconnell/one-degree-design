import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = []

  connect() {
     console.log(this.element)
    // console.log(this.spinnerTarget)
    // console.log(this.formTarget)
  }

  search(event) {
    event.preventDefault()
    console.log(event);
  }
}
