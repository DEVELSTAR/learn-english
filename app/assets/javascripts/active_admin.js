// ActiveAdmin Vanilla JS support for Rails 8 & Propshaft (UJS & Batch Action handling)
(function() {
  "use strict";

  function getCsrfToken() {
    return document.querySelector('meta[name="csrf-token"]')?.getAttribute("content") ||
           document.querySelector('input[name="authenticity_token"]')?.value || "";
  }

  function getCsrfParam() {
    return document.querySelector('meta[name="csrf-param"]')?.getAttribute("content") || "authenticity_token";
  }

  // 1. Bulletproof Capture-Phase Click Handler for data-method="delete" / data-turbo-method
  function handleMethodLink(e) {
    const link = e.target.closest("a[data-method], a[data-turbo-method]");
    if (!link) return;

    const method = (link.getAttribute("data-method") || link.getAttribute("data-turbo-method") || "").toLowerCase();
    if (!method || method === "get") return;

    // Prevent navigation and stop other handlers from taking over
    e.preventDefault();
    e.stopPropagation();
    e.stopImmediatePropagation();

    const confirmMsg = link.getAttribute("data-confirm") || link.getAttribute("data-turbo-confirm");
    if (confirmMsg && !window.confirm(confirmMsg)) {
      return false;
    }

    const form = document.createElement("form");
    form.method = "POST";
    form.action = link.href;
    form.setAttribute("data-turbo", "false");
    form.style.display = "none";

    const csrfToken = getCsrfToken();
    const csrfParam = getCsrfParam();
    if (csrfToken) {
      const csrfInput = document.createElement("input");
      csrfInput.type = "hidden";
      csrfInput.name = csrfParam;
      csrfInput.value = csrfToken;
      form.appendChild(csrfInput);
    }

    const methodInput = document.createElement("input");
    methodInput.type = "hidden";
    methodInput.name = "_method";
    methodInput.value = method;
    form.appendChild(methodInput);

    document.body.appendChild(form);
    HTMLFormElement.prototype.submit.call(form);
    return false;
  }

  // Register in CAPTURE phase so it fires before Turbo or other bubbling listeners
  window.addEventListener("click", handleMethodLink, true);
  document.addEventListener("click", handleMethodLink, true);

  // Also handle links that ONLY have data-confirm without data-method
  document.addEventListener("click", (e) => {
    const confirmLink = e.target.closest("a[data-confirm]:not([data-method]):not([data-turbo-method])");
    if (confirmLink) {
      const confirmMsg = confirmLink.getAttribute("data-confirm");
      if (confirmMsg && !window.confirm(confirmMsg)) {
        e.preventDefault();
        e.stopPropagation();
        return false;
      }
    }
  }, true);

  // 2. Setup Batch Actions and Table Checkbox Selection
  function initActiveAdminUI() {
    const toggleAll = document.querySelector("input.toggle_all");
    const rowCheckboxes = document.querySelectorAll(".paginated_collection input[type='checkbox']:not(.toggle_all)");
    const batchActionSelector = document.querySelector(".batch_actions_selector");

    const updateBatchActions = () => {
      const checkedCount = document.querySelectorAll(".paginated_collection input[type='checkbox']:not(.toggle_all):checked").length;
      if (batchActionSelector) {
        const button = batchActionSelector.querySelector(".dropdown_menu_button");
        if (button) {
          if (checkedCount > 0) {
            button.classList.remove("disabled");
          } else {
            button.classList.add("disabled");
          }
        }
      }
    };

    if (toggleAll && !toggleAll.dataset.aaBound) {
      toggleAll.dataset.aaBound = "true";
      toggleAll.addEventListener("change", () => {
        rowCheckboxes.forEach((cb) => {
          cb.checked = toggleAll.checked;
          const row = cb.closest("tr");
          if (row) row.classList.toggle("selected", toggleAll.checked);
        });
        updateBatchActions();
      });

      rowCheckboxes.forEach((cb) => {
        cb.addEventListener("change", () => {
          const row = cb.closest("tr");
          if (row) row.classList.toggle("selected", cb.checked);
          const allChecked = Array.from(rowCheckboxes).every((c) => c.checked);
          const someChecked = Array.from(rowCheckboxes).some((c) => c.checked);
          toggleAll.checked = allChecked;
          toggleAll.indeterminate = someChecked && !allChecked;
          updateBatchActions();
        });
      });
    }

    // Handle Batch Actions Dropdown & Submission
    if (batchActionSelector && !batchActionSelector.dataset.aaBound) {
      batchActionSelector.dataset.aaBound = "true";
      const button = batchActionSelector.querySelector(".dropdown_menu_button");
      const menuList = batchActionSelector.querySelector(".dropdown_menu_list_wrapper");

      if (button && menuList) {
        button.addEventListener("click", (e) => {
          e.preventDefault();
          e.stopPropagation();
          if (!button.classList.contains("disabled")) {
            menuList.style.display = menuList.style.display === "block" ? "none" : "block";
          }
        });

        document.addEventListener("click", () => {
          menuList.style.display = "none";
        });
      }

      const batchLinks = batchActionSelector.querySelectorAll("a.batch_action");
      batchLinks.forEach((link) => {
        link.addEventListener("click", (e) => {
          e.preventDefault();
          const action = link.getAttribute("data-action");
          const confirmMsg = link.getAttribute("data-confirm");

          if (confirmMsg && !window.confirm(confirmMsg)) {
            return false;
          }

          const batchActionInput = document.getElementById("batch_action");
          const form = document.getElementById("collection_selection");

          if (batchActionInput && form) {
            batchActionInput.value = action;
            form.setAttribute("data-turbo", "false");
            HTMLFormElement.prototype.submit.call(form);
          }
        });
      });
    }
  }

  // Initialize UI on ready, turbo loads, and DOMContentLoaded
  if (document.readyState === "complete" || document.readyState === "interactive") {
    initActiveAdminUI();
  }
  document.addEventListener("DOMContentLoaded", initActiveAdminUI);
  document.addEventListener("turbo:load", initActiveAdminUI);
  window.addEventListener("pageshow", initActiveAdminUI);
})();
