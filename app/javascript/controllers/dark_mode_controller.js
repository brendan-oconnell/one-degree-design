import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["bulb","navbar", "white","green", "footer", "highlightnav", "highlight"]

  connect() {
    if (localStorage.getItem("darkSwitch") == "dark") {
      this.navbarTarget.classList.toggle("yellow-background")
      this.whiteTarget.classList.toggle("yellow-background")
      this.bulbTarget.classList.toggle("bulb-light")
      this.greenTarget.classList.toggle("black-background")
      this.footerTarget.classList.toggle("black-background")
      this.highlightTarget.classList.toggle("orange-highlight")
      this.highlightnavTarget.classList.toggle("orange-highlightnav")
    }
  }


  switch(event) {
    event.preventDefault()
    this.navbarTarget.classList.toggle("yellow-background")
    this.whiteTarget.classList.toggle("yellow-background")
    this.bulbTarget.classList.toggle("bulb-light")
    this.greenTarget.classList.toggle("black-background")
    this.footerTarget.classList.toggle("black-background")
    this.highlightTarget.classList.toggle("orange-highlight")
    this.highlightnavTarget.classList.toggle("orange-highlightnav")
    if (localStorage.getItem("darkSwitch") == "dark") {
      localStorage.setItem("darkSwitch", "light")
    } else {
      localStorage.setItem("darkSwitch", "dark")
    }
  }
}
