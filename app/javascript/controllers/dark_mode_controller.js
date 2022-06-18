import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["bulb","navbar", "white","green", "footer", "highlight"]

  connect() {
    if (localStorage.getItem("darkSwitch") == "dark") {
      this.navbarTarget.classList.toggle("yellow-background")
      this.whiteTarget.classList.toggle("yellow-background")
      this.footerTarget.classList.toggle("black-background")
      this.bulbTarget.classList.toggle("bulb-light")
      // this.highlightTarget.classList.toggle("orange-highlight")
      this.greenTarget.classList.toggle("black-background")
    }
  }


  switch(event) {
    event.preventDefault()
    this.navbarTarget.classList.toggle("yellow-background")
    this.whiteTarget.classList.toggle("yellow-background")
    this.footerTarget.classList.toggle("black-background")
    this.bulbTarget.classList.toggle("bulb-light")
    // this.highlightTarget.classList.toggle("orange-highlight")
    this.greenTarget.classList.toggle("black-background")
    if (localStorage.getItem("darkSwitch") == "dark") {
      localStorage.setItem("darkSwitch", "light")
    } else {
      localStorage.setItem("darkSwitch", "dark")
    }
  }
}
