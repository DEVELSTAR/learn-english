import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "rail",
    "drawer",
    "backdrop",
    "tabContent",
    "tabButton",
    "railButton",
    "mobileFab",
    "mobileFabButton"
  ]

  static values = {
    isOpen: { type: Boolean, default: false },
    activeTab: { type: String, default: "ai_tutor" },
    isMobile: { type: Boolean, default: false }
  }

  connect() {
    this.checkViewport()
    this.handleResize = this.onResize.bind(this)
    window.addEventListener("resize", this.handleResize)

    const savedOpen = localStorage.getItem("lesson_sidebar_open")
    const savedTab = localStorage.getItem("lesson_sidebar_tab")

    if (savedTab && ["ai_tutor", "chatroom", "notes"].includes(savedTab)) {
      this.activeTabValue = savedTab
    }

    if (this.isMobileValue) {
      // On mobile view: show only the single movable menu icon initially
      this.isOpenValue = false
    } else {
      // On laptop view: keep sidebar maximized like the reference image
      this.isOpenValue = savedOpen !== "false"
    }

    this.setupDraggableFab()
    this.updateView()
  }

  disconnect() {
    if (this.handleResize) {
      window.removeEventListener("resize", this.handleResize)
    }
  }

  checkViewport() {
    this.isMobileValue = window.innerWidth < 768
  }

  onResize() {
    const wasMobile = this.isMobileValue
    this.checkViewport()
    if (wasMobile !== this.isMobileValue) {
      this.updateView()
    }
  }

  toggle() {
    this.isOpenValue = !this.isOpenValue
    this.persist()
    this.updateView()
  }

  openTab(event) {
    const tab = event.currentTarget.dataset.tab
    if (tab) {
      this.activeTabValue = tab
    }
    this.isOpenValue = true
    this.persist()
    this.updateView()
  }

  switchTab(event) {
    const tab = event.currentTarget.dataset.tab
    if (tab) {
      this.activeTabValue = tab
      this.persist()
      this.updateView()
    }
  }

  close() {
    this.isOpenValue = false
    this.persist()
    this.updateView()
  }

  persist() {
    // Only persist explicit open/close on desktop so mobile always remains clean
    if (!this.isMobileValue) {
      localStorage.setItem("lesson_sidebar_open", this.isOpenValue)
    }
    localStorage.setItem("lesson_sidebar_tab", this.activeTabValue)
  }

  updateView() {
    // 1. Drawer open/closed animation with inline fallback
    if (this.hasDrawerTarget) {
      if (this.isOpenValue) {
        this.drawerTarget.classList.remove("translate-x-full", "pointer-events-none")
        this.drawerTarget.classList.add("translate-x-0", "pointer-events-auto")
        this.drawerTarget.style.transform = "translateX(0)"
        this.drawerTarget.style.pointerEvents = "auto"
      } else {
        this.drawerTarget.classList.remove("translate-x-0", "pointer-events-auto")
        this.drawerTarget.classList.add("translate-x-full", "pointer-events-none")
        this.drawerTarget.style.transform = "translateX(100%)"
        this.drawerTarget.style.pointerEvents = "none"
      }
    }

    // 2. Backdrop for mobile
    if (this.hasBackdropTarget) {
      if (this.isOpenValue && this.isMobileValue) {
        this.backdropTarget.classList.remove("hidden")
      } else {
        this.backdropTarget.classList.add("hidden")
      }
    }

    // 3. Floating Mobile Menu Button (hidden when drawer is open on mobile)
    if (this.hasMobileFabTarget) {
      if (this.isMobileValue && this.isOpenValue) {
        this.mobileFabTarget.classList.add("hidden")
      } else {
        this.mobileFabTarget.classList.remove("hidden")
      }
    }

    // 4. Highlight active tab in expanded drawer header
    if (this.hasTabButtonTarget) {
      this.tabButtonTargets.forEach(btn => {
        const isCurrent = btn.dataset.tab === this.activeTabValue
        if (isCurrent) {
          btn.classList.add("bg-stone-900", "text-white", "shadow-xs")
          btn.classList.remove("text-stone-600", "hover:bg-stone-100", "hover:text-stone-900")
        } else {
          btn.classList.remove("bg-stone-900", "text-white", "shadow-xs")
          btn.classList.add("text-stone-600", "hover:bg-stone-100", "hover:text-stone-900")
        }
      })
    }

    // 5. Highlight active icon in collapsed desktop slim rail
    if (this.hasRailButtonTarget) {
      this.railButtonTargets.forEach(btn => {
        const isCurrent = this.isOpenValue && btn.dataset.tab === this.activeTabValue
        if (isCurrent) {
          btn.classList.add("bg-stone-900", "text-white")
          btn.classList.remove("text-stone-600", "hover:bg-stone-100", "hover:text-stone-900")
        } else {
          btn.classList.remove("bg-stone-900", "text-white")
          btn.classList.add("text-stone-600", "hover:bg-stone-100", "hover:text-stone-900")
        }
      })
    }

    // 6. Show only active tab content container
    if (this.hasTabContentTarget) {
      this.tabContentTargets.forEach(content => {
        if (content.dataset.tabName === this.activeTabValue) {
          content.classList.remove("hidden")
        } else {
          content.classList.add("hidden")
        }
      })
    }

    // 7. Auto-scroll on tab open
    if (this.isOpenValue) {
      if (this.activeTabValue === "chatroom") {
        const chatRoom = document.getElementById("chat_room_messages")
        if (chatRoom) {
          requestAnimationFrame(() => {
            chatRoom.scrollTop = chatRoom.scrollHeight
          })
        }
      } else if (this.activeTabValue === "ai_tutor") {
        const aiTutor = document.getElementById("chat_messages_container")
        if (aiTutor) {
          requestAnimationFrame(() => {
            aiTutor.scrollTop = aiTutor.scrollHeight
          })
        }
      }
    }
  }

  setupDraggableFab() {
    if (!this.hasMobileFabTarget) return

    const fab = this.mobileFabTarget
    let startX = 0
    let startY = 0
    let initialLeft = 0
    let initialTop = 0
    let isDragging = false
    let hasMoved = false

    // Restore saved position if valid
    const savedTop = sessionStorage.getItem("mobile_fab_top")
    const savedLeft = sessionStorage.getItem("mobile_fab_left")
    if (savedTop && savedLeft) {
      const topNum = parseFloat(savedTop)
      const leftNum = parseFloat(savedLeft)
      if (topNum >= 60 && topNum <= window.innerHeight - 60 && leftNum >= 10 && leftNum <= window.innerWidth - 60) {
        fab.style.top = `${topNum}px`
        fab.style.left = `${leftNum}px`
        fab.style.bottom = "auto"
        fab.style.right = "auto"
      }
    }

    const onStart = (e) => {
      const touch = e.touches ? e.touches[0] : e
      startX = touch.clientX
      startY = touch.clientY

      const rect = fab.getBoundingClientRect()
      initialLeft = rect.left
      initialTop = rect.top
      hasMoved = false
      isDragging = true
    }

    const onMove = (e) => {
      if (!isDragging) return
      const touch = e.touches ? e.touches[0] : e
      const dx = touch.clientX - startX
      const dy = touch.clientY - startY

      if (!hasMoved && Math.hypot(dx, dy) > 8) {
        hasMoved = true
      }

      if (hasMoved) {
        if (e.cancelable) {
          e.preventDefault()
        }
        let newLeft = initialLeft + dx
        let newTop = initialTop + dy

        const maxLeft = window.innerWidth - fab.offsetWidth - 12
        const maxTop = window.innerHeight - fab.offsetHeight - 16
        newLeft = Math.max(12, Math.min(maxLeft, newLeft))
        newTop = Math.max(70, Math.min(maxTop, newTop))

        fab.style.left = `${newLeft}px`
        fab.style.top = `${newTop}px`
        fab.style.bottom = "auto"
        fab.style.right = "auto"
      }
    }

    const onEnd = () => {
      if (isDragging && hasMoved) {
        const rect = fab.getBoundingClientRect()
        sessionStorage.setItem("mobile_fab_top", rect.top)
        sessionStorage.setItem("mobile_fab_left", rect.left)
      }
      isDragging = false
    }

    const fabBtn = this.hasMobileFabButtonTarget ? this.mobileFabButtonTarget : fab
    fabBtn.addEventListener("touchstart", onStart, { passive: true })
    window.addEventListener("touchmove", onMove, { passive: false })
    window.addEventListener("touchend", onEnd)

    fabBtn.addEventListener("mousedown", onStart)
    window.addEventListener("mousemove", onMove)
    window.addEventListener("mouseup", onEnd)

    // Intercept click if finger moved to prevent accidental toggle
    fabBtn.addEventListener("click", (e) => {
      if (hasMoved) {
        e.stopImmediatePropagation()
        e.preventDefault()
        hasMoved = false
      }
    }, true)
  }
}
