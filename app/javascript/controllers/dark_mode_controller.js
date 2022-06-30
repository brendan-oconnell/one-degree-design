import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["spacer", "bulb","navbar", "white","green", "footer", "highlight", "image","file","font", "format", "color", "size"]

  connect() {
    if (localStorage.getItem("darkSwitch") == "light") {
      this.navbarTarget.classList.toggle("yellow-background")
      this.whiteTarget.classList.toggle("yellow-background")
      this.bulbTarget.classList.toggle("bulb-light")
      this.greenTarget.classList.toggle("black-background")
      this.footerTarget.classList.toggle("black-background")
      this.highlightTarget.classList.toggle("orange-highlight")
      this.spacerTarget.classList.toggle("black-background")
      this.imageTarget.classList.toggle("blue-background")
      this.fileTarget.classList.toggle("blue-background")
      this.fontTarget.classList.toggle("blue-background")
      this.formatTarget.classList.toggle("blue-background")
      this.colorTarget.classList.toggle("blue-background")
      this.sizeTarget.classList.toggle("blue-background")
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
    this.spacerTarget.classList.toggle("black-background")
    this.imageTarget.classList.toggle("blue-background")
    this.fileTarget.classList.toggle("blue-background")
    this.fontTarget.classList.toggle("blue-background")
    this.formatTarget.classList.toggle("blue-background")
    this.colorTarget.classList.toggle("blue-background")
    this.sizeTarget.classList.toggle("blue-background")


    if (localStorage.getItem("darkSwitch") == "light") {
      localStorage.setItem("darkSwitch", "dark")
    } else {
      localStorage.setItem("darkSwitch", "light")
    }
  }
}
